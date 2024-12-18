with amazon_countries as (
    select * from {{ ref('amazon_countries') }}
),

amazon_movies as (
    select
        imdbId as id,
        "prime_video" as source,
        title,
        country_code as country
    from amazon_countries
)

select * from amazon_movies
