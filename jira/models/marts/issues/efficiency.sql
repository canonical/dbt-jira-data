WITH delivered_stories AS (
    SELECT
        s.sprint_id,
        s.name AS sprint_name,
        s.started_at,
        i.issue_id,
        i.summary,
        i.project,
        'delivered_story' AS metric_type
    FROM {{ ref('int_jira__sprints') }} s
    JOIN {{ ref('int_jira__sprint_issues') }} isl ON s.sprint_id = isl.sprint_id
    JOIN {{ ref('int_jira__issues') }} i ON i.issue_id = isl.issue_id
    WHERE
        i.issue_type IN ('Story', 'Task')
        AND i.resolved_at BETWEEN s.started_at AND s.completed_at
),

opened_bugs AS (
    SELECT
        s.sprint_id,
        s.name AS sprint_name,
        s.started_at,
        i.issue_id,
        i.summary,
        i.project,
        'opened_bug' AS metric_type
    FROM {{ ref('int_jira__sprints') }} s
    JOIN {{ ref('int_jira__issues') }} i ON i.issue_type = 'Bug'
    WHERE i.created_at BETWEEN s.started_at AND s.completed_at
)

SELECT * FROM delivered_stories
UNION ALL
SELECT * FROM opened_bugs
