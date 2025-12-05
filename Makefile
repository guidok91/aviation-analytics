.PHONY: help
help:
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: docker-up
docker-up: # Spawn containers.
	docker-compose up -d

.PHONY: docker-it-dbt
docker-it-dbt: # Run an interactive bash console on the dbt container.
	docker exec -it dbt bash

.PHONY: docker-it-dlt
docker-it-dlt: # Run an interactive bash console on the dlt container.
	docker exec -it dlt bash

.PHONY: docker-down
docker-down: # Remove containers.
	docker-compose stop
	docker-compose rm -f -v
