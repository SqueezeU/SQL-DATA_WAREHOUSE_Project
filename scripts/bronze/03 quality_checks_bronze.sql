/*
===============================================================================
QA Summary: Bronze Layer — Overview of All Quality Checks
===============================================================================
Script Purpose:
    Quick overview of all quality checks performed on the Bronze layer.
    Each check represents a condensed version of the full QA scripts.
    
    For detailed step-by-step analysis, findings, and brainstorming notes
    see the individual QA scripts:
        - QA_checks_bronze_layer_crm_cust.sql
        - QA_checks_bronze_layer_crm_prd.sql
        - QA_checks_bronze_layer_crm_sales.sql
        - QA_checks_bronze_layer_erp_cust.sql
        - QA_checks_bronze_layer_erp_loc.sql
        - QA_checks_bronze_layer_erp_px.sql

Results documented inline as comments.
===============================================================================
*/

-- =======================
-- 1. bronze.crm_cust_info
-- =======================

-- STEP 1: NULL & Duplicate Check on Primary Key
-- Expectation: No rows returned
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- Result: Duplicates found → will be resolved in Silver via ROW_NUMBER() deduplication

-- STEP 2: Unwanted Spaces (all string columns in one check)
-- Expectation: No rows returned
SELECT * FROM bronze.crm_cust_info
WHERE cst_firstname      != TRIM(cst_firstname)
   OR cst_lastname       != TRIM(cst_lastname)
   OR cst_marital_status != TRIM(cst_marital_status)
   OR cst_gndr           != TRIM(cst_gndr)
   OR cst_key            != TRIM(cst_key);
-- Result: Spaces found in name columns → TRIM will be applied in Silver

-- STEP 3: Standardization — Low Cardinality Columns
-- Expectation: Clean, consistent values only
SELECT DISTINCT cst_gndr           FROM bronze.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info;
-- Result: Abbreviations found (M/F, S/M) → will become mapped to Male/Female/Single/Married/n/a in Silver


-- ======================
-- 2. bronze.crm_prd_info
-- ======================

-- STEP 1: NULL & Duplicate Check on Primary Key
-- Expectation: No rows returned
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Result: No issues

-- STEP 2: Unwanted Spaces (prd_nm)
-- Expectation: No rows returned
SELECT prd_nm FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Result: No issues

-- STEP 3: NULLs or Negative Numbers (prd_cost)
-- Expectation: No rows returned
SELECT prd_cost FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
-- Result: NULL values found → will be replaced with 0 via ISNULL in Silver

-- STEP 4: Standardization — Low Cardinality Column (prd_line)
-- Expectation: Clean, consistent values only
SELECT DISTINCT prd_line FROM bronze.crm_prd_info;
-- Result: Abbreviations found (M/R/S/T) → will become mapped to Mountain/Road/Other Sales/Touring in Silver

-- STEP 5: Invalid Date Order (End Date earlier than Start Date)
-- Expectation: No rows returned
SELECT * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
-- Result: Multiple violations found → will be resolved via LEAD() window function in Silver
-- Note: See individual QA script for full brainstorming on why simple date swap was rejected


-- ===========================
-- 3. bronze.crm_sales_details
-- ===========================
-- Note: No single Primary Key — join compatibility checked instead

-- STEP 1: Unwanted Spaces (sls_ord_num)
-- Expectation: No rows returned
SELECT sls_ord_num FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
-- Result: No issues

-- STEP 2: Join Column Format Check (sls_prd_key, sls_cust_id)
-- Note: Referential integrity against Silver can only be verified AFTER Silver load.
--       At Bronze stage: verify format consistency of join columns only.
--       → Run full integrity check after EXEC silver.load_silver:
--         SELECT * FROM bronze.crm_sales_details
--         WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
--         SELECT * FROM bronze.crm_sales_details
--         WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details ORDER BY sls_prd_key;
SELECT DISTINCT sls_cust_id FROM bronze.crm_sales_details ORDER BY sls_cust_id;
-- Result: Formats look consistent — full integrity to check after Silver load

