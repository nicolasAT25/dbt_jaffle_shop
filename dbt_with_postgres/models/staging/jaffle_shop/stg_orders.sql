SELECT
    id AS order_id
    , user_id AS customer_id
    , order_date
    , status as order_status
    , _etl_loaded_at

FROM {{ source('raw', 'orders') }}
--FROM jaffle_shop.raw.orders