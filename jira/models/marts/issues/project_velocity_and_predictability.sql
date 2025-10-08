WITH base AS (
    SELECT
        s.sprint_id,
        s.name AS sprint_name,
        s.started_at,
        s.completed_at,
        i.issue_key,
        i.issue_type,
        i.summary,
        i.project,
        i.created_at,
        i.resolved_at,
        isl.added_at
    FROM {{ ref('int_jira__issues') }} i
    JOIN {{ ref('int_jira__sprint_issues') }} isl ON i.issue_id = isl.issue_id
    JOIN {{ ref('int_jira__sprints') }} s ON s.sprint_id = isl.sprint_id
    WHERE i.issue_type IN ('Bug', 'Story', 'Task', 'Spike')
),

committed AS (
    SELECT
        sprint_id,
        sprint_name,
        '<a href="https://warthogs.atlassian.net/browse/'
        || issue_key
        || '" target="_blank">'
        || issue_key
        || '</a>' AS issue_url,
        issue_type,
        summary,
        project,
        'committed' AS status
    FROM base
),

delivered AS (
    SELECT
        sprint_id,
        sprint_name,
        '<a href="https://warthogs.atlassian.net/browse/'
        || issue_key
        || '" target="_blank">'
        || issue_key
        || '</a>' AS issue_url,
        issue_type,
        summary,
        project,
        'delivered' AS status
    FROM base
    WHERE resolved_at >= started_at AND resolved_at <= completed_at
)

SELECT * FROM committed
UNION ALL
SELECT * FROM delivered
