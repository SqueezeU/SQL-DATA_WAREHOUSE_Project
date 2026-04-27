/*
======================================================
Transformation & Cleansing: crm_cust_info
======================================================
Script Purpose:
    Cleans and transforms data from bronze.crm_cust_info
    and loads the result into silver.crm_cust_info.
======================================================
*/

TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date)
	
SELECT -- Starting the Subquery
-- *
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname, -- STEP 2
TRIM(cst_lastname) AS cst_lastname, -- STEP 2
	CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' -- STEP 3
		 WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' -- STEP 3
		 ELSE 'n/a'
	END cst_marital_status,
	CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' -- STEP 3
		 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' -- STEP 3
		 ELSE 'n/a'
	END cst_gndr,
cst_create_date
FROM (
	SELECT -- Main query STEP 1
	*,
	ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS Flag_Last
	-- this is the window function
	FROM bronze.crm_cust_info
	-- WHERE cst_id = 29466
)t WHERE flag_last = 1 AND cst_id IS NOT NULL -- (!= 1 - checks for the duplicates)

-- What did we do here in order to understand the issue better?
--
-- STEP 1:
-- Cleaning Nulls and Duplicates in Primary Key 
-- We have chosen one of the duplicates (Where Clause with cst_id = 29466), 
-- which we found in query QA checks STEP 1 - as a result we see 3 entries
-- as we want just one, we concentrate in the newest one (see cst_create_date)
-- so we rank those 3 values and keep just the number 1 - we do this using the Window Function
-- than we commented out the "Where Clause" to get the Flag for all the table
-- this means now we have the table with ALL the values as it´s in bronze just with an additional column
-- therefore we put everything in a subquery (that is where we put the main query in brackets) 
-- to check for all duplicates which are the entries not equal to 1 (see WHERE flag_last != 1)
-- as we want from the bronze layer just the entries without any duplicates, we check as cleaning step
-- for all where flag_last = 1 - so we prepared the table for becoming silver layer with Step 1 cleaned;
-- additionally with changing the WHERE Clause to flag_last = 1 AND cst_id = 29466 we can check 
-- whether we get now just one entry instead of the 3 values before - so STEP 1 done with success
--
-- STEP 2:
-- now we start looking for hidden spaces
-- therefore we comment out the * after the Select of the Subquery (not the one inside the subquery)
-- and put all columns of the table bronze.crm.cust.info
-- as we found out that just the name columns have unwanted spaces, we just need to TRIM them
-- gender and maritual staus has been fine (see Query QA checks STEP 2)
--
-- STEP 3:
-- but those both columns are low cardinality columns (means not very much different values) and the
-- values are abbreviated (check query QA checks STEP 3); so let´s make them more user friendly and
-- better readable - therefore we use the CASE WHEN .. THEN .. ELSE; we also have to make a decision
-- about the NULLs in those columns - we could leave it like it is, but it is always better to use the
-- standard n/a (not applicable) for them
-- in order to include also values which get put in the column in the future, we put UPPER before the
-- column name and we also put TRIM - not because we do have unwanted spaces right now but to cover
-- those errors whcih might occur in the future   
--
-- STEP 4:
-- now we just check the last column cst_create_date - as it is a data type DATE there is nothing to do
--
-- STEP 5:
-- now we have to insert everything in the silver table
