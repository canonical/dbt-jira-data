with mart as (
select
    *
from
    {{ ref("int_salesforce_contacts_joined_for_no_lead_relation") }}

union all

select
    *
from
    {{ ref("int_salesforce_lead_contact_history") }}
)
select * from mart