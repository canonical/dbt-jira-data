select
    name,
    `alpha-2` as country_code
from {{ ref('country_codes') }}
