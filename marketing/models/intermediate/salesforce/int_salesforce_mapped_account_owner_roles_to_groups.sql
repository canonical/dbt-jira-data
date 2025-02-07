{{ config(materialized = 'table') }} 

with source_roles as (
    select
        distinct sur.user_role_name
    from
        {{ ref("stg_salesforce__userroles") }} as sur
),
mapped as (
select
    user_role_name,
    {{ salesforce_user_role_grouping('user_role_name') }} as user_role_group
from
    source_roles
    )
select * from mapped