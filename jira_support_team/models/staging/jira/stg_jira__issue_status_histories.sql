with

source as (
    select * from {{ source('jira', 'issues') }}
),

staged as (
    select
        id as issue_id,
        key as issue_key,
        changelog as changelog_json
    from source
)

select * from staged