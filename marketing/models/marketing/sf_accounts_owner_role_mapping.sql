{{ config(materialized = 'table') }}

with roles as 
(select
    distinct sur.name AS name
from {{ source('marketing', 'salesforce_userrole') }} AS sur
)
select
    name,
    {{ account_owner_role_bucket('name') }} as name_bucket
    from roles
    