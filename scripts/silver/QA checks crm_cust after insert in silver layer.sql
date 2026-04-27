/*
======================================================
QA Script: Silver Layer - crm_cust_info
======================================================
Script Purpose:
    Verifies that the transformation and cleansing
    applied in Transformation_Cleansing_cust.sql
    produced clean data in the silver layer.
======================================================
*/

SELECT 
*
FROM silver.crm_cust_info

-- STEP 1
-- QA check for NULLs or Duplicates
SELECT 
cst_id,
Count(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- STEP 2
-- QA check for unwanted Spaces
-- Expectation: No Results

SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != Trim(cst_firstname) 

SELECT
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != Trim(cst_lastname)

SELECT
cst_marital_status 
FROM silver.crm_cust_info
WHERE cst_marital_status != Trim(cst_marital_status)

SELECT
cst_gndr  
FROM silver.crm_cust_info
WHERE cst_gndr != Trim(cst_gndr)

SELECT
cst_key   
FROM silver.crm_cust_info
WHERE cst_key != Trim(cst_key)

-- STEP 3
-- DATA Standardization & Consistency in low cardinality columns

SELECT DISTINCT
cst_gndr  
FROM silver.crm_cust_info

SELECT DISTINCT
cst_marital_status  
FROM silver.crm_cust_info