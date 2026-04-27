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
FROM bronze.crm_sales_details
-- as we have no Primary Key we don´t need to check for NULLs and duplicates in the first three
-- columns, but we need to check whether we can use them to join other tables

-- STEP 1
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != Trim(sls_ord_num)

-- STEP 2
-- Integrity Check for column 2 and 3 as we need to join them with other tables
-- Expectation: No Results

SELECT * FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

SELECT * FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)

-- Results first 3 columns as expected - no issues and useable, so perfect

-- STEP 3
-- check for Invalid Dates
-- next 3 columns are actually DATE but they are saved like INT
-- we have to check the columns carefully

SELECT
sls_order_dt
FROM bronze.crm_sales_details
-- WHERE sls_order_dt < 0 -- Result ok no issues
WHERE sls_order_dt <= 0
-- a few 0 that´s bad as 0 or negative numbers we can´t transform into DATE
-- so we need first make those 0 to a NULL using NULLIF

-- Brainstorm: testing NULLIF to handle invalid dates
-- NULLIF(sls_order_dt, 0) converts 0 to NULL before CAST to DATE
-- invalid dates are: 0, negative, LEN != 8, or outside boundary 19000101 - 20500101
SELECT
NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
OR LEN(sls_order_dt) != 8 
OR sls_order_dt > 20500101 
OR sls_order_dt < 19000101
-- Result: NULLs - confirms NULLIF works as expected
-- same check applies to sls_ship_dt and sls_due_dt
-- solution for all three date columns will be applied in Transformation & Cleansing_sales

-- STEP 4
-- check for Invalid Date Orders
-- Expectation: No Result
-- Business Rule: Order Date must always be earlier than Ship Date and Due Date

SELECT *
FROM bronze.crm_sales_details
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
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price 
-- ORDER BY to group error types: NULLs first, then negatives, then zeros

-- Results show NULLs, negatives and zeros in sls_sales and sls_price
-- Following Business Rules have been agreed with table owners:
-- >> If Sales is NULL, zero, or negative → derive from Quantity * Price
-- >> If Price is NULL or zero → derive from Sales / Quantity
-- >> If Price is negative → convert to positive using ABS()
-- Solution will be applied in Transformation & Cleansing_sales

-- BRAINSTORMING ONLY - not part of QA check
-- testing the transformation logic before moving to Transformation & Cleansing_sales
SELECT DISTINCT
    sls_quantity,
    sls_sales AS old_sls_sales,
    CASE
        WHEN sls_sales IS NULL
          OR sls_sales <= 0
          OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_price IS NULL
          OR sls_price = 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price
FROM bronze.crm_sales_details

-- Code Explanation:

-- DISTINCT returns each value combination only once
--
-- CASE 1: Fix sls_sales
-- IF sales is NULL, zero, negative, or does not match quantity * price
-- THEN derive sales from quantity * price (ABS ensures price is positive)
-- ELSE keep the original sales value
-- stored as sls_sales (original value kept as old_sls_sales for reference)
--
-- CASE 2: Fix sls_price
-- IF price is NULL or zero
-- THEN derive price from sales / quantity
--      NULLIF(sls_quantity, 0) prevents division by zero by converting 0 to NULL
-- ELSE keep the original price value but convert to positive using ABS
--      this also handles Rule 3: negative prices are converted to positive
-- stored as sls_price (original value kept as old_sls_price for reference)