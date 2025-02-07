with source as (
    select
        *
    from
        {{ source("marketing_salesforce", "salesforce_opportunity") }}
),
staged as (
    select
        *
    from
        source
)
select
    *
from
    staged