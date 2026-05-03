-- QA check prd table
-- basic general check
SELECT 
*
FROM bronze.crm_prd_info

-- STEP 1
-- QA check for NULLs or Duplicates
-- Expectation: No Result

SELECT 
prd_id,
Count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- STEP 2
-- the product key contains two informations - so we need to derive new columns
-- the first 5 characters are actually the category, so we split the code there, using Substring
-- you can see that in the query Transformation & Cleansing_prd

-- STEP 3
-- the rest is the real prd_key, so we split the code starting at position 7, using Substring
-- with LEN(column name) we make it dynamic
-- you can see that in the query Transformation & Cleansing_prd

-- STEP 4
-- the prd_nm column ist string so we check for unwanted spaces
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != Trim(prd_nm)

-- Step 5
-- check for NULLs or Negative Numbers
-- Expectations: No Result

SELECT
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL
-- we find 2 NULL values and need to replace them with 0; we do this using ISNULL befor the column name
-- you can see that in the query Transformation & Cleansing_prd

-- STEP 6
-- DATA Standardization & Consistency in low cardinality columns

SELECT DISTINCT prd_line  
FROM bronze.crm_prd_info
-- we find a few abbrevations - let´s talk to the database or table owner to find out what they mean
-- than we put them in a user-friendly output using CASE WHEN THEN ELSE
-- you can see that in the query Transformation & Cleansing_prd

-- STEP 7
-- Check for invalid Date Orders
-- Expectation: No Result
-- End Date must not be earlier than start date

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt
-- QA check: we find multiple records where prd_end_dt is earlier than prd_start_dt
-- this is invalid - an end date must never be before the start date
-- for complex transformations like this it helps to narrow down to a few specific examples first
-- and brainstorm multiple solution approaches before writing the final logic

SELECT TOP 10 * FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt OR prd_end_dt IS NULL
-- Brainstorm approach: simply swap end_date and start_date
-- REJECTED - because costs differ across periods (e.g. cost 12 in 2011, cost 14 in 2012)
-- swapping would create overlapping cost periods for the same product
-- a product cannot have two different costs in the same year - overlapping is not acceptable

-- Solution approach: the end_date of one product entry must always be one day before
-- the start_date of the next entry for the same product (= non-overlapping consecutive periods)

-- Furthermore we would have some entries without a start (NULL) - that´s also not acceptable
-- while a NULL in the end date wouldn´t be a problem; it just means currently the same cost
-- so let´s derive the end date from the start date
-- Rule: End Date = Start Date of the next record - 1
-- the result you have to discuss with the owners of the table and if they approve it, we can clean up
-- the date with the new logic
-- you can see how to do in the query Transformation & Cleansing_prd (check fo the Line with LEAD)

-- as we still can see various 00 as time we dont need them, so we simply switch the data type 
-- to DATE instead of DATETIME or DATETIME2 using CAST
-- you can see how to do in the query Transformation & Cleansing_prd (check fo the Line with CAST)

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
-- --> Make sure the Silver Layer DDL reflects these changes!