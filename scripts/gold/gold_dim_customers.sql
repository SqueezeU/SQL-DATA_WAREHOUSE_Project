-- =====================================================================
-- Data Integration: Combining CRM and ERP Customer Data
-- =====================================================================
-- Master Source for Customer Data: CRM (silver.crm_cust_info)
-- Decision made with table owners: CRM is authoritative for gender
-- ERP data enriches CRM with additional attributes (birthdate, country)
-- =====================================================================

-- Master Table: silver.crm_cust_info (cci)
-- LEFT JOIN silver.erp_cust_az12 (eca) ON cst_key = cid → adds birthdate and gender from ERP
-- LEFT JOIN silver.erp_loc_a101  (ela) ON cst_key = cid → adds country from ERP

SELECT 
		cci.cst_id,
		cci.cst_key,
		cci.cst_firstname,
		cci.cst_lastname,
		cci.cst_marital_status,
		cci.cst_gndr,
		cci.cst_create_date,
		eca.bdate,
		eca.gen,
		ela.cntry 
	FROM silver.crm_cust_info cci
	LEFT JOIN silver.erp_cust_az12 eca 
	ON cci.cst_key = eca.cid 
	LEFT JOIN silver.erp_loc_a101 ela
	ON cci.cst_key = ela.cid

-- Result: all CRM customers enriched with ERP data - no customers lost through LEFT JOIN strategy
	
-- ===================================================================
-- Duplicate Check: verify JOINs did not create duplicate rows
-- Wrap main query in subquery and count by primary key
-- Expectation: no rows returned (COUNT(*) > 1 means duplicates exist)
-- ===================================================================
SELECT cst_id, COUNT(*) FROM
	(SELECT 
		cci.cst_id,
		cci.cst_key,
		cci.cst_firstname,
		cci.cst_lastname,
		cci.cst_marital_status,
		cci.cst_gndr,
		cci.cst_create_date,
		eca.bdate,
		eca.gen,
		ela.cntry 
	FROM silver.crm_cust_info cci
	LEFT JOIN silver.erp_cust_az12 eca 
	ON cci.cst_key = eca.cid 
	LEFT JOIN silver.erp_loc_a101 ela
	ON cci.cst_key = ela.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1

-- Result: no rows returned → no duplicates created by JOINs

-- ================================================================
-- Data Integration: Resolve duplicate gender columns
-- CRM (cst_gndr) is Master Source for gender information
-- ERP (gen) used as fallback if CRM value is 'n/a'
-- COALESCE handles NULL values from LEFT JOIN → replaced with 'n/a'
-- =================================================================
SELECT DISTINCT
		cci.cst_gndr,
		eca.gen,
		CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr -- CRM = Master Source for Gender Info
			 ELSE COALESCE(eca.gen, 'n/a')
		END AS gender -- Data Integration: single unified gender column
	FROM silver.crm_cust_info cci
	LEFT JOIN silver.erp_cust_az12 eca
	ON cci.cst_key = eca.cid
	LEFT JOIN silver.erp_loc_a101 ela
	ON cci.cst_key = ela.cid
	ORDER BY cci.cst_gndr, eca.gen -- abbreviated: ORDER BY 1,2
	
-- ====================================================================
-- Rename columns to business-friendly names
-- Following naming conventions: snake_case, English, no reserved words
-- Columns reorganized: personal data first, geographic data second,
-- system/technical data last - for better business readability
-- ====================================================================
SELECT
    cci.cst_id                                      AS customer_id,
    cci.cst_key                                     AS customer_number,
    -- renamed: 'key' removed from alias - surrogate key (customer_key) will be added later
    cci.cst_firstname                               AS first_name,
    cci.cst_lastname                                AS last_name,
    ela.cntry                                       AS country,
    cci.cst_marital_status                          AS marital_status,
    CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr
         ELSE COALESCE(eca.gen, 'n/a')
    END                                             AS gender,
    eca.bdate                                       AS birthdate,
    cci.cst_create_date                             AS create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
    ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela
    ON cci.cst_key = ela.cid

-- ===========================================================================
-- Add Surrogate Key
-- Using ROW_NUMBER() window function to generate a unique integer key
-- Independent from source system IDs - stable identifier for fact table joins
-- Naming convention: <entity>_key (e.g. customer_key)
-- ===========================================================================
SELECT
	ROW_NUMBER () OVER (ORDER BY cci.cst_id) AS customer_key,
    cci.cst_id                                      AS customer_id,
    cci.cst_key                                     AS customer_number,
    cci.cst_firstname                               AS first_name,
    cci.cst_lastname                                AS last_name,
    ela.cntry                                       AS country,
    cci.cst_marital_status                          AS marital_status,
    CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr
         ELSE COALESCE(eca.gen, 'n/a')
    END                                             AS gender,
    eca.bdate                                       AS birthdate,
    cci.cst_create_date                             AS create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
    ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela
    ON cci.cst_key = ela.cid
    
-- ====================================================================
-- Create View: gold.dim_customers
-- This view represents the final dimensional table for customers
-- combining and enriching data from CRM and ERP silver layer tables
-- ====================================================================
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER () OVER (ORDER BY cci.cst_id) AS customer_key,
    cci.cst_id                                      AS customer_id,
    cci.cst_key                                     AS customer_number,
    cci.cst_firstname                               AS first_name,
    cci.cst_lastname                                AS last_name,
    ela.cntry                                       AS country,
    cci.cst_marital_status                          AS marital_status,
    CASE WHEN cci.cst_gndr != 'n/a' THEN cci.cst_gndr
         ELSE COALESCE(eca.gen, 'n/a')
    END                                             AS gender,
    eca.bdate                                       AS birthdate,
    cci.cst_create_date                             AS create_date
FROM silver.crm_cust_info cci
LEFT JOIN silver.erp_cust_az12 eca
    ON cci.cst_key = eca.cid
LEFT JOIN silver.erp_loc_a101 ela
    ON cci.cst_key = ela.cid
    
-- Quick Validation: gold.dim_customers
SELECT DISTINCT gender FROM gold.dim_customers;
-- Expectation: only Female, Male, n/a - no NULLs