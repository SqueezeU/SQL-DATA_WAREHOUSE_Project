/*
===============================================================================
QA Summary: Silver Layer — Overview of All Quality Checks
===============================================================================
Script Purpose:
    Quick overview of all quality checks performed on the Silver layer
    after transformation and cleansing from Bronze.
    Each check represents a condensed version of the full QA scripts.

    For detailed step-by-step analysis, findings, and brainstorming notes
    see the individual QA scripts:
        - QA_checks_crm_cust_after_insert_in_silver_layer.sql
        - QA_checks_crm_prd_after_insert_in_silver_layer.sql
        - QA_checks_crm_sales_after_insert_in_silver_layer.sql
        - QA_checks_erp_cust_after_insert_in_silver_layer.sql
        - QA_checks_erp_loc_after_insert_in_silver_layer.sql
        - QA_checks_erp_px_after_insert_in_silver_layer.sql

Results documented inline as comments.
===============================================================================
*/

-- ============================================================
-- 1. silver.crm_cust_info
-- ============================================================

-- STEP 1: NULL & Duplicate Check on Primary Key
-- Expectation: No rows returned
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;
-- Result: No issues — duplicates were resolved via ROW_NUMBER() deduplication

-- STEP 2: Unwanted Spaces (all string columns in one check)
-- Expectation: No rows returned
SELECT * FROM silver.crm_cust_info
WHERE cst_firstname      != TRIM(cst_firstname)
   OR cst_lastname       != TRIM(cst_lastname)
   OR cst_marital_status != TRIM(cst_marital_status)
   OR cst_gndr           != TRIM(cst_gndr)
   OR cst_key            != TRIM(cst_key);
-- Result: No issues — TRIM applied during transformation

-- STEP 3: Standardization — Low Cardinality Columns
-- Expectation: only Female, Male, n/a / only Single, Married, n/a
SELECT DISTINCT cst_gndr           FROM silver.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;
-- Result: Clean values confirmed — abbreviations successfully mapped in transformation


-- ============================================================
-- 2. silver.crm_prd_info
-- ============================================================

-- STEP 1: NULL & Duplicate Check on Primary Key
-- Expectation: No rows returned
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
-- Result: No issues

-- STEP 2: Unwanted Spaces (prd_nm)
-- Expectation: No rows returned
SELECT prd_nm FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);
-- Result: No issues

-- STEP 3: NULLs or Negative Numbers (prd_cost)
-- Expectation: No rows returned
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;
-- Result: No issues — NULLs replaced with 0 via ISNULL during transformation

-- STEP 4: Standardization — Low Cardinality Column (prd_line)
-- Expectation: only Mountain, Road, Other Sales, Touring, n/a
SELECT DISTINCT prd_line FROM silver.crm_prd_info;
-- Result: Clean values confirmed — abbreviations successfully mapped in transformation

-- STEP 5: Invalid Date Order (End Date earlier than Start Date)
-- Expectation: No rows returned
SELECT * FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
-- Result: No issues — resolved via LEAD() window function during transformation


-- ============================================================
-- 3. silver.crm_sales_details
-- ============================================================
-- Note: No single Primary Key — join compatibility checked instead

-- STEP 1: Unwanted Spaces (sls_ord_num)
-- Expectation: No rows returned
SELECT sls_ord_num FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);
-- Result: No issues

-- STEP 2: Integrity Check — Join Columns
-- Expectation: No rows returned
SELECT * FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

SELECT * FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
-- Result: No issues — join keys are reliable

-- STEP 3: NULL Date Check (dates converted from INT to DATE in transformation)
-- Expectation: No rows returned for ship_dt and due_dt
-- Note: sls_order_dt may contain NULLs — see Portfolio Finding #1
SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR sls_due_dt  IS NULL;
-- Result: No issues for ship and due dates

-- STEP 4: Invalid Date Order (Order Date later than Ship or Due Date)
-- Expectation: No rows returned
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
-- Result: No issues — business rule confirmed

