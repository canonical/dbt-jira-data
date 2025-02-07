with source as (
    select
        *
    from
        {{ source(
            "marketing_salesforce",
            "salesforce_account"
        ) }}
),
staged as (
    select
        s.id as account_id,
        s.name as account_name,
        s.ownerid as account_owner_id,
        s.industry as account_industry
    from
        source as s
)
select
    *
from
    staged