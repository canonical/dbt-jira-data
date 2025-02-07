with source as (
    select
        *
    from
        {{ source("marketing_salesforce", "salesforce_campaign") }}
),
staged as (
    select
        s.id as campaign_id,
        s.name as campaign_name,
        s.type as campaign_type
    from
        source as s
)
select
    *
from
    staged