/*
======================================================
Transformation & Cleansing: erp_cust_az12
======================================================
Script Purpose:
    Cleans and transforms data from bronze.erp_cust_az12
    and loads the result into silver.erp_cust_az12.
======================================================
*/

TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
         ELSE cid
    END AS cid,
    -- STEP 1: remove first 3 characters if cid starts with NAS
    -- to match cst_key in silver.crm_cust_info for joining

    CASE WHEN bdate > GETDATE() THEN NULL
         ELSE bdate
    END AS bdate,
    -- STEP 2: future birth dates are invalid - set to NULL
    -- birth dates older than 1924 are kept - decision by table owners

    CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
         WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
         ELSE 'n/a'
    END AS gen
    -- STEP 3: standardize gender values
    -- F/Female → Female, M/Male → Male, NULL/empty → n/a

FROM bronze.erp_cust_az12