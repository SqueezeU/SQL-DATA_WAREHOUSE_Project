/*
======================================================
QA Script: Silver Layer - erp_loc_a101
======================================================
Script Purpose:
    Verifies that the transformation and cleansing
    applied in Transformation_Cleansing_erp_loc.sql
    produced clean data in the silver layer.
======================================================
*/

-- basic general check
SELECT cid, cntry
FROM silver.erp_loc_a101

-- basic total row check
SELECT
COUNT(*)
FROM silver.erp_loc_a101

-- STEP 1
-- Integrity Check: cid should now match cst_key in silver.crm_cust_info
-- Expectation: No Result

SELECT * FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

-- STEP 2
-- DATA Standardization & Consistency - cntry column
-- Expectation: only Germany, United States, n/a and other clean values

SELECT DISTINCT cntry
FROM silver.erp_loc_a101