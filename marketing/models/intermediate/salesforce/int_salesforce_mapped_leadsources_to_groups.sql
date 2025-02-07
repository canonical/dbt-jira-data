{{ config(materialized = 'table') }}

with sources as (
    select
        distinct sl.lead_source as lead_source
    from
        {{ ref("stg_salesforce__leads") }} as sl
),
mapped as (
select
    lead_source,
    {{ salesforce_lead_source_grouping('lead_source') }} as lead_source_group
from
    sources
)
select * from mapped