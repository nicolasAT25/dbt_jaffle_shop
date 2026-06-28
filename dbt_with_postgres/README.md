# dbt with PostgreSQL — Jaffle Shop

A hands-on dbt project built on top of the classic [Jaffle Shop](https://github.com/dbt-labs/jaffle_shop) dataset, using **PostgreSQL** as the data warehouse. This project demonstrates a full dbt workflow: source declarations, a three-layer model architecture, custom macros, data tests, and package integrations.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Project Structure](#project-structure)
- [Model Layers](#model-layers)
- [Macros](#macros)
- [Tests](#tests)
- [Packages](#packages)
- [Setup & Usage](#setup--usage)

---

## Project Overview

| Property | Value |
|---|---|
| dbt project name | `dbt_with_postgres` |
| Adapter | PostgreSQL |
| Database | `jaffle_shop` |
| Source schema | `raw` |

The Jaffle Shop is a fictional food delivery business. The raw data contains customers, orders, and payments. This project transforms that raw data into clean, analytics-ready mart tables that answer questions like: *Which customers have the highest lifetime value?* and *What is the total revenue from completed orders?*

---

## Data Sources

Three raw tables live in the `jaffle_shop.raw` schema:

| Table | Description |
|---|---|
| `customers` | One row per customer (id, first_name, last_name) |
| `orders` | One row per order (id, user_id, order_date, status, _etl_loaded_at) |
| `payments` | One row per payment (id, order_id, payment_method, amount, _batched_at) |

Source freshness is monitored on the `orders` table — dbt warns if data is older than 6 hours and errors after 12 hours.

---

## Project Structure

```
dbt_with_postgres/
├── models/
│   ├── sources/              # Source definitions (YAML)
│   ├── staging/
│   │   ├── jaffle_shop/      # stg_customers, stg_orders
│   │   └── stripe/           # stg_payments
│   ├── intermediate/
│   │   └── jaffle_shop/      # int_orders_pivoted, int_customers_daily_summary
│   ├── marts/
│   │   ├── finance/          # fct_orders
│   │   └── marketing/        # fct_customers_orders
│   └── date_spine.sql        # Utility: date dimension
├── macros/                   # Custom macros
├── tests/                    # Custom singular tests
├── analyses/
├── seeds/
├── snapshots/
├── packages.yml
└── dbt_project.yml
```

---

## Model Layers

### Staging — `views` in schema `staging`

Light-touch cleaning and renaming on top of the raw sources. No business logic.

| Model | Source | Key transformations |
|---|---|---|
| `stg_customers` | `raw.customers` | Renames `id` → `customer_id` |
| `stg_orders` | `raw.orders` | Renames `id` → `order_id`, `user_id` → `customer_id`, `status` → `order_status` |
| `stg_payments` | `raw.payments` | Renames `id` → `payment_id`, `amount` → `payment_amount` |

### Intermediate — `tables` in schema `intermediate`

Joins and transformations that prepare data for the marts. Not intended for direct consumption by end users.

| Model | Description |
|---|---|
| `int_orders_pivoted` | Pivots payment methods (coupon, credit_card, bank_transfer, gift_card) into separate amount columns per order using a Jinja `for` loop |
| `int_customers_daily_summary` | Aggregates order counts per customer per day; generates a surrogate primary key using `dbt_utils.generate_surrogate_key` |

### Marts — `tables` in schema `marts`

Business-facing fact tables, organized by domain.

**Finance**

| Model | Description |
|---|---|
| `fct_orders` | One row per completed order with total payment amount. Joins `stg_orders` and `stg_payments`. |

**Marketing**

| Model | Description |
|---|---|
| `fct_customers_orders` | One row per customer with first/most recent order dates, total number of orders, and lifetime value. Built on top of `fct_orders`. |

### DAG overview

```
raw.customers ──► stg_customers ──────────────────────────────► fct_customers_orders
raw.orders    ──► stg_orders    ──► int_customers_daily_summary
                                ──► fct_orders ────────────────► fct_customers_orders
raw.payments  ──► stg_payments  ──► int_orders_pivoted
                                ──► fct_orders
```

### Utility models

| Model | Description |
|---|---|
| `date_spine` | A full calendar date table from 2026-01-01 to 2027-01-01, built with `dbt_utils.date_spine` |
| `unioned_tables` | Dynamically unions all tables with the prefix `orders__` in the raw schema using the custom `union_tables_by_prefix` macro |

---

## Macros

| Macro | Description |
|---|---|
| `cents_to_dollars(column_name, decimals=2)` | Converts a cents column to dollars, rounded to `decimals` places (default 2) |
| `generate_schema_name(custom_schema_name, node)` | Overrides the default dbt schema naming logic. In `dev` environments (when `DBT_ENV_NAME=dev`), all models land in the default target schema — preventing dev runs from polluting production schemas |
| `grant_select(schema, user)` | Runs `GRANT SELECT` on all tables and sequences across the four project schemas (`raw`, `jaffle_shop_staging`, `jaffle_shop_intermediate`, `jaffle_shop_marts`) for a given user/role |
| `union_tables_by_prefix(database, schema, prefix)` | Uses `dbt_utils.get_relations_by_prefix` to dynamically discover and `UNION ALL` all tables matching a prefix pattern |

---

## Tests

### Generic tests (schema YAML)

| Model | Column | Test |
|---|---|---|
| `stg_customers` | `customer_id` | `unique`, `not_null` |
| `stg_orders` | `order_id` | `unique`, `not_null` |
| `stg_orders` | `customer_id` | `relationships` → `stg_customers` |
| `stg_orders` | `order_status` | `accepted_values`: placed, shipped, completed, return_pending, returned |
| `stg_payments` | `payment_id` | `unique`, `not_null` |
| `int_customers_daily_summary` | `primary_key` | `unique`, `not_null` |
| `int_orders_pivoted` | `order_id` | `unique`, `not_null` |
| `raw.customers` | `id` | `unique`, `not_null` |
| `raw.orders` | `id` | `unique`, `not_null` |

### Custom singular tests

| Test | Description |
|---|---|
| `assert_stg_stripe_payment_total_positive` | Fails if any order in `stg_payments` has a negative total payment amount |

---

## Packages

| Package | Version | Purpose |
|---|---|---|
| [`dbt_utils`](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) | `1.3.3` | Surrogate keys, date spine, relation discovery |
| [`dbt-codegen`](https://github.com/dbt-labs/dbt-codegen) | `main` | Code generation macros (source YAML, model YAML, base models) |

---

## Setup & Usage

### Prerequisites

- Python 3.8+
- dbt-postgres installed (`pip install dbt-postgres`)
- A running PostgreSQL instance with the Jaffle Shop raw data loaded

### Configure your profile

Add the following to `~/.dbt/profiles.yml`:

```yaml
dbt_with_postgres:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: <your_user>
      password: <your_password>
      dbname: jaffle_shop
      schema: dev
      threads: 4
```

Set the required environment variable:

```bash
export DBT_ENV_NAME=dev
```

### Install packages

```bash
dbt deps
```

### Run the project

```bash
# Run all models
dbt run

# Run only staging models
dbt run --select staging

# Run a specific model and its dependencies
dbt run --select +fct_customers_orders
```

### Run tests

```bash
dbt test
```

### Check source freshness

```bash
dbt source freshness
```

### Generate and serve documentation

```bash
dbt docs generate
dbt docs serve
```

---

## Refactoring SQL for Modularity

Inside `models/demos` directory there is an example of how to migrate code from "classic" SQL to a `dbt` style. This refactoring includes:

- Save legacy code
- Implement sources
- Cosmetic cleanup (indentation, lower case consistency)
- CTE groupings
- Auditing
  - `audit_helper`
    - compare_all_columns
    - compare_row_counts
  - `custom audit`
    - discrepancies
- User-Defined Functions (UDFs)
  - Create an UDF in dbt
  - Import an UDF data platform (`Postgres`)