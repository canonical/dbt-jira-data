with netflix_countries as (
    select * from {{ ref('netflix_countries') }}
),

netflix_movies as (
    select
        imdbId as id,
        "netflix" as source,
        title,
        country_code as country
    from netflix_countries
)

select * from netflix_movies
