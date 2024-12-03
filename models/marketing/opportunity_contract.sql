{{ config(materialized='table') }}

with opportunity as (

    select *
    from {{ source('marketborg', 'salesforce_opportunity') }}

),

contract as (
    select *
    from {{ source('salesborg', 'salesforce_contract') }}
)

select so.id, sc.accountid
from opportunity so
left join contract sc
    on sc.id = so.contractid
where sc.accountid is not null
