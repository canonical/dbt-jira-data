with source as (
    select
        *
    FROM
        {{ source("marketing_salesforce", "salesforce_leadhistory") }}
),
staged as (
    select
        leadid as history_lead_id,
        CAST(createddate AS TIMESTAMP) AS history_record_date,
        field as history_field,
        oldvalue as history_field_old_value,
        newvalue as history_field_new_value
    from
        source
    where field in ('Status', 'created', 'Google_Analytics_User_ID__c')
    and createddate >= (current_timestamp - INTERVAL '2' YEAR)
)
select
    *
from
    staged