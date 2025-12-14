# Aviation analytics with DuckDB, dbt and dlt using AirLabs data
![workflow](https://github.com/guidok91/duckdb-dbt/actions/workflows/ci-cd.yml/badge.svg)

Aviation analytics project with [DuckDB](https://duckdb.org/), [dbt](https://docs.getdbt.com/docs/introduction) and [dlt](https://dlthub.com/) using the data from [AirLabs API](https://airlabs.co).

## Data Architecture
![data architecture](https://github.com/user-attachments/assets/0c834008-3c91-4227-a950-879684dd9010)

Datasets are ingested as snapshots from the source API.  
When loading to the curated tables, they are processed with a `merge` strategy (using a unique key per dataset).  
This preserves the latest version of each record to keep it simple on the querying side.

## Running instructions
Run `make help` to see available commands together with their description.

### Spin up Docker containers
Build and spin up Docker containers needed for the app:
- `make docker-up`

### Ingest source data from AirLabs REST API to DuckDB using dlt
Get into the dlt container:
- `make docker-it-dlt`

For this step we first need to generate an AirLabs API key (see how to on their website), and set the environment variable `AIRLABS_API_KEY`. Then run:
- `make dlt-ingest-source-data`

### Run dbt models to transform and curate the data
Exit the dlt container and get into the dbt one by running `make docker-it-dbt`. Then:
- `make dbt-deps`
- `make dbt-run`

## Data exploration with the DuckDB UI
Once the models have been run and the data is ready, you can start exploring the data.

Run `make duckdb-ui` to lauch the DuckDB UI and access it via http://localhost:4213.

Example queries:

### Countries with the highest number of airports
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

### Current number of flights by status
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

![data exploration](https://github.com/user-attachments/assets/a1caa51b-de60-40ed-bdb5-c85857fe299d)

## Dependency management
Dependabot is configured to periodically upgrade repo dependencies. See [dependabot.yml](.github/dependabot.yml).

## CI/CD
A Github Actions CI/CD pipeline that runs the models, tests and code linting is defined [here](.github/workflows) and can be seen [here](https://github.com/guidok91/duckdb-dbt/actions).

Note that the `AIRLABS_API_KEY` is provided as a Github repository secret to be used in the CI/CD pipeline.
