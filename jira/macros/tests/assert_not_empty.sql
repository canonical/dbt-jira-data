{% test assert_not_empty(model) %}
select 1
where not exists (select 1 from {{ model }} limit 1)
{% endtest %}