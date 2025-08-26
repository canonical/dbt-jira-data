with

source as (
    select * from {{ source('jira', 'sprint_issues') }}
),

staged as (
    select
        "issueId"::bigint as issue_id,
        "sprintId"::bigint as sprint_id
    from source
)

select * from staged
