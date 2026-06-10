with payments as (
    select *
    from {{ ref('stg_payments') }}
)

, pivoted as (
    select
        order_id,
        {%- set payment_methods = ['coupon', 'credit_card', 'bank_transfer', 'gift_card'] -%}

        {% for payment in payment_methods %}
            sum(case when payment_method = '{{ payment }}' then payment_amount else 0 end) as {{ payment }}_amount
            {%- if not loop.last -%}
                ,
            {% endif %}
        {% endfor %}
    
    from payments
    group by 1
)

select * from pivoted

