-- QA check cust table
-- basic general check
SELECT 
*
FROM bronze.crm_cust_info

-- STEP 1
-- QA check for NULLs or Duplicates
-- therefore we have to aggregate the primary key and if we get values higher then 1,
-- then it is not unique and we got duplicates
-- Expectation: No Result

SELECT 
cst_id,
Count(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- STEP 2
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
-- * (just for quick checking base data and columns if needed)
cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != Trim(cst_firstname) -- Trim removes all leading and trailing spaces
-- if we get results, we have spaces in this column
-- so this we need to do with all string columns of the bronze table
-- eg. Select cst_lastname ... or Select cst_gndr etc etc

SELECT
-- * (just for quick checking base data and columns if needed)
cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != Trim(cst_lastname)

SELECT
-- * (just for quick checking base data and columns if needed)
cst_marital_status 
FROM bronze.crm_cust_info
WHERE cst_marital_status != Trim(cst_marital_status)

SELECT
-- * (just for quick checking base data and columns if needed)
cst_gndr  
FROM bronze.crm_cust_info
WHERE cst_gndr != Trim(cst_gndr)

SELECT
-- * (just for quick checking base data and columns if needed)
cst_key   
FROM bronze.crm_cust_info
WHERE cst_key != Trim(cst_key)

-- STEP 3
-- DATA Standardization & Consistency in low cardinality columns

SELECT DISTINCT -- to get the values in this column just once 
cst_gndr  
FROM bronze.crm_cust_info

SELECT DISTINCT
cst_marital_status  
FROM bronze.crm_cust_info