export DUCKDB_VERSION=1.5.5
export ENV?=dev
export DOCKER_IMAGE=aviation-analytics
export DOCKER_CONTAINER=aviation-analytics

.PHONY: help
help:
	@awk -F ':.*# ' '/^[a-zA-Z0-9_-]+:.*# / {printf "\033[32m%-35s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: deps
deps: # Install deps (DuckDB CLI + Python packages).
	curl -LO https://github.com/duckdb/duckdb/releases/download/v$(DUCKDB_VERSION)/duckdb_cli-linux-amd64.zip
	unzip duckdb_cli-linux-amd64.zip
	sudo mv duckdb /usr/bin
	rm duckdb_cli-linux-amd64.zip
	pip install --upgrade pip setuptools wheel
	pip install -r requirements.txt

.PHONY: docker-build
docker-build: # Build the Docker image.
	docker build --platform linux/amd64 -t $(DOCKER_IMAGE) .

.PHONY: docker-up
docker-up: # Spawn the container.
	docker run -d --name $(DOCKER_CONTAINER) --platform linux/amd64 --network host -e ENV -e AIRLABS_API_KEY -v "$(PWD):/app" $(DOCKER_IMAGE) tail -f /dev/null

.PHONY: docker-it
docker-it: # Run an interactive bash console on the container.
	docker exec -it $(DOCKER_CONTAINER) bash

.PHONY: docker-down
docker-down: # Remove the container.
	docker stop $(DOCKER_CONTAINER)
	docker rm -f -v $(DOCKER_CONTAINER)

.PHONY: dlt-lint
dlt-lint: # Run linter tools on the dlt code.
	cd dlt && ruff check
	cd dlt && ruff format --exit-non-zero-on-format
	cd dlt && ty check --python $(shell which python)

.PHONY: dlt-ingest-source-data
dlt-ingest-source-data: # Ingest raw data from the AirLabs API using dlt.
	cd dlt && python ingest_aviation_data.py

.PHONY: dbt-deps
dbt-deps: # Install dbt deps (packages).
	cd dbt && dbt deps

.PHONY: dbt-lint
dbt-lint: # Run linter tools on the dbt code.
	@cd dbt && { \
		sqlfluff lint --dialect duckdb; exit_code=$$?; \
		sqlfluff fix --dialect duckdb; exit_code=$$?; \
		exit $$exit_code; \
	}

.PHONY: dbt-run
dbt-run: # Run dbt models.
	cd dbt && dbt run

.PHONY: dbt-test-unit
dbt-test-unit: # Run unit tests on dbt models.
	cd dbt && dbt test --select "test_type:unit"

.PHONY: dbt-test-data
dbt-test-data: # Run data tests on dbt models.
	cd dbt && dbt test --select "test_type:data"

.PHONY: dbt-docs-generate
dbt-docs-generate: # Generate dbt docs (to be hosted in Github Pages).
	cd dbt && dbt docs generate

.PHONY: duckdb-ui
duckdb-ui: # Run DuckDB UI.
	duckdb data/aviation.duckdb -ui

.PHONY: clean
clean: # Clean auxiliary files.
	cd dbt && dbt clean
	rm -rf dbt/logs dbt/.user.yml dlt/.ty dlt/.ruff_cache data/*.duckdb
