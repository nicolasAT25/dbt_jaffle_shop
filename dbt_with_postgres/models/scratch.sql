
Name:       {{ target.name }}
User:       {{ target.user }}
DB name:    {{ target.dbname }}
Host:       {{ target.host }}
Port:       {{ target.port }}
Type:       {{ target.type }}


{% set schema_query %}
    SELECT schema_name 
    FROM information_schema.schemata
    WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
{% endset %}

{% set results = run_query(schema_query) %}


{% if execute %}
    {% set schema_list = results.columns[0].values() %}
    {%- for schema in schema_list -%}
        {{ log("Found schema: " + schema, info=True) }}
    {% endfor %}
{% endif %}
