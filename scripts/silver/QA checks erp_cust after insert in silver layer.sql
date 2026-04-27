/*
======================================================
QA Script: Silver Layer - erp_cust_az12
======================================================
Script Purpose:
    Verifies that the transformation and cleansing
    applied in Transformation_Cleansing_erp_cust.sql
    produced clean data in the silver layer.
======================================================
*/

-- basic general check
SELECT
    cid,
    bdate,
    gen
FROM silver.erp_cust_az12

-- STEP 1
-- Integrity Check: cid should now match cst_key in silver.crm_cust_info
-- Expectation: No Result

SELECT * FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- STEP 2
-- Identify Out-of-Range Dates
-- bdate < 1924-01-01 → kept as is (decision by table owners)
-- bdate > GETDATE() → set to NULL in Transformation
-- Expectation: No Result - future dates have been set to NULL

SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

-- STEP 3
-- DATA Standardization & Consistency
-- Expectation: only Female, Male, n/a

SELECT DISTINCT gen
FROM silver.erp_cust_az12