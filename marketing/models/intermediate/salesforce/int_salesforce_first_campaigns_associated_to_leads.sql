{{ config(materialized = 'ephemeral') }}

with campaigns as (
    select
        *
    from
        {{ ref("stg_salesforce__campaigns") }}
),
campaignmembers as (
    select
        *
    from
        {{ ref("stg_salesforce__campaignmembers") }}
),
campaign_data as (
    select
        cm.campaignmember_lead_id,
        --the id of the lead
        cm.campaignmember_campaign_id,
        --the id of the campaign
        cm.campaignmember_created_date,
        --the date the lead touched the campaign
        c.campaign_name,
        --the name of the campaign
        row_number() over (
            partition by cm.campaignmember_lead_id
            order by
                cm.campaignmember_created_date asc
        ) as seq --order campaigns at the lead level by date of lead touch  
    from
        campaignmembers as cm
        left join campaigns as c on c.campaign_id = cm.campaignmember_campaign_id
    where
        c.campaign_name is not null
        and (c.campaign_type <> varchar 'operational')
),
intermediate as (
select
    campaignmember_lead_id,
    campaign_name as campaignmember_first_campaign
from
    campaign_data
where
    seq = 1 --grab only the records representing the first campaign the lead touched
    and campaignmember_lead_id is not null
)
select * from intermediate