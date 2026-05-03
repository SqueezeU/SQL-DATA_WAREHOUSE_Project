/*
===============================================================================
Execute: Load Bronze Layer
===============================================================================
Script Purpose:
    Executes the stored procedure bronze.load_bronze which truncates all
    Bronze tables and reloads them from the source CSV files.
    
    Run this script after 01_ddl_bronze.sql and 02_proc_load_bronze.sql.
    Run QA checks (04 onwards) only after this script has completed successfully.
===============================================================================
*/

EXEC bronze.load_bronze;