-- STEP 3: Invalid Dates (stored as INT — boundary + format check)
-- Expectation: No rows returned
SELECT sls_order_dt FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;
-- Result: Zero values found → will be converted via NULLIF before CAST to DATE in Silver

-- STEP 4: Invalid Date Order (Order Date later than Ship or Due Date)
-- Expectation: No rows returned
SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
-- Result: No issues — business rule confirmed

-- STEP 5: Data Consistency — Sales = Quantity * Price
-- Expectation: No rows returned
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales    IS NULL OR sls_sales    <= 0
   OR sls_quantity IS NULL OR sls_quantity <= 0
   OR sls_price    IS NULL OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
-- Result: NULLs, negatives and zeros found in sls_sales and sls_price
-- → Business rules agreed with table owners, will be applied in Silver
-- Note: See individual QA script for full derivation logic


-- =======================
-- 4. bronze.erp_cust_az12
-- =======================

-- STEP 1: cid Format Check (NAS prefix identification)
-- Note: Referential integrity against Silver can only be verified AFTER Silver load.
--       At Bronze stage: identify the prefix pattern only.
--       → Run full integrity check after EXEC silver.load_silver:
--         SELECT * FROM silver.erp_cust_az12
--         WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);
SELECT DISTINCT cid FROM bronze.erp_cust_az12
WHERE cid LIKE 'NAS%';
-- Result: NAS prefix identified → will be removed via SUBSTRING(cid, 4, LEN(cid)) in Silver

-- STEP 2: Out-of-Range Birthdates (future dates)
-- Expectation: No rows returned
SELECT DISTINCT bdate FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();
-- Result: Future dates found → will be set to NULL in Silver
-- Note: Records older than 100 years kept — confirmed with table owners

-- STEP 3: Standardization — Gender Column (gen)
-- Expectation: Clean, consistent values only
SELECT DISTINCT gen FROM bronze.erp_cust_az12;
-- Result: Mixed values found (F/Female/M/Male/NULL)
-- → will become standardized to Female/Male/n/a in Silver


-- ======================
-- 5. bronze.erp_loc_a101
-- ======================

-- STEP 1: cid Format Check (dash identification)
-- Note: Referential integrity against Silver can only be verified AFTER Silver load.
--       At Bronze stage: identify the dash pattern only.
--       → Run full integrity check after EXEC silver.load_silver:
--         SELECT * FROM silver.erp_loc_a101
--         WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);
SELECT DISTINCT cid FROM bronze.erp_loc_a101
WHERE cid LIKE '%-%';
-- Result: Dash found in all cid values (e.g. AW-00011000)
-- → will be removed via REPLACE(cid, '-', '') in Silver

-- STEP 2: Standardization — Country Column (cntry)
-- Expectation: Clean, consistent values only
SELECT DISTINCT cntry FROM bronze.erp_loc_a101;
-- Result: Abbreviations and inconsistencies found (DE/US/empty)
-- → will become standardized to Germany/United States/n/a in Silver


-- =========================
-- 6. bronze.erp_px_cat_g1v2
-- =========================

-- STEP 1: NULL Check — Data Completeness (all columns)
-- Expectation: No rows returned
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE id          IS NULL OR cat         IS NULL
   OR subcat      IS NULL OR maintenance IS NULL;
-- Result: No issues

-- STEP 2: Whitespace & Empty Value Check (all columns)
-- Expectation: No rows returned
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE (id          != TRIM(id)          OR TRIM(id)          = '')
   OR (cat         != TRIM(cat)         OR TRIM(cat)         = '')
   OR (subcat      != TRIM(subcat)      OR TRIM(subcat)      = '')
   OR (maintenance != TRIM(maintenance) OR TRIM(maintenance) = '');
-- Result: No issues

-- STEP 3: Standardization — Distinct Value Review
-- Expectation: Clean, consistent values only
SELECT DISTINCT cat         FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat      FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;
-- Result: No issues — source data already clean, no transformation required