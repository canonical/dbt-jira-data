with countries as (
    select * from {{ ref('countries') }}
),

apple_movies as (
    select
      country,
      count(*) as num_movies
    from
      {{ ref('apple_movies') }}
    group by country
),

amazon_movies as (
    select
      country,
      count(*) as num_movies
    from
      {{ ref('amazon_movies') }}
    group by country
),

netflix_movies as (
    select
      country,
      count(*) as num_movies
    from
      {{ ref('netflix_movies') }}
    group by country
),

hbo_movies as (
    select
      country,
      count(*) as num_movies
    from
      {{ ref('hbo_movies') }}
    group by country
),

final as (
    select
        ifnull(apple_movies.num_movies, 0) as num_apple_movies,
        ifnull(amazon_movies.num_movies, 0) as num_amazon_movies,
        ifnull(netflix_movies.num_movies, 0) as num_netflix_movies,
        ifnull(hbo_movies.num_movies, 0) as num_hbo_movies,
        countries.name as country
    from countries
    full outer join apple_movies on countries.country_code = apple_movies.country
    full outer join amazon_movies on countries.country_code = amazon_movies.country
    full outer join netflix_movies on countries.country_code = netflix_movies.country
    full outer join hbo_movies on countries.country_code = hbo_movies.country
)

select * from final
where num_apple_movies > 0 or num_amazon_movies > 0 or num_netflix_movies > 0 or num_hbo_movies > 0
