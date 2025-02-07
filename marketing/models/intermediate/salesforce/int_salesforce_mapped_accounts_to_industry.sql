{{ config(materialized = 'table') }} 

with source_industry as (
    select
        distinct sa.account_industry
    from
        {{ ref("stg_salesforce__accounts") }} as sa
),
mapped as (
select
    account_industry,
    {{ salesforce_account_industry_grouping('account_industry') }} as industry_group
from
    source_industry
    )
select * from mapped