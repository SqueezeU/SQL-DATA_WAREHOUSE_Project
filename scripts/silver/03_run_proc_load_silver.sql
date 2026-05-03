/*
===============================================================================
Execute: Load Silver Layer
===============================================================================
Script Purpose:
    Executes the stored procedure silver.load_silver which truncates all
    Silver tables and reloads them with transformed and cleansed data
    from the Bronze layer.

    Run this script after 01_ddl_silver.sql and 02_proc_load_silver.sql.
    Run QA checks only after this script has completed successfully.
===============================================================================
*/

EXEC silver.load_silver;