.PHONY: help
help:
	@awk -F ':.*# ' '/^[a-zA-Z0-9_-]+:.*# / {printf "\033[32m%-35s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: docker-up
docker-up: # Spawn containers.
	docker-compose up -d

.PHONY: docker-it-dbt
docker-it-dbt: # Run an interactive bash console on the dbt container.
	docker exec -it aviation-analytics-dbt bash

.PHONY: docker-it-dlt
docker-it-dlt: # Run an interactive bash console on the dlt container.
	docker exec -it aviation-analytics-dlt bash

.PHONY: docker-down
docker-down: # Remove containers.
	docker-compose stop
	docker-compose rm -f -v
