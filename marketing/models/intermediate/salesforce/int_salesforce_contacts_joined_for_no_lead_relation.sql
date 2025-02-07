{{ config(materialized = 'ephemeral') }}

with pseddo_history_contacts as (
    select
        pseudo_contact_lead_id,
        contact_id,
        pseudo_contact_record_date,
        pseduo_contact_history_field,
        pseudo_contact_history_field_old_value,
        pseudo_contact_history_field_new_value,
        contact_created_date
    from
        {{ ref("int_salesforce_contacts_structured_for_history") }}
),
contacts_created_directly as (
    select
        contact_id
    from
        pseddo_history_contacts
    where
        contact_id not in (
            select
                lead_contact_id
            from
                {{ ref("int_salesforce_lead_contact_history") }}
        )
)
select
    sc.pseudo_contact_lead_id as history_lead_id,
    ccd.contact_id,
    sc.pseudo_contact_record_date as history_record_date,
    sc.pseduo_contact_history_field as history_field,
    sc.pseudo_contact_history_field_old_value as history_field_old_value,
    sc.pseudo_contact_history_field_new_value as history_field_new_value,
    sc.contact_created_date as lead_created_date
from
    pseddo_history_contacts as sc
    join contacts_created_directly ccd on sc.contact_id = ccd.contact_id