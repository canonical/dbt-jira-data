with source as (
    select
        *
    FROM
        {{ source("marketing_salesforce", "salesforce_user") }}
),
staged as (
    select
        id as user_id,
        userroleid as user_role_id
    from
        source
)
select
    *
from
    staged