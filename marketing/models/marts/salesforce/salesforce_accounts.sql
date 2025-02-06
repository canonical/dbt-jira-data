{{ config(materialized = 'table') }}
with mart as (
select
    sa.*,
    rm.user_role_group,
    im.industry_group
from
    {{ ref("stg_salesforce__accounts") }} AS sa
    left join {{ ref("stg_salesforce__users") }} AS su on sa.account_owner_id = su.user_id
    left join {{ ref("stg_salesforce__userroles") }} AS sur on su.user_role_id = sur.user_role_id
    left join {{ ref('int_salesforce_mapped_account_owner_roles_to_groups') }} AS rm ON rm.user_role_name = sur.user_role_name
    left join {{ ref('int_salesforce_mapped_accounts_to_industry') }} AS im ON im.account_industry = sa.account_industry
)
select * from mart