/*
======================================================
QA Script: Bronze Layer - erp_cust_az12
======================================================
Script Purpose:
    QA checks on bronze.erp_cust_az12 before transformation
    into the silver layer.
======================================================
*/

-- basic general check
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12

-- STEP 1
-- Integrity Check: cid needs to be cleaned to join with silver.crm_cust_info
-- erp cid has 3 extra characters at the beginning (NAS) compared to crm cst_key
-- Solution will be applied in Transformation & Cleansing_erp_cust

SELECT DISTINCT cid FROM bronze.erp_cust_az12
-- compare with silver to check join compatibility:
SELECT cst_key FROM silver.crm_cust_info
-- checking join column values to compare with erp cid column
-- after transformation cid should match cst_key in silver.crm_cust_info

-- STEP 2
-- check for Invalid Dates in bdate
-- Expectation: No Result

SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
-- found multiple records older than 100 years - decision by table owners: keep as is
-- found records with future dates - these will be set to NULL in Transformation
-- Rule: bdate > GETDATE() → NULL
-- Solution will be applied in Transformation & Cleansing_erp_cust

-- STEP 3
-- DATA Standardization & Consistency 
-- low cardinality column

SELECT DISTINCT gen
FROM bronze.erp_cust_az12
-- found: NULL, empty, F, M, Male, Female - inconsistent values
-- abbreviations and full words mixed - needs standardization
-- Rule: F/Female → Female, M/Male → Male, NULL/empty → n/a
-- Solution will be applied in Transformation & Cleansing_erp_cust
