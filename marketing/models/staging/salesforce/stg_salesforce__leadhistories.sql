with source as (
    select
        *
    from
        {{ source("marketing_salesforce", "salesforce_leadhistory") }}
),
staged as (
    select
        leadid as history_lead_id,
        cast(createddate as timestamp) as history_record_date,
        field as history_field,
        oldvalue as history_field_old_value,
        newvalue as history_field_new_value
    from
        source
    where field in ('status', 'created', 'google_analytics_user_id__c')
    and createddate >= (current_timestamp - interval '2' year)
)
select
    *
from
    staged