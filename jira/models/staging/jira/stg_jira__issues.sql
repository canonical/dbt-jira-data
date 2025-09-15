with

source as (
    select * from {{ source('jira', 'issues') }}
),

staged as (
    select
        key as issue_key,
        fields as fields_json,
        created,
        updated,
        "projectKey" as project_key,
        CAST(id as BIGINT) as issue_id
    from source
)

select *
from staged
where project_key = 'JUJU'
/* where project_key in (
    'KE', 'SNAPDENG', 'KRNS', 'MIRENG', 'ROBENG',
    'C3', 'ZAP', 'CHECKBOX', 'RTW', 'LM', 'CERTTF',
    'IQA', 'SQT', 'IENG', 'AC', 'WD',
    'TORENG', 'DPUENG', 'RTOS', 'JUJU', 'KU', 'MAASENG'
) */
