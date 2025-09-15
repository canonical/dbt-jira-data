select
    sprint_id,
    name,
    original_name,
    state,
    started_at,
    completed_at
from {{ ref('int_jira__sprints') }}
