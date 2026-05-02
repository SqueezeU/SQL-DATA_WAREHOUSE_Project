-- =====================================================================================
-- Data Integration: Combining CRM and ERP Product Data
-- =====================================================================================
-- Master Source for Product Data: CRM (silver.crm_prd_info)
-- Decision made with table owners: CRM is authoritative for product details
-- ERP data enriches CRM with additional attributes (category, subcategory, maintenance)
-- =====================================================================================

-- Master Table: silver.crm_prd_info (cpi)
-- LEFT JOIN silver.erp_px_cat_g1v2 (epcg) ON cat_id = id → adds category info from ERP
SELECT 
	cpi.prd_id,
	cpi.cat_id,
	cpi.prd_key,
	cpi.prd_nm,
	cpi.prd_cost,
	cpi.prd_line, 
	cpi.prd_start_dt,
	cpi.prd_end_dt,
	epcg.cat,
	epcg.subcat,
	epcg.maintenance
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcg
ON cpi.cat_id = epcg.id

-- Result: all CRM products enriched with ERP data - no products lost through LEFT JOIN strategy

-- ===================================================================
-- Duplicate Check: verify JOINs did not create duplicate rows
-- Wrap main query in subquery and count by primary key
-- Expectation: no rows returned (COUNT(*) > 1 means duplicates exist)
-- ===================================================================
SELECT prd_key, COUNT(*) FROM
		(SELECT 
			cpi.prd_id,
			cpi.cat_id,
			cpi.prd_key,
			cpi.prd_nm,
			cpi.prd_cost,
			cpi.prd_line, 
			cpi.prd_start_dt,
			cpi.prd_end_dt,
			epcg.cat,
			epcg.subcat,
			epcg.maintenance
		FROM silver.crm_prd_info cpi 
		LEFT JOIN silver.erp_px_cat_g1v2 epcg
		ON cpi.cat_id = epcg.id
		WHERE cpi.prd_end_dt IS NULL
)t GROUP BY prd_key
HAVING COUNT(*) > 1

-- Result: no rows returned → no duplicates created by JOINs

-- ====================================================================
-- Rename columns to business-friendly names
-- Following naming conventions: snake_case, English, no reserved words
-- Columns reorganized: product data first
-- system/technical data last - for better business readability
-- ====================================================================
SELECT 
	cpi.prd_id AS product_id,
	cpi.prd_key AS product_number,
	epcg.cat AS product_category,
	cpi.prd_nm AS product_name,
	cpi.cat_id AS category_id,
	epcg.subcat AS subcategory,
	epcg.maintenance AS maintenance_required,
	cpi.prd_cost AS cost,
	cpi.prd_line AS product_line,
	cpi.prd_start_dt AS start_date
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcg
ON cpi.cat_id = epcg.id

-- ===========================================================================
-- Add Surrogate Key
-- Using ROW_NUMBER() window function to generate a unique integer key
-- Independent from source system IDs - stable identifier for fact table joins
-- Naming convention: <entity>_key (e.g. product_key)
-- Filter: prd_end_dt IS NULL → only current/active products (no historization)
-- ============================================================================
SELECT 
ROW_NUMBER() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
cpi.prd_id          AS product_id,
cpi.prd_key         AS product_number,
cpi.prd_nm          AS product_name,
epcg.cat            AS category,
cpi.cat_id          AS category_id,
epcg.subcat         AS subcategory,
epcg.maintenance    AS maintenance_required,
cpi.prd_cost        AS cost,
cpi.prd_line        AS product_line,
cpi.prd_start_dt    AS start_date
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcg
ON cpi.cat_id = epcg.id
WHERE cpi.prd_end_dt IS NULL

-- ====================================================================
-- Create View: gold.dim_products
-- This view represents the final dimensional table for products
-- combining and enriching data from CRM and ERP silver layer tables
-- ====================================================================
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
ROW_NUMBER() OVER (ORDER BY cpi.prd_start_dt, cpi.prd_key) AS product_key,
cpi.prd_id          AS product_id,
cpi.prd_key         AS product_number,
cpi.prd_nm          AS product_name,
epcg.cat            AS category,
cpi.cat_id          AS category_id,
epcg.subcat         AS subcategory,
epcg.maintenance    AS maintenance_required,
cpi.prd_cost        AS cost,
cpi.prd_line        AS product_line,
cpi.prd_start_dt    AS start_date
FROM silver.crm_prd_info cpi 
LEFT JOIN silver.erp_px_cat_g1v2 epcg
ON cpi.cat_id = epcg.id
WHERE cpi.prd_end_dt IS NULL



