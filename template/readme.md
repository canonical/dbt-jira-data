# Sample dbt project

This is a sample dbt project that can be used as a starting point for your own.
In this example, we suppose a data source named `streaming` that contains
information about the movies and TV shows on Apple TV, HBO Max, Netflix and Prime Video.

The objective is to create a model that shows the number of movies available on each
service, for each country available.
To that end, it also uses the `countries` seed, which is a static list of countries.

Go through the sub-directories in this order: `staging`, `intermediate`, `marts`.
This is very simple example, and it the project structure is "over-engineered" for
its size, but it demonstrates a structure applicable to larger projects.

One of the fundamental principles is reusability of models. For example, we could
filter out TV shows in the staging model, since here we are only interested in movies,
but if later on we want to build a model based on TV shows, we would need to modify the
existing models.
By putting the `where type = 'movie'` clause in the intermediate model, we are enabled
to create other intermediate models for TV shows.

# ❗️ Important ❗️

If you choose to use this directory as a starting point for your own project,
please ***make a copy*** of it and name it something else.
This will avoid future conflicts when updates are made from the root repository
into your fork.

## Guidelines
- Create config and sources files in each directory, as well as a documentation file
if necessary. For example:
  - `_streaming__docs.md`
  - `_streaming__models.yml`
  - `_streaming__sources.yml`
- Use `dbt_project.yml` to define defaults if necessary.
- The `models` directory is the core of the project, where all the models are stored.
- The `seeds` directory stores CSV files of static data that can be used as
sources.
- The `macros` directory stores common transformations that can be used in
multiple models.
- If you copy this directory to start your own, remember to update all instances of the
string `template` to your project name (the name of the directory) in the following files:
  - `dbt_project.yml`
  - `profiles.yml`
  - `.sqlfluff`

## References
* [How we structure our dbt projects | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)
* [The rest of the project | dbt Developer Hub](https://docs.getdbt.com/best-practices/how-we-structure/5-the-rest-of-the-project)
