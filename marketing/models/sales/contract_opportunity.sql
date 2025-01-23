{{ config(materialized='table') }}

with opportunity as (

    select *
    from {{ source('marketing', 'salesforce_opportunity') }}

),

contract as (
    select *
    from {{ source('sales', 'salesforce_contract') }}
)

select so.amount, so.stagename, sc.contractterm
from contract sc
left join opportunity sc
    on sc.id = so.contractid
where sc.accountid is not null
limit 10
