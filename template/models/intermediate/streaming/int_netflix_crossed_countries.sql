with

countries as (
    select * from {{ ref('stg_countries__countries') }}
),

movies as (
    select *
    from {{ ref('int_netflix_movies') }}
),

netflix_crossed_countries as (
    select
        m.title,
        m.id,
        m.available_countries,
        c.country_code
    from movies as m
    cross join countries as c
    where {{ dbt.position("country_code", "available_countries") }} > 0
)

select * from netflix_crossed_countries
