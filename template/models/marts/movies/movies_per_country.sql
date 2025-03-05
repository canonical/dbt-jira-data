with countries as (
    select * from {{ ref('stg_countries__countries') }}
),

netflix_movies as (
    select
        country,
        count(*) as num_movies
    from
        {{ ref('int_netflix_crossed_countries') }}
    group by country
),

final as (
    select
        countries.name as country,
        coalesce(netflix_movies.num_movies, 0) as num_netflix_movies
    from countries
    full outer join
        netflix_movies
        on countries.country_code = netflix_movies.country
)

select * from final
where num_netflix_movies > 0
