{{ config(materialized = 'ephemeral') }}

with source_leads as (
    select
        sl.lead_id,
        sl.lead_contact_id,
        sl.lead_created_date
    from
        {{ ref("stg_salesforce__leads") }} as sl
),
intermediate as (
    select
        lh.history_lead_id,
        lc.lead_contact_id,
        lh.history_record_date,
        lh.history_field,
        lh.history_field_old_value,
        lh.history_field_new_value,
        lc.lead_created_date
    from
        {{ ref("stg_salesforce__leadhistories") }} as lh
        left join source_leads as lc on lh.history_lead_id = lc.lead_id
)
select * from intermediate

    