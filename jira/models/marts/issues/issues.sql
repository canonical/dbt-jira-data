select
    issue_id,
    issue_key,
    issue_type,
    summary,
    priority,
    reporter,
    assignee,
    status,
    created_at,
    resolved_at,
    story_points,
    first_committed_sprint_id,
    project_key,
    project
from {{ ref('int_jira__issues') }}
