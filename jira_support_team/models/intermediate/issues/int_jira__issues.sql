with base as (
    select * from {{ ref('stg_jira__issues') }}
),

-- Extract and cast in one place
flattened as (
    select
        issue_id,
        issue_key,
        project_key,

        (fields_json -> 'issuetype' ->> 'name') as issue_type,
        (fields_json ->> 'summary') as summary,
        (fields_json -> 'priority' ->> 'name') as priority,
        (fields_json -> 'reporter' ->> 'displayName') as reporter,
        (fields_json -> 'assignee' ->> 'displayName') as assignee,
        (fields_json -> 'status' ->> 'name') as status,
        (fields_json ->> 'created')::timestamptz as created_at,
        nullif(fields_json ->> 'resolutiondate', '')::timestamptz as resolved_at,
        nullif(fields_json ->> 'customfield_10024', '')::numeric as story_points,
        (fields_json -> 'project' ->> 'name') as project,

        -- keep raw timestamps too (from top-level) just in case
        created as created_raw,
        updated as updated_raw,
        
        -- sprints
        case
            when jsonb_typeof(fields_json->'customfield_10020') = 'array'
            then ((fields_json->'customfield_10020')->0->>'id')::bigint
            when jsonb_typeof(fields_json->'customfield_10020') = 'object'
            then ((fields_json->'customfield_10020')->>'id')::bigint
            else null
        end as first_committed_sprint_id

    from base
),

-- NEED TO BE CHECKED ON PROD.
validated as (
    select
        f.*,
        case
            when s.sprint_id is not null then f.first_committed_sprint_id
            else null
        end as validated_first_committed_sprint_id
    from flattened f
    left join {{ ref('stg_jira__sprints') }} s
        on f.first_committed_sprint_id = s.sprint_id
)

select
    issue_id,
    issue_key,
    issue_type,
    summary,
    priority,
    reporter,
    assignee,
    status,
    created_at,
    resolved_at,
    story_points,
    validated_first_committed_sprint_id as first_committed_sprint_id,
    project_key,
    project
from validated

