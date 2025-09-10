with

source as (
    select * from {{ source('jira', 'sprints') }}
),

ranked as (
    select
        CAST(id AS BIGINT)        as sprint_id,
        name                      as name,
        state                     as state,
        "startDate"               as started_at,
        "completeDate"            as completed_at,
        row_number() over (
            partition by id
            order by coalesce("completeDate", "startDate") desc
        ) as rn
    from source
)

select
    sprint_id,
    name,
    state,
    started_at,
    completed_at
from ranked
where rn = 1