{% macro grant_select(schema=target.schema, user=target.user) %} -- user = role for snowflake
    {% set schema_list = ['raw', 'jaffle_shop_staging', 'jaffle_shop_intermediate', 'jaffle_shop_marts'] %}

        {% for schema in schema_list %}

            {% set sql %}
                GRANT USAGE ON SCHEMA "{{ schema }}" TO "{{ user }}";
                GRANT SELECT ON ALL TABLES IN SCHEMA "{{ schema }}" TO "{{ user }}";
                GRANT SELECT ON ALL SEQUENCES IN SCHEMA "{{ schema }}" TO "{{ user }}";
            {% endset %}

            {{ log('Granting select on all tables and sequences in schema ' ~ schema ~ ' to user ' ~ user, info=True) }}
            {% do run_query(sql) %}
            {{ log('Privileges granted', info=True) }}

        {% endfor %}

{% endmacro %}