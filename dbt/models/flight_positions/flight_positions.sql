{{ config(
    alias='flight_positions',
    unique_key=['flight_iata_code', 'event_timestamp']
) }}

SELECT
    flight_iata AS flight_iata_code,
    flag AS country_code,
    lat AS latitude,
    lng AS longitude,
    alt AS altitude_meters,
    speed AS speed_horizontal,
    v_speed AS speed_vertical,
    squawk AS squawk_signal_code,
    status AS flight_status,
    airline_iata AS airline_iata_code,
    dep_iata AS departure_airport_iata_code,
    arr_iata AS arrival_airport_iata_code,
    reg_number AS aircraft_registration_number,
    type AS aircraft_type,
    TO_TIMESTAMP(updated) AS event_timestamp,
    NOW() AS processed_timestamp
FROM
    {{ source('raw', 'flight_positions') }}
WHERE
    flight_iata_code IS NOT NULL
    AND latitude IS NOT NULL
    AND longitude IS NOT NULL
    AND _dlt_load_id::decimal = (
        SELECT MAX(_dlt_load_id::decimal)
        FROM
            {{ source('raw', 'flight_positions') }}
    )
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY flight_iata_code, event_timestamp
    ORDER BY event_timestamp DESC
) = 1
