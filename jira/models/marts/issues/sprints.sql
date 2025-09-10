select  
    sprint_id,
    name,
    state,
    started_at,
    completed_at
from {{ ref('int_jira__sprints') }}