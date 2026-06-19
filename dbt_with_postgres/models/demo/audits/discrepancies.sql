with legacy as (
    select
        order_id,
        order_value_dollars
    from {{ ref('customer_orders_legacy') }}
)

, refactored as (
    select
        order_id,
        order_value_dollars
    from {{ ref('fct_customer_orders') }}
)

select
    coalesce(legacy.order_id, refactored.order_id) as order_id,
    coalesce(legacy.order_value_dollars, refactored.order_value_dollars) as order_value_dollars,
    (legacy.order_id is not null) as in_legacy,
    (refactored.order_id is not null) as in_refactored
from legacy
    full outer join refactored on legacy.order_id = refactored.order_id
        and legacy.order_value_dollars = refactored.order_value_dollars
where (legacy.order_id is not null) != (refactored.order_id is not null)
order by order_id