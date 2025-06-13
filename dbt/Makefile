DUCKDB_VERSION=1.3.0

.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: deps
deps: # Install deps.
	curl -LO https://github.com/duckdb/duckdb/releases/download/v$(DUCKDB_VERSION)/duckdb_cli-linux-amd64.zip
	unzip duckdb_cli-linux-amd64.zip
	sudo mv duckdb /usr/bin
	rm duckdb_cli-linux-amd64.zip
	pip install --upgrade pip setuptools wheel
	pip install -r requirements.txt

.PHONY: duckdb
duckdb: # Run DuckDB console.
	duckdb /data/aviation.duckdb

.PHONY: lint
lint: # Run code linter tools.
	@{ \
		sqlfluff lint --dialect duckdb; exit_code=$$?; \
		sqlfluff fix --dialect duckdb; exit_code=$$?; \
		exit $$exit_code; \
	}

.PHONY: dbt-deps
dbt-deps: # Install dbt deps (packages).
	dbt deps

.PHONY: dbt-run
dbt-run: # Run dbt models.
	dbt run

.PHONY: dbt-test-unit
dbt-test-unit: # Run unit tests on dbt models.
	dbt test --select "test_type:unit"

.PHONY: dbt-test-data
dbt-test-data: # Run data tests on dbt models.
	dbt test --select "test_type:data"

.PHONY: clean
clean: # Clean auxiliary files.
	dbt clean
	rm -rf logs .user.yml /data/*.duckdb
