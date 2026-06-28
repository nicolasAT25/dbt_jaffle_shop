with legacy as (
    select
        order_id,
        order_value_dollars,
        order_status
    from {{ ref('customer_orders_legacy') }}
)

, refactored as (
    select
        order_id,
        order_value_dollars,
        order_status
    from {{ ref('fct_customer_orders') }}
)

select
    legacy.order_id as order_id_legacy,
    refactored.order_id as order_id_refactored,
    legacy.order_value_dollars as order_value_dollars_legacy,
    refactored.order_value_dollars as order_value_dollars_refactored,
    legacy.order_status as order_status_legacy,
    refactored.order_status as order_status_refactored,
    coalesce(legacy.order_id, refactored.order_id) as order_id,
    coalesce(legacy.order_value_dollars, refactored.order_value_dollars) as order_value_dollars,
    coalesce(legacy.order_status, refactored.order_status) as order_status,
    (legacy.order_id is not null) as in_legacy,
    (refactored.order_id is not null) as in_refactored
from legacy
    full outer join refactored on legacy.order_id = refactored.order_id
        and legacy.order_value_dollars = refactored.order_value_dollars
where (legacy.order_id is not null) != (refactored.order_id is not null)
order by order_id