ALTER TABLE jaffle_shop.orders 
ADD COLUMN _etl_loaded_at timestamp DEFAULT now();

ALTER TABLE jaffle_shop.orders 
DROP COLUMN _etl_loaded_at;

-- ALTER TABLE raw.jaffle_shop.orders ALTER COLUMN _etl_loaded_at DROP DEFAULT;

select * from jaffle_shop.orders;

-------------------

ALTER TABLE stripe.payments 
ADD COLUMN _batched_at timestamp DEFAULT now();

ALTER TABLE stripe.payments  
DROP COLUMN _batched_at;