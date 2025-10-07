WITH status_intervals AS (
    SELECT
        issue_id,
        issue_key,
        to_status AS status,
        changed_at AS status_start,
        LEAD(changed_at) OVER (
            PARTITION BY issue_id
            ORDER BY changed_at
        ) AS status_end
    FROM {{ ref('int_jira__issue_status_histories') }}
),

status_times AS (
    SELECT
        s.sprint_id,
        s.name AS sprint_name,
        si.issue_id,
        i.issue_key,
        i.summary,
        i.project,
        si.status,
        GREATEST(si.status_start, s.started_at) AS period_start,
        LEAST(COALESCE(si.status_end, NOW()), s.completed_at) AS period_end,
        DATE_DIFF(
            'second',
            GREATEST(si.status_start, s.started_at),
            LEAST(COALESCE(si.status_end, CURRENT_TIMESTAMP), s.completed_at)
        ) AS seconds_in_status
    FROM status_intervals si
    JOIN {{ ref('int_jira__sprint_issues') }} isl ON si.issue_id = isl.issue_id
    JOIN {{ ref('int_jira__sprints') }} s ON isl.sprint_id = s.sprint_id
    JOIN {{ ref('int_jira__issues') }} i ON si.issue_id = i.issue_id
    WHERE
        COALESCE(si.status_end, NOW()) > s.started_at
        AND si.status_start < s.completed_at
)

SELECT
    '<a href="https://warthogs.atlassian.net/browse/'
    || issue_key
    || '" target="_blank">'
    || issue_key
    || '</a>' AS issue_url,
    sprint_id,
    sprint_name,
    issue_id,
    summary,
    status,
    project,
    period_start,
    period_end,
    seconds_in_status,
    seconds_in_status / 3600.0 AS hours_in_status
FROM status_times
ORDER BY sprint_id, issue_id, status, period_start
