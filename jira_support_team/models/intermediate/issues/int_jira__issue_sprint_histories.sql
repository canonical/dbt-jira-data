with issues_base as (
  select
    i.issue_id,
    i.issue_key,
    (i.fields_json->>'created')::timestamptz as created_at
  from {{ ref('stg_jira__issues') }} i
),

histories as (
  select *
  from {{ ref('stg_jira__issue_histories') }}
),

items as (
  select
    h.issue_id,
    h.issue_key,
    (hist->>'created')::timestamptz as changed_at,
    itm->>'field'                    as field,
    itm->>'fromString'               as from_string,
    itm->>'toString'                 as to_string,
    itm->>'from'                     as from_id,
    itm->>'to'                       as to_id
  from histories h
  cross join lateral jsonb_array_elements(h.changelog_json->'histories') as hist
  cross join lateral jsonb_array_elements(coalesce(hist->'items','[]'::jsonb)) as itm
),

sprint_changes as (
  select
    issue_id, issue_key, changed_at, from_string, to_string, from_id, to_id
  from items
  where lower(field) = 'sprint'
),

first_change as (
  select issue_id, issue_key, from_string, from_id
  from (
    select
      sc.*,
      row_number() over (partition by sc.issue_id order by sc.changed_at asc) as rn
    from sprint_changes sc
  ) t
  where rn = 1
),

-- Initial row only if the earliest sprint change has a non-empty FROM (issue already had a sprint at creation)
initial_from_history as (
  select
    ib.issue_id,
    ib.issue_key,
    ib.created_at             as changed_at,
    cast(null as text)        as from_string,
    fc.from_string            as to_string,
    cast(null as text)        as from_id,
    fc.from_id                as to_id
  from issues_base ib
  join first_change fc using (issue_id)
  where coalesce(nullif(fc.from_id, ''), nullif(fc.from_string, '')) is not null
)

select * from initial_from_history
union all
select * from sprint_changes
order by issue_id, changed_at
