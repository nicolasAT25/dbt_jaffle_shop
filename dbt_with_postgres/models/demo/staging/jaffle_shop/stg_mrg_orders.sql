-- mrg stands for migration

with raw_orders as (
    select * from {{ source('raw', 'orders') }}
)

, transformed_orders as (
    select
        row_number() over (
            partition by user_id 
            order by order_date, id
            ) as user_order_seq,
        id as order_id,
        user_id as customer_id,
        order_date,

        case    
            when status not in ('returned','return_pending')
            then order_date
        end as valid_order_date,
        
        status as order_status,
        _etl_loaded_at
    from raw_orders
)

select * from transformed_orders