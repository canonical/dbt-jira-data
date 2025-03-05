with

source as (
    select * from {{ ref('country_codes') }}
),

staged as (

    select
        name,
        "alpha-2" as country_code
    from source

)

select *
from staged
