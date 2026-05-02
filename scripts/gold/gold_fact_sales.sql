-- ====================================================================
-- Data Integration: Building Fact Table - gold.fact_sales
-- ====================================================================
-- Master Source: silver.crm_sales_details (csd)
-- JOINs to dimension tables to replace source IDs with surrogate keys:
--   sls_prd_key → product_key  (from gold.dim_products)
--   sls_cust_id → customer_key (from gold.dim_customers)
-- Columns renamed to user-friendly names and reorganised:
--   1. Keys & IDs first (order_number, product_key, customer_key)
--   2. Date columns (order_date, shipping_date, due_date)
--   3. Measures last (sales_amount, quantity, price)
-- =====================================================================
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
csd.sls_ord_num AS order_number,
dp.product_key, -- replaces csd.sls_prd_key
dc.customer_key, -- replaces csd.sls_cust_id
csd.sls_order_dt AS order_date,
csd.sls_ship_dt AS shipping_date,
csd.sls_due_dt AS due_date,
csd.sls_sales AS sales_amount,
csd.sls_quantity AS quantity,
csd.sls_price AS price
FROM silver.crm_sales_details csd
LEFT JOIN gold.dim_products dp
ON csd.sls_prd_key = dp.product_number -- to get to the surrogated key 
LEFT JOIN gold.dim_customers dc
ON csd.sls_cust_id = dc.customer_id -- to get to the surrogated key

