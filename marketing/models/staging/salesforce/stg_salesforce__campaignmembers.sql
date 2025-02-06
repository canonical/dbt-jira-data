with source as (
    select
        *
    FROM
        { { source("marketing_salesforce", "salesforce_campaignmember") } }
),
staged as (
    select
        leadid as campaignmember_lead_id,
        contactid as campaignmember_contact_id,
        campaignid as campaignmember_campaign_id,
        createddate as campaignmember_created_date
    from
        source as s
)
select
    *
from
    staged