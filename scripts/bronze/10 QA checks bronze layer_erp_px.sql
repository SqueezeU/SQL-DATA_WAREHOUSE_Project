/*
======================================================
QA Script: Bronze Layer - erp_px_cat_g1v2
======================================================
Script Purpose:
    QA checks on bronze.erp_px_cat_g1v2 before transformation
    into the silver layer.
    
Checks:
    1. Basic Visual Inspection
    2. Key Integrity  - Count Comparison (Bronze vs Silver)
    3. Key Consistency - Join Check (Bronze vs Silver)
    4. NULL Check      - Data Completeness
    5. String Check    - Whitespace and Empty Values
    6. Standardization - Distinct Value Review
======================================================
*/

-- ============================================================
-- 1. Basic Visual Inspection
-- ============================================================
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- ============================================================
-- 2. Key Integrity: Count Comparison
--    Compare distinct ID counts between Bronze and Silver
--    Expectation: Both counts are equal
-- ============================================================
SELECT COUNT(DISTINCT id) AS bronze_id_count
FROM bronze.erp_px_cat_g1v2;

SELECT COUNT(DISTINCT cat_id) AS silver_cat_id_count
FROM silver.crm_prd_info;

--    Result: Both = 37 → counts match, so no count issue

-- ============================================================
-- 3. Key Consistency: Join Check
--    Check if all IDs match between Bronze and Silver
--    Expectation: No rows returned
-- ============================================================

-- 3a. Bronze IDs not found in Silver
--     Result: 1 row (CO_PD)
--     Expected - CO_PD exists in ERP but has no products in CRM
--     Confirmed at project start → not a data quality issue
SELECT DISTINCT b.id AS bronze_id_not_in_silver
FROM bronze.erp_px_cat_g1v2 b
LEFT JOIN silver.crm_prd_info s ON b.id = s.cat_id
WHERE s.cat_id IS NULL;

-- 3b. Silver IDs not found in Bronze
--     Result: 1 row (CO_PE)
--     DATA QUALITY FINDING #2 (Portfolio):
--       CO_PE exists in silver.crm_prd_info but not in bronze.erp_px_cat_g1v2
--       Root cause: products with prd_key 'CO-PE-PD-XXXX' generate cat_id 'CO_PE'
--       via SUBSTRING(prd_key,1,5) + REPLACE('-','_'), but 'CO_PE' does not exist
--       in the ERP category table - the correct category is 'CO_PD'
--       Recommendation: use CHARINDEX for dynamic extraction instead of fixed SUBSTRING
--       Status: not corrected in transformation - documented as portfolio finding
SELECT DISTINCT s.cat_id AS silver_id_not_in_bronze
FROM silver.crm_prd_info s
LEFT JOIN bronze.erp_px_cat_g1v2 b ON s.cat_id = b.id
WHERE b.id IS NULL;


-- ============================================================
-- 4. NULL Check: Data Completeness
--    Expectation: No rows returned
-- ============================================================
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE id          IS NULL
   OR cat         IS NULL
   OR subcat      IS NULL
   OR maintenance IS NULL;

--    Result: No rows → no NULLs anywhere

-- ============================================================
-- 5. String Check: Whitespace and Empty Values
--    Expectation: No rows returned
-- ============================================================
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE (id          != TRIM(id)          OR TRIM(id)          = '')
   OR (cat         != TRIM(cat)         OR TRIM(cat)         = '')
   OR (subcat      != TRIM(subcat)      OR TRIM(subcat)      = '')
   OR (maintenance != TRIM(maintenance) OR TRIM(maintenance) = '');

--    Result: No rows → expectation met

-- ============================================================
-- 6. Standardization: Distinct Value Review
--    Visual check for unexpected values or inconsistencies
-- ============================================================
SELECT DISTINCT cat         FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT subcat      FROM bronze.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM bronze.erp_px_cat_g1v2;

--    Result: No issues found in any column

/*
====================================================================
Summary:
    - Count match:     ✓ Bronze and Silver both = 37
    - Key join gaps:   ✓ CO_PD (Bronze only) - expected, no issue
                       ! CO_PE (Silver only)  - Portfolio Finding #2
    - NULLs:           ✓ None
    - Whitespace:      ✓ None
    - Standardization: ✓ No issues
    Overall: Clean source data - no transformations required
=====================================================================
*/