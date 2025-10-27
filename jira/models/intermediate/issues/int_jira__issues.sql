with base as (
    select *
    from {{ ref('stg_jira__issues') }}
),

parsed as (
    select
        issue_id,
        issue_key,
        project_key,
        created as created_raw,
        updated as updated_raw,
        cast(fields_json as json) as f
    from base
)

select
    issue_id,
    issue_key,
    project_key,

    from_iso8601_timestamp(json_extract_scalar(f, '$.created')) as created_at,
    case
        when nullif(json_extract_scalar(f, '$.resolutiondate'), '') is not null
            then from_iso8601_timestamp(json_extract_scalar(f, '$.resolutiondate'))
    end as resolved_at,

    cast(nullif(json_extract_scalar(f, '$.customfield_10024'), '') as double) as story_points,

    cast(
        coalesce(
            json_extract_scalar(f, '$.customfield_10020[0].id'),
            json_extract_scalar(f, '$.customfield_10020.id')
        ) as bigint
    ) as first_committed_sprint_id,

    json_extract_scalar(f, '$.issuetype.name') as issue_type,
    json_extract_scalar(f, '$.summary') as summary,
    json_extract_scalar(f, '$.priority.name') as priority,
    json_extract_scalar(f, '$.reporter.displayName') as reporter,
    json_extract_scalar(f, '$.assignee.displayName') as assignee,
    json_extract_scalar(f, '$.status.name') as status,
    json_extract_scalar(f, '$.project.name') as project,

    created_raw,
    updated_raw as updated_at

from parsed
