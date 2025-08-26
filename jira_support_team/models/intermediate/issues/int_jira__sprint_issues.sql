with source as (
    select * from {{ ref('stg_jira__sprint_issues') }}
),
hist as (
  select * from {{ ref('int_jira__issue_sprint_histories') }}
),
added_events as (
  select
    h.issue_id,
    (to_m.m[1])::bigint          as sprint_id,
    (h.changed_at)::timestamptz  as added_at
  from hist h
  cross join lateral regexp_matches(coalesce(h.to_id, ''), '(\d+)', 'g') as to_m(m)
  left join lateral (
    select 1
    from regexp_matches(coalesce(h.from_id, ''), '(\d+)', 'g') as fm(m)
    where fm.m[1] = to_m.m[1]
    limit 1
  ) in_from on true
  where in_from is null
),
first_added as (
  select
    issue_id,
    sprint_id,
    min(added_at) as added_at
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
