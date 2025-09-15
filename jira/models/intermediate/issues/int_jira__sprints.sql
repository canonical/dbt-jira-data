with source as (
    select
        issue_id,
        fields_json
    from {{ ref('stg_jira__issues') }}
),

sprint_arrays as (
    select try_cast(json_extract(fields_json, '$.customfield_10020') as array(json)) as sprints_json
    from source
    where json_extract(fields_json, '$.customfield_10020') is not null
),

exploded as (
    select t.sprint_json
    from sprint_arrays as sa
    cross join unnest(sa.sprints_json) as t (sprint_json)
),

typed as (
    select
        cast(json_extract_scalar(sprint_json, '$.id') as bigint) as sprint_id,
        json_extract_scalar(sprint_json, '$.name') as name,
        json_extract_scalar(sprint_json, '$.state') as state,
        from_iso8601_timestamp(json_extract_scalar(sprint_json, '$.startDate')) as started_at,
        from_iso8601_timestamp(json_extract_scalar(sprint_json, '$.completeDate')) as completed_at
    from exploded
),

base as (
    select
        sprint_id,
        any_value(name) as name,
        any_value(state) as state,
        min(started_at) as started_at,
        max(completed_at) as completed_at
    from typed
    where sprint_id is not null
    group by sprint_id
),

normalized as (
    select
        sprint_id,
        name as original_name,
        state,
        started_at,
        completed_at,
        -- normalized canonical name: YYYY#NN (left-pad sprint number to 2 digits)
        case
            when
                regexp_like(
                    name,
                    '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*'
                )
                then concat(
                    regexp_extract(
                        name,
                        '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*',
                        1
                    ),
                    '#',
                    lpad(
                        regexp_extract(
                            name,
                            '(?i).*(?:^|[^0-9])(20[0-9]{2})[ \t]*#[ \t]*([0-9]{1,2})(?:[^0-9]|$).*',
                            2
                        ),
                        2,
                        '0'
                    )
                )
            else 'ERROR'
        end as name
    from base
)

select
    sprint_id,
    original_name,
    name,
    state,
    started_at,
    completed_at
from normalized
