with source as (
    select
        *
    FROM
        {{ source("marketing_salesforce", "salesforce_userrole") }}
),
staged as (
    select
    id as user_role_id,
    name as user_role_name
    from source
)
select * from staged