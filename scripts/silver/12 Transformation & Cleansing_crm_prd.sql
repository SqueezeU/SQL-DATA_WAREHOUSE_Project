/*
======================================================
Transformation & Cleansing: crm_prd_info
======================================================
Script Purpose:
    Cleans and transforms data from bronze.crm_prd_info
    and loads the result into silver.crm_prd_info.
======================================================
*/
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
	-- SUBSTRING - extract from the column prd_key the first 5 characters
	-- REPLACE - replace the minus with an underscore
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,
	CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CAST(prd_start_dt AS DATE) AS prd_start_dt,
	CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
FROM
	bronze.crm_prd_info
-- WHERE Replace(Substring (prd_key, 1, 5), '-', '_') NOT in 
-- (SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2)
-- this WHERE clause checks whether there are any categories in erp_px_cat_g1v2 which are not
-- in our crm_prd_info

-- Substring check whether we can join the other tables using the new derived columns
-- BRAINSTORMING ONLY - not part of transformation
-- SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2
-- we notice that this is really the category and we could join but we have to make s slighly change
-- as in the erp file the category is written with an underscore instead of a minus which we got from
-- the Substring - so we need to change that using before SUBSTRING REPLACE '-' with '_'
-- then we extract (also with Substring) the second part which is the real prd_key
-- it starts in position 7 but the length is not in each row eqaul so we need to make it dynamic 
-- we do this using LEN(column name)
-- BRAINSTORMING ONLY - not part of transformation
-- SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details
-- we notice that there are a lot of products which have no sales so far using the following clause
-- WHERE Substring (prd_key, 7, Len(prd_key)) NOT in 
-- (SELECT DISTINCT sls_prd_key FROM bronze.crm_sales_details)
-- well we can´t do anything about it, so we can move on
--
-- as prd_line is a string data type, we put in the CASE WHEN THEN ELSE clause UPPER and TRIM
-- UPPER means get all values no matter what spelling ot better converts all spellings to Upper Case
-- TRIM assures that there are no hidden spaces
-- the usual long code would be
/*CASE
		WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
		WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
*/
-- but as is just a simple value mapping we can use the abbreviated coding
-- you can see it above in the code
-- it is not possible if we have complex mapping

-- =============================================
-- IMPORTANT - Next Step: Update Silver Layer
-- =============================================
-- The following changes in this transformation require updates
-- to the CREATE TABLE statement in the Silver Layer:
--
-- 1. New derived columns added:
--      - cat_id        (derived from prd_key via SUBSTRING + REPLACE)
--      - prd_key       (cleaned via SUBSTRING - original value modified)
--      - prd_line      (mapped via CASE WHEN to readable values)
--
-- 2. Data type changes:
--      - prd_cost      (NULLs replaced with 0 via ISNULL)
--      - prd_start_dt  (date logic applied via LEAD)
--      - prd_end_dt    (date logic applied via LEAD + CAST)
--
-- --> Silver Layer DDL has been updated accordingly
