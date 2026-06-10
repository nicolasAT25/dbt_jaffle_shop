-- mrg stands for migration

with raw_customers as (
    select * from {{ source('raw', 'customers') }}
)

, transformed_customers as (
    select 
        id as customer_id,
        first_name as givenname,
        last_name as surname,
        first_name || ' ' || last_name as full_name
      from raw_customers
)

select * from transformed_customers