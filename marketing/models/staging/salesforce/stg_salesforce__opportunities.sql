with source as (
    select
        *
    FROM
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