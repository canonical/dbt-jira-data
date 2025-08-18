select
  issue_id,
  issue_key,
  project_key,
  project,
  issue_type,
  summary,
  priority,
  reporter,
  assignee,
  status,
  created_at,
  resolved_at,
  story_points
from {{ ref('int_jira__issues_flat') }}