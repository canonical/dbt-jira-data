with src as (
    select
        issue_id,
        cast(fields_json as json) as f
    from {{ ref('stg_jira__issues') }}
),

labels_array as (
    select
        issue_id,
        cast(json_extract(f, '$.labels') as array(varchar)) as labels
    from src
    where json_extract(f, '$.labels') is not null
)

select
    issue_id,
    label
from labels_array
cross join unnest(labels) as t(label)
where label is not null