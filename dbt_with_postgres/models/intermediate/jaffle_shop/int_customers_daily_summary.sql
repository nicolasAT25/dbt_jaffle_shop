SELECT
    customer_id
    , order_date
    , {{ dbt_utils.generate_surrogate_key(['customer_id', 'order_date']) }} AS primary_key
    , COUNT(order_id) AS count_orders
FROM {{ ref('stg_orders') }}
GROUP BY 1,2