SELECT
    id AS customer_id
    , first_name
    , last_name

FROM {{ source('raw', 'customers') }}
--FROM jaffle_shop.raw.customers