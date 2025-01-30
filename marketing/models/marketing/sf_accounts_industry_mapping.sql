{{ config(materialized = 'table') }}

with industries as 
(select
    distinct sa.industry AS industry
from {{ source('marketing', 'salesforce_account') }} AS sa
)
select
    industry,
    {{ account_industry_bucket('industry') }} as industry_bucket
    from industries
    