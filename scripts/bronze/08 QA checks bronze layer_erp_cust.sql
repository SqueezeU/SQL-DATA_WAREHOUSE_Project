/*
===========================================================
QA Script: Bronze Layer - erp_cust_az12
===========================================================
Script Purpose:
    QA checks on bronze.erp_cust_az12 before transformation
    into the silver layer.
===========================================================
*/

-- basic general check
SELECT
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12

-- STEP 1: cid Format Check (NAS prefix identification)
-- Note: Referential integrity against Silver can only be verified AFTER Silver load.
--       At Bronze stage: identify the prefix pattern only.
--       → Run full integrity check after EXEC silver.load_silver:
--         SELECT * FROM silver.erp_cust_az12
--         WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);
SELECT DISTINCT cid FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';
-- Result: NAS prefix identified → will be removed via SUBSTRING(cid, 4, LEN(cid)) in Silver

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
