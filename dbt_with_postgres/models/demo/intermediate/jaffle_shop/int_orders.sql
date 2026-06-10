with orders as (
    select
        *
    from {{ ref('stg_mrg_orders') }}
    --where order_status not in ('return_paending', 'returned')
)

, payments as (
    select * from {{ ref('stg_mrg_payments')}}
)

/*
, order_totals as (
    select
        order_id,
        payment_method,
        sum(payment_amount) as order_value_dollars
    from payments
    group by order_id, payment_method
)

, order_value_joined as (
    select
        o.*,
        ot.order_value_dollars,
        ot.payment_method

    from orders o
        left join order_totals ot on o.order_id = ot.order_id
)
*/

, completed_payments as (
    select 
        orders.order_id,
        sum(payments.payment_amount) as total_amount_paid
    from payments
    join orders on payments.order_id = orders.order_id
    group by 1
)

, paid_orders as (
    select 
        orders.user_order_seq,
        orders.customer_id,
        orders.order_id,
        orders.order_date,
        orders.valid_order_date,
        orders.order_status,
        completed_payments.total_amount_paid
    from orders
        left join completed_payments on orders.order_id = completed_payments.order_id   
)

select * from paid_orders
