-- Import CTEs
with customers as (
    select * from {{ ref('stg_mrg_customers') }}
)

, orders as (
    select
        *
    from {{ ref('int_orders') }}
    --where order_status not in ('return_pending', 'returned')
)

-----------------------

, customer_orders as (
  select 
    orders.*,
    customers.full_name,
    customers.surname,
    customers.givenname,

    --- Customer level aggregations
    min(orders.order_date) over(
      partition by orders.customer_id
    ) as customer_first_order_date,

    min(orders.valid_order_date) over(
      partition by orders.customer_id
    ) as customer_first_non_returned_order_date,

    max(orders.valid_order_date) over(
      partition by orders.customer_id
    ) as customer_most_recent_non_returned_order_date,

    count(*) over(
      partition by orders.customer_id
    ) as customer_order_count,

    coalesce(count(case when orders.order_status not in ('returned') then 1 end) over(partition by orders.customer_id),1) as customer_non_returned_order_count,
    /*sum(nvl2(orders.valid_order_date, 1, 0)) over(
      partition by orders.customer_id
    ) as customer_non_returned_order_count,*/

    sum(case when orders.order_status not in ('returned','return_pending') then orders.total_amount_paid else 0 end) over(partition by orders.customer_id) as customer_total_lifetime_value,
    /*sum(nvl2(orders.valid_order_date, orders.total_amount_paid, 0)) over(
      partition by orders.customer_id
    ) as customer_total_lifetime_value,*/

    array_agg(orders.order_id) over(
      partition by orders.customer_id
    ) as customer_order_ids

  from orders
  inner join customers
    on orders.customer_id = customers.customer_id

  where orders.order_status not in ('return_paending', 'returned')
)

, average_customer_order_totals as (
    select
        customer_orders.*,
        customer_orders.customer_total_lifetime_value / customer_non_returned_order_count as avg_non_returned_order_value
    from customer_orders
)

select * from average_customer_order_totals