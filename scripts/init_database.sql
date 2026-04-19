/*
    Script: init_database.sql
    Description: Creates the DataWarehouse database with three schemas
    within the database: 'bronze', 'silver', and 'gold'.

    WARNING:
        Running this script will drop the entire 'DataWarehouse' database if it exists.
        All data in the database will be permanently deleted. Proceed with caution
        and ensure you have proper backups before running this script.
*/

USE master;

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END

-- Create the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;

-- Create Schemas
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
