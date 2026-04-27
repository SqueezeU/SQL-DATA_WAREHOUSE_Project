/*
======================================================
QA Script: Silver Layer - crm_prd_info
======================================================
Script Purpose:
    Verifies that the transformation and cleansing
    applied in Transformation_Cleansing_prd.sql
    produced clean data in the silver layer.
======================================================
*/
-- QA check prd column
-- basic general check
SELECT 
*
FROM silver.crm_prd_info

-- STEP 1
-- QA check for NULLs or Duplicates
-- Expectation: No Result

SELECT 
prd_id,
Count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- STEP 4
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != Trim(prd_nm)

-- Step 5
-- check for NULLs or Negative Numbers
-- Expectations: No Result

SELECT
prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- STEP 6
-- DATA Standardization & Consistency in low cardinality columns

SELECT DISTINCT prd_line  
FROM silver.crm_prd_info

-- STEP 7
-- Check for invalid Date Orders
-- Expectation: No Result
-- End Date must not be earlier than start date

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt
