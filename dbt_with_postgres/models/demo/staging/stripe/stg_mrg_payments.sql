-- mrg stands for migration

with raw_payments as (
    select * from {{ source('raw', 'payments') }}
)

, transformed_payments as (
    select
        id AS payment_id,
        order_id,
        payment_method,
        amount as payment_amount,
        _batched_at
    from raw_payments
)

select * from transformed_payments