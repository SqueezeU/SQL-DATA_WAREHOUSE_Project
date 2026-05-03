/*
======================================================
QA Script: Silver Layer - crm_sales_details
======================================================
Script Purpose:
    Verifies that the transformation and cleansing
    applied in Transformation_Cleansing_sales.sql
    produced clean data in the silver layer.
======================================================
*/

-- QA check sales table
-- basic general check
SELECT 
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
-- we need to check whether we can use the first 3 columns to join other tables

-- STEP 1
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != Trim(sls_ord_num)

-- STEP 2
-- Integrity Check for column 2 and 3 as we need to join them with other tables
-- Expectation: No Results

SELECT * FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT * FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- STEP 3
-- check for Invalid Dates
-- Expectation: No Result
-- dates have been converted from INT to DATE in Transformation

SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL 
   OR sls_ship_dt IS NULL 
   OR sls_due_dt IS NULL

-- STEP 4
-- check for Invalid Date Orders
-- Expectation: No Result
-- Business Rule: Order Date must always be earlier than Ship Date and Due Date

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
-- no issues - Business Rule confirmed

-- STEP 5
-- Check Data Consistency: Between Sales, Quantity, and Price
-- Business Rules:
-- >> Sales = Quantity * Price
-- >> Values must not be NULL, zero, or negative
-- Expectation: No Result

SELECT DISTINCT -- DISTINCT to show unique error patterns only, not every single row
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price 
-- ORDER BY to group error types: NULLs first, then negatives, then zeros