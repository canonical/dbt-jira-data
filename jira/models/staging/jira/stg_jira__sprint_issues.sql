with

source as (
    select * from {{ source('jira', 'sprint_issues') }}
),

staged as (
    select
        CAST("issueId" AS BIGINT)  as issue_id,
        CAST("sprintId" AS BIGINT) as sprint_id
    from source
)

select * from staged
