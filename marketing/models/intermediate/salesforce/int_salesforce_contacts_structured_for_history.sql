{{ config(materialized = 'ephemeral') }}

with staged as (
    select
        *
    from
        {{ ref("stg_salesforce__contacts") }}
),
intermediate as (
    select
        cast(null as varchar) as pseudo_contact_lead_id,
        contact_id,
        contact_created_date as pseudo_contact_record_date,
        'created' as pseduo_contact_history_field,
        cast(null as varchar) as pseudo_contact_history_field_old_value,
        cast(null as varchar) as pseudo_contact_history_field_new_value,
        contact_created_date as contact_created_date
    from
        staged
)
select
    *
from
    intermediate