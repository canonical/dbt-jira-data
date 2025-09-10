with issues_base as (
  select
    i.issue_id,
    i.issue_key,
    from_iso8601_timestamp(json_extract_scalar(i.fields_json, '$.created')) as created_at
  from {{ ref('stg_jira__issues') }} i
),

histories as (
  select * from {{ ref('stg_jira__issue_histories') }}
),

/* Explode histories[].items[] */
items as (
  select
    h.issue_id,
    h.issue_key,
    from_iso8601_timestamp(json_extract_scalar(hist, '$.created')) as changed_at,
    json_extract_scalar(itm, '$.field')                            as field,
    json_extract_scalar(itm, '$.fromString')                       as from_string,
    json_extract_scalar(itm, '$.toString')                         as to_string,
    json_extract_scalar(itm, '$.from')                             as from_id,
    json_extract_scalar(itm, '$.to')                               as to_id
  from histories h
  cross join unnest(cast(json_extract(h.changelog_json, '$.histories') as array(json))) as hist
  cross join unnest(
      coalesce(
        cast(json_extract(hist, '$.items') as array(json)),
        cast(array[] as array(json))
      )
  ) as itm
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

initial_from_history as (
  /* Add a synthetic initial row if earliest change indicates a prior sprint */
  select
    ib.issue_id,
    ib.issue_key,
    ib.created_at                     as changed_at,
    cast(null as varchar)             as from_string,
    fc.from_string                    as to_string,
    cast(null as varchar)             as from_id,
    fc.from_id                        as to_id
  from issues_base ib
  join first_change fc using (issue_id)
  where coalesce(nullif(fc.from_id, ''), nullif(fc.from_string, '')) is not null
)

select * from initial_from_history
union all
select * from sprint_changes
order by issue_id, changed_at