{{ config(
    alias='airlines',
    unique_key=['iata_code']
) }}

SELECT
    iata_code,
    name,
    NOW() AS processed_timestamp
FROM
    {{ source('raw', 'airlines') }}
WHERE
    iata_code IS NOT NULL
    AND _dlt_load_id::decimal = (
        SELECT MAX(_dlt_load_id::decimal)
        FROM
            {{ source('raw', 'airlines') }}
    )
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY iata_code
    ORDER BY name
) = 1
