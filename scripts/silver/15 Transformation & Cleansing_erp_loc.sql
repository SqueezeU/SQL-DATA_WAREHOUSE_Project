/*
======================================================
Transformation & Cleansing: erp_loc_a101
======================================================
Script Purpose:
    Cleans and transforms data from bronze.erp_loc_a101
    and loads the result into silver.erp_loc_a101.
======================================================
*/
TRUNCATE TABLE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    -- STEP 1: remove dash from cid to match cst_key in silver.crm_cust_info
    CASE WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
         WHEN UPPER(TRIM(cntry)) IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
         WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
         ELSE TRIM(cntry)
    END AS cntry
    -- STEP 2: standardize country values using UPPER and TRIM for future-proofing
    -- DE/Germany/GERMANY → Germany
    -- US/USA/United States → United States
    -- NULL/empty → n/a
    -- other values kept as is with TRIM
FROM bronze.erp_loc_a101