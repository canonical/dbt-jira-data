with source as (
    select
        *
    FROM
        {{ source("marketing_salesforce", "salesforce_contact") }}
),
staged as (
    select
        id as contact_id,
        createddate AS contact_created_date
    from
        source
    where
        createddate >= (
            (current_timestamp - INTERVAL '2' YEAR)
        )
)
select
    *
from
    staged