SELECT
    s.name AS sprint_name,
    '<a href="https://warthogs.atlassian.net/browse/'
    || i.issue_key
    || '" target="_blank">'
    || i.issue_key
    || '</a>' AS issue_url,
    i.summary,
    i.priority,
    i.project,
    CASE
        WHEN i.priority IN ('Highest', 'High') THEN 'P1/2'
        ELSE 'P3'
    END AS priority_group,
    i.created_at,
    i.resolved_at
FROM {{ ref('int_jira__sprints') }} s
JOIN {{ ref('int_jira__sprint_issues') }} isl ON isl.sprint_id = s.sprint_id
JOIN {{ ref('int_jira__issues') }} i ON isl.issue_id = i.issue_id
WHERE
    i.issue_type = 'Bug'
    AND i.created_at <= s.completed_at
    AND (
        i.resolved_at IS NULL
        OR i.resolved_at >= s.started_at
    )
