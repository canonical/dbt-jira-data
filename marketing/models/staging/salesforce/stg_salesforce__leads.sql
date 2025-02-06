with source as (
    select
        *
    FROM
        {{ source("marketing_salesforce", "salesforce_lead") }}
),
staged as (
    select
sl.id as lead_id,
sl.acquisition_url__c as lead_acquisition_url,
sl.alliance_type__c as lead_alliance_type,
sl.comments_from_lead__c as lead_comments,
sl.company as lead_company,
sl.convertedcontactid as lead_contact_id,
sl.convertedopportunityid as lead_opportunity_id,
sl.country as lead_country,
sl.createdbyid as lead_created_by_id,
sl.createddate as lead_created_date,
sl.description as lead_description,
sl.disqualified_reason__c as lead_disqualified_reason,
sl.email as lead_email,
sl.firstname as lead_first_name,
sl.industry as lead_industry,
sl.iot__c as lead_iot,
sl.last_touch_by_owner__c as lead_last_touch_date,
sl.lastmodifieddate as lead_last_modified_date,
sl.lastname as lead_last_name,
sl.leadsource as lead_source,
sl.marketing_opt_in__c as lead_opt_in,
sl.mkto71_acquisition_program__c as lead_acquistion_program,
sl.nurture_reason__c as lead_nurture_reason,
sl.ownerid as lead_owner_id,
sl.primary_product_interest2__c as lead_product_interest,
sl.region__c as lead_region,
sl.salesloft1__most_recent_cadence_name__c as lead_most_recent_cadence,
sl.sql_by_sdr__c as lead_sql_by_sdr,
sl.state as lead_state,
sl.status as lead_status,
sl.tier__c as lead_tier,
sl.title as lead_job_title,
COALESCE(
    sl.leandata__reporting_matched_account__c,
    sl.convertedaccountid
) as lead_account_id,
sl.source_detail__c AS lead_source_detail
    from
        source as sl
    where
        sl.createddate >= (
            (current_timestamp - INTERVAL '2' YEAR)
        )
        or sl.lastmodifieddate >= (
            (current_timestamp - INTERVAL '2' YEAR)
        )
)
select
    *
from
    staged