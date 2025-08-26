with

source as (
    select * from {{ source('jira', 'issues') }}
),

staged as (
    select
        id::bigint as issue_id,
        key as issue_key,
        changelog as changelog_json
    from source
)

select * from staged
