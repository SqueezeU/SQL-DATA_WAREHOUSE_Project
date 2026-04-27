/*
======================================================
QA Script: After Insert - silver.erp_px_cat_g1v2
======================================================
Script Purpose:
    QA checks on silver.erp_px_cat_g1v2 after transformation
    to verify data was loaded correctly from bronze layer.
    
Checks:
    1. Basic Visual Inspection
    2. Row Count Comparison  (Bronze vs Silver)
    3. NULL Check            - Data Completeness
    4. String Check          - Whitespace and Empty Values
    5. Standardization       - Distinct Value Review
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
FROM silver.erp_px_cat_g1v2;


-- ============================================================
-- 2. Row Count Comparison
--    Expectation: Both counts are equal
--    Result: Both = 37 → counts match, no rows lost or duplicated
-- ============================================================
SELECT COUNT(*) AS bronze_row_count
FROM bronze.erp_px_cat_g1v2;

SELECT COUNT(*) AS silver_row_count
FROM silver.erp_px_cat_g1v2;


-- ============================================================
-- 3. NULL Check: Data Completeness
--    Expectation: No rows returned
--    Result: No rows → no NULLs anywhere
-- ============================================================
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id          IS NULL
   OR cat         IS NULL
   OR subcat      IS NULL
   OR maintenance IS NULL;


-- ============================================================
-- 4. String Check: Whitespace and Empty Values
--    Expectation: No rows returned
--    Result: No rows → expectation met
-- ============================================================
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE (id          != TRIM(id)          OR TRIM(id)          = '')
   OR (cat         != TRIM(cat)         OR TRIM(cat)         = '')
   OR (subcat      != TRIM(subcat)      OR TRIM(subcat)      = '')
   OR (maintenance != TRIM(maintenance) OR TRIM(maintenance) = '');


-- ============================================================
-- 5. Standardization: Distinct Value Review
--    Visual check for unexpected values or inconsistencies
--    Result: No issues found in any column
-- ============================================================
SELECT DISTINCT cat         FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT subcat      FROM silver.erp_px_cat_g1v2;
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2;

/*
======================================================
Summary:
    - Row count match: ✓ Bronze and Silver both = 37
    - NULLs:           ✓ None
    - Whitespace:      ✓ None
    - Standardization: ✓ No issues
    Overall: Silver load successful - data matches bronze
======================================================
*/