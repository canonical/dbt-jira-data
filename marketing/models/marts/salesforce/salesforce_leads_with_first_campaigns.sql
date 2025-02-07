with stg_leadhistories as (
    select
        distinct history_lead_id -- the id of the lead 
    from
        {{ ref("stg_salesforce__leadhistories") }}
),
stg_leads as (
    select
        *
    from
        {{ ref("stg_salesforce__leads") }}
),
int_first_campaigns as (
    select
        *
    from
        {{ ref("int_salesforce_first_campaigns_associated_to_leads") }}
    where
        campaignmembership_sequence = 1
),
mart as (
select
    *
from
    stg_leadhistories as slh
    left join stg_leads as sl on slh.history_lead_id = sl.lead_id
    left join int_first_campaigns as ifc on ifc.campaignmember_lead_id = sl.lead_id
)
select * from mart