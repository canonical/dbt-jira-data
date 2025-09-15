with base as (
    select * from {{ ref('stg_jira__issues') }}
),

flattened as (
    select
        issue_id,
        issue_key,
        project_key,
        created as created_raw,
        updated as updated_raw,

        cast(nullif(json_extract_scalar(fields_json, '$.customfield_10024'), '') as double)
            as story_points,
        cast(
            coalesce(
                json_extract_scalar(fields_json, '$.customfield_10020[0].id'),
                json_extract_scalar(fields_json, '$.customfield_10020.id')
            ) as bigint
        ) as first_committed_sprint_id,
        json_extract_scalar(fields_json, '$.issuetype.name') as issue_type,
        json_extract_scalar(fields_json, '$.summary') as summary,
        json_extract_scalar(fields_json, '$.priority.name') as priority,
        json_extract_scalar(fields_json, '$.reporter.displayName') as reporter,
        json_extract_scalar(fields_json, '$.assignee.displayName') as assignee,
        json_extract_scalar(fields_json, '$.status.name') as status,

        -- resolution date
        json_extract_scalar(fields_json, '$.project.name') as project,

        -- story points (customfield_10024)
        from_iso8601_timestamp(json_extract_scalar(fields_json, '$.created')) as created_at,

        -- first sprint in the array of sprints (customfield_10020)
        case
            when nullif(json_extract_scalar(fields_json, '$.resolutiondate'), '') is not null
                then from_iso8601_timestamp(json_extract_scalar(fields_json, '$.resolutiondate'))
        end as resolved_at

    from base
)

select * from flattened
