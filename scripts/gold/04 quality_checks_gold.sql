/*
===============================================================================
QA Summary: Gold Layer — Overview of All Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

    For detailed step-by-step development of the Gold Layer views see:
        - gold_dim_customers.sql
        - gold_dim_products.sql
        - gold_fact_sales.sql
===============================================================================
*/

-- ================================================
-- 1. gold.dim_customers — Surrogate Key Uniqueness
-- ================================================
-- Expectation: No rows returned
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
-- Result: No issues — customer_key is unique

-- ===============================================
-- 2. gold.dim_products — Surrogate Key Uniqueness
-- ===============================================
-- Expectation: No rows returned
SELECT
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
-- Result: No issues — product_key is unique

-- ==============================================================
-- 3. gold.fact_sales — Referential Integrity (Fact → Dimensions)
-- ==============================================================
-- Check for orphaned records: fact rows with no matching dimension key
-- Expectation: 0 rows returned
SELECT COUNT(*) AS orphaned_records
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON dc.customer_key = fs.customer_key
LEFT JOIN gold.dim_products dp  ON dp.product_key  = fs.product_key
WHERE dp.product_key IS NULL OR dc.customer_key IS NULL;
-- Result: 0 — no orphaned records, data model connectivity confirmed