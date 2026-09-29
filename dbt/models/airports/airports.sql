{{ config(
    alias='airports',
    unique_key=['iata_code']
) }}

SELECT
    iata_code,
    name,
    lat AS latitude,
    lng AS longitude,
    country_code,
    NOW() AS processed_timestamp
FROM
    {{ source('raw', 'airports') }}
WHERE
    iata_code IS NOT NULL
    AND _dlt_load_id::decimal = (
        SELECT MAX(_dlt_load_id::decimal)
        FROM
            {{ source('raw', 'airports') }}
    )
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY iata_code
    ORDER BY name
) = 1
