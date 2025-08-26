with issues_base as (
  select
    i.issue_id,
    i.issue_key,
    (i.fields_json->>'created')::timestamptz          as created_at,
    (i.fields_json->'status'->>'name')                as current_status
  from {{ ref('stg_jira__issues') }} i
),

histories as (
  select
    *
  from {{ ref('stg_jira__issue_histories') }} h
),

items as (
  select
    h.issue_id,
    h.issue_key,
    (hist->>'created')::timestamptz      as changed_at,
    itm->>'field'                        as field,
    itm->>'fromString'                   as from_status,
    itm->>'toString'                     as to_status
  from histories h
  cross join lateral jsonb_array_elements(h.changelog_json->'histories') as hist
  cross join lateral jsonb_array_elements(coalesce(hist->'items','[]'::jsonb)) as itm
),

status_changes as (
  select
    issue_id,
    issue_key,
    changed_at,
    from_status,
    to_status
  from items
  where lower(field) = 'status'
    and (from_status is distinct from to_status)
),

-- Earliest status change per issue (to infer initial status if available)
first_change as (
  select issue_id, issue_key, from_status, changed_at
  from (
    select
      sc.*,
      row_number() over (partition by sc.issue_id order by sc.changed_at asc) as rn
    from status_changes sc
  ) t
  where rn = 1
),

-- Synthesize the initial status row per issue
initial_rows as (
  select
    ib.issue_id,
    ib.issue_key,
    ib.created_at                          as changed_at,
    cast(null as text)                     as from_status,
    coalesce(fc.from_status, ib.current_status) as to_status
  from issues_base ib
  left join first_change fc using (issue_id)
)

-- Final result: initial row + all actual changes
select * from initial_rows
union all
select * from status_changes
