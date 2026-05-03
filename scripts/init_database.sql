/*
===============================================================================
DDL Script: Create Database and Schemas
===============================================================================
Script Purpose:
    Creates the DataWarehouse database and the three schemas:
    bronze, silver, and gold.

WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists.
    All data will be permanently deleted. Proceed with caution and ensure
    you have proper backups before running this script.

-------------------------------------------------------------------------------
NOTE: TWO VERSIONS IN THIS FILE
-------------------------------------------------------------------------------
    DBeaver Version (above):
    - Run statements individually or in sequence
    - No GO batch separators
    - No USE statements
    - Set the target database manually in your DBeaver connection

    SSMS Version (below, commented out):
    - Uses GO batch separators and USE statements
    - Required for SQL Server Management Studio
    - Does NOT run in DBeaver
===============================================================================
*/

-- =============================================================================
-- Step 1: Drop and recreate the DataWarehouse database
-- WARNING: Run this manually in DBeaver — confirm before executing!
-- =============================================================================

-- Check and drop existing database (run in master context)
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;

-- Create the DataWarehouse database
CREATE DATABASE DataWarehouse;

-- =============================================================================
-- Step 2: Create Schemas
-- Switch your DBeaver connection to DataWarehouse before running this block
-- =============================================================================

CREATE SCHEMA bronze;

CREATE SCHEMA silver;

CREATE SCHEMA gold;

-- =============================================================================
-- SSMS Version (does NOT run in DBeaver)
-- GO and USE are SSMS-specific batch separators not supported in DBeaver
-- =============================================================================
/*
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
*/