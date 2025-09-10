select  
    issue_id,
    sprint_id,
    added_at
from {{ ref('int_jira__sprint_issues') }}