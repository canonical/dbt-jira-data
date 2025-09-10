with issues_base as (
  select
    i.issue_id,
    i.issue_key,
    from_iso8601_timestamp(json_extract_scalar(i.fields_json, '$.created')) as created_at,
    json_extract_scalar(i.fields_json, '$.status.name')                     as current_status
  from {{ ref('stg_jira__issues') }} i
),

histories as (
  select * from {{ ref('stg_jira__issue_histories') }} h
),

items as (
  select
    h.issue_id,
    h.issue_key,
    from_iso8601_timestamp(json_extract_scalar(hh.hist, '$.created')) as changed_at,
    json_extract_scalar(ii.itm, '$.field')                            as field,
    json_extract_scalar(ii.itm, '$.fromString')                       as from_status,
    json_extract_scalar(ii.itm, '$.toString')                         as to_status
  from histories h
  cross join unnest(
    cast(json_extract(h.changelog_json, '$.histories') as array(json))
  ) as hh(hist)
  cross join unnest(
      coalesce(
        cast(json_extract(hh.hist, '$.items') as array(json)),
        cast(array[] as array(json))
      )
  ) as ii(itm)
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

initial_rows as (
  select
    issue_id,                        
    ib.issue_key,
    ib.created_at                               as changed_at,
    cast(null as varchar)                       as from_status,
    coalesce(fc.from_status, ib.current_status) as to_status
  from issues_base ib
  left join first_change fc using (issue_id)
)


select * from initial_rows
union all
select * from status_changes
