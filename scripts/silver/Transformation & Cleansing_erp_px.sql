/*
======================================================
Transformation & Cleansing: erp_px_cat_g1v2
======================================================
Script Purpose:
    Loads data from bronze.erp_px_cat_g1v2 into
    silver.erp_px_cat_g1v2 without transformation.
    Source data is already clean - no changes required.
    (Confirmed by QA Bronze Layer checks)
======================================================
*/

TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;
