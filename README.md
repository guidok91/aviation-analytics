# Aviation analytics with DuckDB, dbt, dlt and Metabase, using AirLabs data
![workflow](https://github.com/guidok91/duckdb-dbt/actions/workflows/ci-cd.yml/badge.svg)

Aviation analytics project with [DuckDB](https://duckdb.org/), [dbt](https://docs.getdbt.com/docs/introduction), [dlt](https://dlthub.com/) and [Metabase](https://www.metabase.com/) using the data from [AirLabs API](https://airlabs.co).

## Data Architecture
![data architecture](https://github.com/user-attachments/assets/13ef8d33-10af-463d-a947-a75a17e2373e)

Datasets are ingested as snapshots from the source API.  
When loading to the curated tables, they are processed with a `merge` strategy (using a unique key per dataset).  
This preserves the latest version of each record to keep it simple on the querying side.

## Running instructions
Run `make help` to see available commands together with their description.

### Spin up Docker containers
Build and spin up Docker containers needed for the app:
- `make docker-build`
- `make docker-up`

Get into the dlt container:
- `make docker-it-dlt`

### Ingest source data from AirLabs REST API to DuckDB using dlt
For this step we first need to generate an AirLabs API key (see how to on their website), and set the environment variable `AIRLABS_API_KEY`. Then run:
- `make dlt-ingest-source-data`

### Run dbt models to transform and curate the data
Exit the dlt container and get into the dbt one by running `make docker-it-dbt`. Then:
- `make dbt-deps`
- `make dbt-run`

## Data exploration
Once the models have been run and the data is ready, you can start exploring the data.

### Using the DuckDB UI
Run `make duckdb-ui` to lauch the DuckDB UI and access it via http://localhost:4213.

Example queries:

#### Countries with the highest number of airports
```sql
SELECT
    country_code,
    COUNT(*)
FROM
    curated.airports
GROUP BY
    country_code
ORDER BY
    count(*) DESC
LIMIT 10;
```

#### Current number of flights by status
```sql
SELECT
    flight_status,
    COUNT(*)
FROM
    curated.flight_positions
WHERE
    processed_timestamp = (SELECT MAX(processed_timestamp) FROM curated.flight_positions)
GROUP BY
    ALL
ORDER BY
    COUNT(*) DESC;
```

### Using Metabase
Go to http://localhost:3000 to use the Metabase UI. There you can connect to the DuckDB database and explore the data.

When prompted for the database file, use `/data/aviation.duckdb`.

Example of a dashboard:

<img width="1000" alt="image" src="https://github.com/guidok91/duckdb-dbt-metabase/assets/38698125/b90e8caa-f497-4917-b6c3-9e86aaaa83f9">

## Dependency management
Dependabot is configured to periodically upgrade repo dependencies. See [dependabot.yml](.github/dependabot.yml).

## CI/CD
A Github Actions CI/CD pipeline that runs the models, tests and code linting is defined [here](.github/workflows) and can be seen [here](https://github.com/guidok91/duckdb-dbt/actions).

Note that the `AIRLABS_API_KEY` is provided as a Github repository secret to be used in the CI/CD pipeline.
