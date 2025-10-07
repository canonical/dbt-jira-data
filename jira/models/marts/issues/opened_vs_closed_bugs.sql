SELECT
    s.sprint_id,
    s.name AS sprint_name,
    '<a href="https://warthogs.atlassian.net/browse/'
    || i.issue_key
    || '" target="_blank">'
    || i.issue_key
    || '</a>' AS issue_url,
    i.summary,
    i.project,
    i.created_at,
    i.resolved_at,
    i.priority,
    'opened' AS status
FROM {{ ref('int_jira__issues') }} i
JOIN {{ ref('int_jira__sprint_issues') }} isl ON i.issue_id = isl.issue_id
JOIN {{ ref('int_jira__sprints') }} s ON s.sprint_id = isl.sprint_id
WHERE
    i.issue_type = 'Bug'
    AND i.created_at BETWEEN s.started_at AND s.completed_at

UNION ALL

SELECT
    s.sprint_id,
    s.name AS sprint_name,
    '<a href="https://warthogs.atlassian.net/browse/'
    || i.issue_key
    || '" target="_blank">'
    || i.issue_key
    || '</a>' AS issue_url,
    i.summary,
    i.project,
    i.created_at,
    i.resolved_at,
    i.priority,
    'closed' AS status
FROM {{ ref('int_jira__issues') }} i
JOIN {{ ref('int_jira__sprint_issues') }} isl ON i.issue_id = isl.issue_id
JOIN {{ ref('int_jira__sprints') }} s ON s.sprint_id = isl.sprint_id
WHERE
    i.issue_type = 'Bug'
    AND i.resolved_at BETWEEN s.started_at AND s.completed_at
