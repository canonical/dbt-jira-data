select
    issue_id,
    issue_key,
    changed_at,
    from_string,
    to_string,
    from_id,
    to_id
from {{ ref('int_jira__issue_sprint_histories') }}
