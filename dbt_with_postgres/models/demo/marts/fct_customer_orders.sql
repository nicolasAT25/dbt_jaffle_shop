-- Import CTEs
with customer_orders as (
    select * from {{ ref('int_customers') }}
)

-----------------------
/*
, customer_order_history as (

    select 
        customers.customer_id,
        customers.full_name,
        customers.surname,
        customers.givenname,
        min(orders.order_date) as first_order_date,
        min(orders.valid_order_date) as first_non_returned_order_date,
        max(orders.valid_order_date) as most_recent_non_returned_order_date,
        coalesce(max(orders.user_order_seq),0) as order_count,
        --coalesce(count(case when orders.order_status is not null then 1 end),0) as non_null_order_count,
        --sum(case when orders.order_status is not null then orders.total_amount_paid else 0 end) as total_lifetime_value,
        coalesce(count(case when orders.order_status not in ('returned','return_pending') then 1 end),0) as non_returned_order_count,
        sum(case when orders.order_status not in ('returned','return_pending') then orders.total_amount_paid else 0 end) as total_lifetime_value,
        
        sum(
            case
                when orders.order_status is not null
                then orders.total_amount_paid
                else 0
            end) / 
            nullif(count(
                        case
                            when orders.order_status is not null
                            then 1
                        end
                        ),
                    0) as avg_non_null_order_value,
        
        sum(
            case
                when orders.order_status not in ('returned','return_pending')
                then orders.total_amount_paid
                else 0
            end) / 
            nullif(count(
                        case
                            when orders.order_status not in ('returned','return_pending')
                            then 1
                        end
                        ),
                    0) as avg_non_returned_order_value,

        array_agg(distinct orders.order_id) as order_ids

    from orders

    join customers on orders.customer_id = customers.customer_id

    group by customers.customer_id, customers.full_name, customers.surname, customers.givenname

)
*/

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
    total_amount_paid,
    order_status

  from add_avg_order_values

)

select * from final

/*
-- Final CTE
, final as (
    select 
        orders.customer_id,
        orders.order_id,
        customer_order_history.order_ids,
        customers.surname,
        customers.givenname,
        customers.full_name,
        customer_order_history.first_order_date,
        orders.order_status,
        customer_order_history.first_non_returned_order_date,
        customer_order_history.most_recent_non_returned_order_date,
        --orders.valid_order_date,
        customer_order_history.non_returned_order_count,
        customer_order_history.order_count,
        customer_order_history.total_lifetime_value,
        customer_order_history.avg_non_returned_order_value,
        orders.total_amount_paid

    from orders as orders

    join customers on orders.customer_id = customers.customer_id

    join customer_order_history on orders.customer_id = customer_order_history.customer_id
)

-- Final SELECT
select * from final
*/