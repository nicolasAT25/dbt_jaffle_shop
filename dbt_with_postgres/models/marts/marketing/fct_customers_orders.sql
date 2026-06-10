with customers as (

    select
        customer_id,
        first_name,
        last_name

    from {{ ref('stg_customers') }}

),

orders as (

    select
        order_id,
        customer_id,
        order_date,
        payment_amount

    from {{ ref('fct_orders') }}

),

customer_orders as (

    select
        customer_id,

        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(DISTINCT order_id) as number_of_orders,
        sum(payment_amount) as lifetime_value

    from orders

    group by 1

)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    co.first_order_date,
    co.most_recent_order_date,
    coalesce(co.number_of_orders, 0) as number_of_orders,
    coalesce(co.lifetime_value, 0) as lifetime_value

from customers c
    left join customer_orders co using (customer_id)