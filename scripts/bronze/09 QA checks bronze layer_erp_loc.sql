/*
======================================================
QA Script: Bronze Layer - erp_loc_a101
======================================================
Script Purpose:
    QA checks on bronze.erp_loc_a101 before transformation
    into the silver layer.
======================================================
*/

-- basic general check
SELECT
    cid,
    cntry
FROM bronze.erp_loc_a101

-- STEP 1
-- Integrity Check: cid needs to be cleaned to join with silver.crm_cust_info
-- erp_loc cid contains a dash (-) after first 2 characters - not present in cst_key
-- e.g. AW-00011000 vs AW00011000
-- Rule: remove dash using REPLACE(cid, '-', '')
-- Solution will be applied in Transformation & Cleansing_erp_loc

SELECT DISTINCT cid FROM bronze.erp_loc_a101
-- compare with silver to check join compatibility:
SELECT DISTINCT cst_key FROM silver.crm_cust_info
-- checking join column values to compare with erp cid column
-- after transformation cid should match cst_key in silver.crm_cust_info

-- STEP 2
-- DATA Standardization & Consistency - low cardinality

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
-- check for abbreviations, inconsistent values or NULLs
-- Solution will be applied in Transformation & Cleansing_erp_loc