-- STEP 5: Data Consistency — Sales = Quantity * Price
-- Expectation: No rows returned
SELECT DISTINCT sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales    IS NULL OR sls_sales    <= 0
   OR sls_quantity IS NULL OR sls_quantity <= 0
   OR sls_price    IS NULL OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
-- Result: No issues — business rules successfully applied in transformation

-- ============================================================
-- Portfolio Finding #1 — identified during this QA:
-- sls_order_dt contains NULL values while sls_ship_dt and sls_due_dt
-- have valid dates. Shipments and due dates exist without a corresponding
-- order date.
-- Status: documented, not corrected in code.
-- ============================================================


-- ============================================================
-- 4. silver.erp_cust_az12
-- ============================================================

-- STEP 1: Integrity Check — cid vs. silver.crm_cust_info.cst_key
-- NAS prefix has been removed during transformation
-- Expectation: No rows returned
SELECT * FROM silver.erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);
-- Result: No issues — cid successfully cleaned and join confirmed

-- STEP 2: Out-of-Range Birthdates (future dates)
-- Expectation: No rows returned
SELECT DISTINCT bdate FROM silver.erp_cust_az12
WHERE bdate > GETDATE();
-- Result: No issues — future dates set to NULL during transformation
-- Note: Records older than 100 years kept — confirmed with table owners

-- STEP 3: Standardization — Gender Column (gen)
-- Expectation: only Female, Male, n/a
SELECT DISTINCT gen FROM silver.erp_cust_az12;
-- Result: Clean values confirmed — mixed values standardized in transformation


-- ============================================================
-- 5. silver.erp_loc_a101
-- ============================================================

-- STEP 1: Integrity Check — cid vs. silver.crm_cust_info.cst_key
-- Dash has been removed during transformation
-- Expectation: No rows returned
SELECT * FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info);
-- Result: No issues — cid successfully cleaned and join confirmed

-- STEP 2: Standardization — Country Column (cntry)
-- Expectation: only Germany, United States, n/a and other clean values
SELECT DISTINCT cntry FROM silver.erp_loc_a101;
-- Result: Clean values confirmed — abbreviations standardized in transformation


-- ============================================================
-- 6. silver.erp_px_cat_g1v2
-- ============================================================

-- STEP 1: Row Count Comparison (Bronze vs Silver)
-- Expectation: Both counts are equal
SELECT COUNT(*) AS bronze_row_count FROM bronze.erp_px_cat_g1v2;
SELECT COUNT(*) AS silver_row_count FROM silver.erp_px_cat_g1v2;
-- Result: Both = 37 — no rows lost or duplicated

-- STEP 2: NULL Check — Data Completeness (all columns)
-- Expectation: No rows returned
SELECT * FROM silver.erp_px_cat_g1v2
WHERE id          IS NULL OR cat         IS NULL
   OR subcat      IS NULL OR maintenance IS NULL;
-- Result: No issues

-- STEP 3: Whitespace & Empty Value Check (all columns)
-- Expectation: No rows returned
SELECT * FROM silver.erp_px_cat_g1v2
WHERE (id          != TRIM(id)          OR TRIM(id)          = '')
   OR (cat         != TRIM(cat)         OR TRIM(cat)         = '')
   OR (subcat      != TRIM(subcat)      OR TRIM(subcat)      = '')
   OR (maintenance != TRIM(maintenance) OR TRIM(maintenance) = '');
-- Result: No issues

-- STEP 4: Standardization — Distinct Value Review
-- Expectation: Clean, consistent values only
SELECT DISTINCT cat         FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT subcat      FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;
-- Result: No issues — source data already clean, no transformation required

-- ============================================================
-- Portfolio Finding #2 — identified during this QA:
-- CO_PE exists in silver.crm_prd_info but NOT in bronze.erp_px_cat_g1v2
-- Root cause: fixed SUBSTRING on prd_key generates 'CO_PE' which has
-- no matching category in ERP. Recommendation: use CHARINDEX instead.
-- Status: documented, not corrected in code.
-- ============================================================