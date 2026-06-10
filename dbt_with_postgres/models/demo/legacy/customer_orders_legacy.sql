select 
    orders.id as order_id,
    orders.user_id as customer_id,
    customers.last_name as surname,
    customers.first_name as givenname,
    first_order_date,
    order_count,
    customer_order_history.total_lifetime_value,
    payments.amount as order_value_dollars,
    orders.status as order_status

from {{ source('raw', 'orders') }} as orders

join (
    select * from {{ source('raw', 'payments') }}
) payments on orders.id = payments.order_id

join (
      select 
        first_name || ' ' || last_name as name, 
        * 
      from {{ source('raw', 'customers') }}
) customers on orders.user_id = customers.id

join (

    select 
      b.id as customer_id,
      b.name as full_name,
      b.last_name as surname,
      b.first_name as givenname,
      min(order_date) as first_order_date,
      min(case when a.status NOT IN ('returned','return_pending') then order_date end) as first_non_returned_order_date,
      max(case when a.status NOT IN ('returned','return_pending') then order_date end) as most_recent_non_returned_order_date,
      COALESCE(max(user_order_seq),0) as order_count,
      COALESCE(count(case when a.status != 'returned' then 1 end),0) as non_returned_order_count,
      sum(case when a.status NOT IN ('returned','return_pending') then c.amount else 0 end) as total_lifetime_value,
      sum(case when a.status NOT IN ('returned','return_pending') then c.amount else 0 end)/NULLIF(count(case when a.status NOT IN ('returned','return_pending') then 1 end),0) as avg_non_returned_order_value,
      array_agg(distinct a.id) as order_ids

    from (
      select 
        row_number() over (partition by user_id order by order_date, id) as user_order_seq,
        *
      from {{ source('raw', 'orders') }}
    ) a

    join ( 
      select 
        first_name || ' ' || last_name as name, 
        * 
      from {{ source('raw', 'customers') }}
    ) b on a.user_id = b.id

    left outer join {{ source('raw', 'payments') }} c on a.id = c.order_id

        --where a.status NOT IN ('pending') and c.status != 'fail'

        group by b.id, b.name, b.last_name, b.first_name

) customer_order_history on orders.user_id = customer_order_history.customer_id

--left outer join {{ source('raw', 'payments') }} payments on orders.id = payments.order_id

    --where payments.status != 'fail'