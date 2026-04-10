import logging
import os

import dlt
from dlt.sources.rest_api import rest_api_source
from dlt.sources.helpers.rest_client.paginators import SinglePagePaginator

logging.basicConfig(level=logging.INFO)

SOURCE_API_KEY = os.environ["AIRLABS_API_KEY"]
SOURCE_BASE_URL = "https://airlabs.co/api/v9/"
DESTINATION_DB_PATH = "../data/aviation.duckdb"


def load_aviation_data() -> None:
    pipeline = dlt.pipeline(
        pipeline_name="aviation",
        destination=dlt.destinations.duckdb(DESTINATION_DB_PATH),
        dataset_name="raw",
    )

    aviation_source = rest_api_source(
        {
            "client": {
                "base_url": SOURCE_BASE_URL,
                "paginator": SinglePagePaginator(),
            },
            "resources": [
                {
                    "name": "airlines",
                    "endpoint": {
                        "path": "airlines",
                        "params": {"api_key": SOURCE_API_KEY},
                    },
                },
                {
                    "name": "airports",
                    "endpoint": {
                        "path": "airports",
                        "params": {"api_key": SOURCE_API_KEY},
                    },
                },
                {
                    "name": "flight_positions",
                    "endpoint": {
                        "path": "flights",
                        "params": {"api_key": SOURCE_API_KEY},
                    },
                },
            ],
        }
    )

    load_info = pipeline.run(aviation_source)
    logging.info(load_info)
    logging.info(f"Loaded row counts: {pipeline.last_trace.last_normalize_info.row_counts}")


if __name__ == "__main__":
    load_aviation_data()
