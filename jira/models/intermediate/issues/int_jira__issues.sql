with base as (
    select * from {{ ref('stg_jira__issues') }}
),

flattened as (
    select
        issue_id,
        issue_key,
        project_key,

        /* JSON → scalar strings */
        json_extract_scalar(fields_json, '$.issuetype.name')          as issue_type,
        json_extract_scalar(fields_json, '$.summary')                  as summary,
        json_extract_scalar(fields_json, '$.priority.name')            as priority,
        json_extract_scalar(fields_json, '$.reporter.displayName')     as reporter,
        json_extract_scalar(fields_json, '$.assignee.displayName')     as assignee,
        json_extract_scalar(fields_json, '$.status.name')              as status,

        /* timestamps (ISO8601 strings → TIMESTAMP WITH TIME ZONE) */
        from_iso8601_timestamp(json_extract_scalar(fields_json, '$.created'))                    as created_at,
        case
            when nullif(json_extract_scalar(fields_json, '$.resolutiondate'), '') is not null
            then from_iso8601_timestamp(json_extract_scalar(fields_json, '$.resolutiondate'))
            else null
        end                                                                                      as resolved_at,

        /* numeric (story points) — cast from string; adjust to DECIMAL(p,s) if you prefer */
        cast(nullif(json_extract_scalar(fields_json, '$.customfield_10024'), '') as double)      as story_points,

        json_extract_scalar(fields_json, '$.project.name')                as project,

        /* keep raw timestamps from top-level fields if present */
        created as created_raw,
        updated as updated_raw,

        /* first_committed_sprint_id: handle array OR object shape */
        cast(
            coalesce(
                json_extract_scalar(fields_json, '$.customfield_10020[0].id'),
                json_extract_scalar(fields_json, '$.customfield_10020.id')
            ) as bigint
        ) as first_committed_sprint_id

    from base
),

validated as (
    select
        f.*,
        case when s.sprint_id is not null then f.first_committed_sprint_id else null end
            as validated_first_committed_sprint_id
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