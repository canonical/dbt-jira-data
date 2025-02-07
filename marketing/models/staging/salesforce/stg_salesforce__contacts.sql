with source as (
    select
        *
    from
        {{ source("marketing_salesforce", "salesforce_contact") }}
),
staged as (
    select
        id as contact_id,
        createddate as contact_created_date
    from
        source
    where
        createddate >= (
            (current_timestamp - interval '2' year)
        )
)
select
    *
from
    staged