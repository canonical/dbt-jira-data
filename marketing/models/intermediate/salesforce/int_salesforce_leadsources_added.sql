with sf_leads as (
    select
        *
    from
        {{ ref("stg_salesforce__leads") }}
),
intermediate as (
    select
        sl.*,
        ls.lead_source_group
    from
        sf_leads as sl
        left join {{ ref('int_salesforce_mapped_leadsources_to_groups') }} as ls on ls.lead_source = sl.lead_source
)
select
    *
from
    intermediate