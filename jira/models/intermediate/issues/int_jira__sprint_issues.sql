with source as (
  select * from {{ ref('stg_jira__sprint_issues') }}
),

hist as (
  select * from {{ ref('int_jira__issue_sprint_histories') }}
),

/* Expand sprint IDs from the "to_id" field; drop those that already existed in "from_id" */
added_events as (
  select
    h.issue_id,
    cast(m as bigint)                                  as sprint_id,
    cast(h.changed_at as timestamp with time zone)     as added_at
  from hist h
  cross join unnest(regexp_extract_all(coalesce(h.to_id, ''), '(\\d+)')) as t(m)
  where not array_contains(regexp_extract_all(coalesce(h.from_id, ''), '(\\d+)'), m)
),

first_added as (
  select issue_id, sprint_id, min(added_at) as added_at
  from added_events
  group by 1, 2
),

issues as (
  select issue_id from {{ ref('int_jira__issues') }}
),

staged as (
  select
    s.issue_id,
    s.sprint_id,
    fa.added_at
  from source s
  left join first_added fa
    on fa.issue_id = s.issue_id
   and fa.sprint_id = s.sprint_id
  inner join issues i
    on i.issue_id = s.issue_id
)

select * from staged