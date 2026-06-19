-- Import CTEs
with customer_orders as (
    select * from {{ ref('int_customers') }}
)

-- Final CTE
, final as (
  select 
    order_id,
    customer_id,
    surname,
    givenname,
    customer_first_order_date as first_order_date,
    customer_order_count as order_count,
    customer_total_lifetime_value as total_lifetime_value,
    total_amount_paid as order_value_dollars,
    order_status

  from customer_orders

  --where order_status not in ('return_paending', 'returned')

)

select * from final