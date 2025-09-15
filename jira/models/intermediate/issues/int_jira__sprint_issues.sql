with issues as (
    select
        issue_id,
        fields_json,
        from_iso8601_timestamp(json_extract_scalar(fields_json, '$.created')) as created_at
    from {{ ref('stg_jira__issues') }}
),

current_field_links as (
    select
        i.issue_id,
        cast(json_extract_scalar(u.sj, '$.id') as bigint) as sprint_id,
        i.created_at
    from issues as i
    cross join
        unnest(
            try_cast(json_extract(i.fields_json, '$.customfield_10020') as array(json))
        ) as u (sj)
    where
        json_extract(i.fields_json, '$.customfield_10020') is not null
        and cast(json_extract_scalar(u.sj, '$.id') as bigint) is not null
),

sprint_changes_expanded as (
    select
        ish.issue_id,
        cast(ids.m as bigint) as sprint_id,
        ish.changed_at
    from {{ ref('int_jira__issue_sprint_histories') }} as ish
    cross join
        unnest(
            regexp_extract_all(coalesce(ish.to_id, ''), '(\d+)')
        ) as ids (m)
    where ish.to_id is not null
),

first_added as (
    select
        issue_id,
        sprint_id,
        min(changed_at) as added_at
    from sprint_changes_expanded
    group by issue_id, sprint_id
),

initial_sprint_assignments as (
    select
        c.issue_id,
        c.sprint_id,
        c.created_at as added_at
    from current_field_links as c
    left join first_added as f
        on
            c.issue_id = f.issue_id
            and c.sprint_id = f.sprint_id
    where f.added_at is null
),

combined_assignments as (
    select
        issue_id,
        sprint_id,
        added_at
    from first_added
    union all
    select
        issue_id,
        sprint_id,
        added_at
    from initial_sprint_assignments
)

select
    c.issue_id,
    c.sprint_id,
    ca.added_at
from current_field_links as c
left join combined_assignments as ca
    on
        c.issue_id = ca.issue_id
        and c.sprint_id = ca.sprint_id
