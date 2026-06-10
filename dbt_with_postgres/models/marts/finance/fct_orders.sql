with orders as (

    select
        order_id,
        customer_id,
        order_date,
        order_status

    from {{ ref('stg_orders') }}

),

payments as (

    select
        payment_id,
        order_id,
        payment_method,
        payment_amount,
        _batched_at

    from {{ ref('stg_payments') }}

),

orders_payments as (

    select
        o.order_id,
        sum(p.payment_amount) as payment_amount

    from orders o 
        left join payments p on o.order_id = payment_id

    where o.order_status like 'completed'

    group by 1

)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    coalesce(op.payment_amount, 0) as payment_amount

from orders o
    join orders_payments op on op.order_id = o.order_id