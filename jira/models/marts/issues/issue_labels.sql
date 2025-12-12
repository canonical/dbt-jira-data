with src as (
    select
        issue_id,
        label
    from {{ ref('int_jira__issue_labels') }}
)

select distinct
    cast(issue_id as bigint) as issue_id,
    cast(label as varchar) as label
from src
where label is not null
order by issue_id, label