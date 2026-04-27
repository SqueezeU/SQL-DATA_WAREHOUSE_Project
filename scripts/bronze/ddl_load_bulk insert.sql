/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS -- as we need to run it on daily basis
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY 
		SET @batch_start_time = GetDate () 
		PRINT '=================';
		PRINT 'Load Bronze Layer';
		PRINT '=================';
		
		PRINT '---------------'; 
		PRINT 'Load CRM Tables';
		PRINT '---------------';
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info; -- first empty the table and than upload the data
		
		PRINT '>>> Inserting Data: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			Firstrow = 2, -- means firstrow is the header; data begins in row 2
			Fieldterminator = ',', -- how the data is separated in the csv
			Tablock	-- blocks the table for us until we are done
		);
		PRINT '>>> Rows Inserted: ' +CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.crm_cust_info -- not just insert, also test it at once
			
		-- ===================================================================================
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info; 
		
		PRINT '>>> Inserting Data: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			Firstrow = 2, 
			Fieldterminator = ',',
			Tablock
		);
		
		PRINT '>>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.crm_prd_info 
		
		-- ===================================================================================
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details; 
		
		PRINT '>>> Inserting Data: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			Firstrow = 2, 
			Fieldterminator = ',', 
			Tablock	
		);
		
		PRINT '>>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.crm_sales_details 
		
		-- ===================================================================================
		
		PRINT '---------------'; 
		PRINT 'Load ERP Tables';
		PRINT '---------------';
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101; 
		
		PRINT '>>> Inserting Data: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
		WITH (
			Firstrow = 2, 
			Fieldterminator = ',',
			Tablock	
		);
		
		PRINT '>>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.erp_loc_a101 
		
		-- ===================================================================================
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12; 
		
		PRINT '>>> Inserting Data: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
		WITH (
			Firstrow = 2, 
			Fieldterminator = ',', 
			Tablock	
		);
		
		PRINT '>>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.erp_cust_az12 
		
		-- ===================================================================================
		
		SET @start_time = GetDate () 
		PRINT '>>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 
		
		PRINT '>>> Inserting Data: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\Errol\OneDrive\Freelancer\_DND Labs UG\SQL Cloud\12 Projects\DATA Warehouse Project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
		WITH (
			Firstrow = 2, 
			Fieldterminator = ',', 
			Tablock	
		);
		
		PRINT '>>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
		SET @end_time = GetDate ()
		PRINT '>>> Load Duration: ' + Cast(Datediff(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------------------------------------';
		-- SELECT * FROM bronze.erp_px_cat_g1v2 
		
		SET @batch_end_time = GetDate ()
		PRINT '----------------------------------'
		PRINT 'Loading Bronze Layer is completed';
		PRINT ' - Total Load duration: ' + Cast(Datediff(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------------------------';	
		
	END TRY
	BEGIN CATCH
		PRINT '-----------------------------------------'
		PRINT 'Error occured during loading Bronze Layer'
		PRINT 'Error Message: ' + Error_Message ();
		PRINT 'Error Message: ' + CAST (Error_Number() AS NVARCHAR);
		PRINT 'Error Message: ' + CAST (Error_State() AS NVARCHAR);
		PRINT '-----------------------------------------'
	END CATCH
END