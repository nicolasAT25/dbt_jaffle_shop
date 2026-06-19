------------------------------------------------
-- Compare Row Counts
------------------------------------------------
{% set old_relation = adapter.get_relation(
      database = "jaffle_shop",
      schema = "legacy",
      identifier = "customer_orders_legacy"
) -%}

{% set dbt_relation = ref('fct_customer_orders') %}

{{ audit_helper.compare_row_counts(
    a_relation = old_relation,
    b_relation = dbt_relation
) }}

-- Legacy : 111
-- Refactored : 95