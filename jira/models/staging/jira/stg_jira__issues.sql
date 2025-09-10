with

source as (
    select * from {{ source('jira', 'issues') }}
),

staged as (
    select
        CAST(id AS BIGINT) as issue_id,
        key as issue_key,
        fields as fields_json,
        created as created,
        updated as updated,
        "projectKey" as project_key
    from source
)

select * from staged
