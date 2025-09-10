with

source as (
    select * from {{ source('jira', 'sprints') }}
),

staged as (
    select
        CAST(id AS BIGINT) as sprint_id,
        name as name,
        state as state,
        "startDate" as started_at,
        "completeDate" as completed_at
    from source
)

select * from staged
