SELECT
    id AS payment_id
    , order_id
    , payment_method
    , amount as payment_amount
    , _batched_at

FROM {{ source('raw', 'payments') }}
--FROM jaffle_shop.raw.payments