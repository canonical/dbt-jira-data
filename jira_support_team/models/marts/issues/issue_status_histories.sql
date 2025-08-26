{{ config(
  indexes=[
    {'columns': ['issue_id', 'changed_at']}
  ]
) }}

select
    issue_id,
    issue_key,
    changed_at,
    from_status,
    to_status
from {{ ref('int_jira__issue_status_histories') }}
