--*********************************************
--Create Stored Procedures 
--Save frequently used sql code in stored procedures in database
--*********************************************
--Executing Stored Procedure
EXEC Bronze.load_Bronze

CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY 
    SET @start_time=GETDATE()
        PRINT'======================================';
        PRINT'Loading Bronze Layer';
        PRINT'=====================================';
        --Bulk insert data
        --(Truncate & Insert) Truncate/Empty the table and then load data in order to avoid duplicate data loading
        PRINT'Laoding CRM Tables';
        PRINT'======================================';
        SET @start_time = GETDATE()
        PRINT'Truncating Table: Bronze.crm_cust_info';
        TRUNCATE TABLE Bronze.crm_cust_info
        PRINT'Inseritng into:Bronze.crm_cust_info';
        BULK INSERT Bronze.crm_cust_info
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH(            --instructing sql how to handle data
            FIRSTROW= 2,     -- Data starts from 2nd row
            FIELDTERMINATOR= ',',  --seperate data using ,
            TABLOCK  --lock the entire table during data loading
        );
        SET @end_time= GETDATE();
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT'---------'
        --Checking data Quality of Bronze table 
        --2 crucial data quality checks
        --1. Do each column contains data 
        --2. Do data is in correct column

        --SELECT * FROM Bronze.crm_cust_info
        --SELECT COUNT(*) FROM Bronze.crm_cust_info
        PRINT'--------------------------------------------';
        SET @start_time= GETDATE()
        PRINT'Truncating Table: Bronze.crm_prd_info';
        TRUNCATE TABLE Bronze.crm_prd_info
        PRINT'Inserting into:Bronze.crm_prd_info';
        BULK INSERT Bronze.crm_prd_info
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
             FIRSTROW= 2,
             FIELDTERMINATOR= ',',
             TABLOCK
        );
        SET @end_time= GETDATE()
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

        PRINT'----------------------------------------';
        SET @start_time= GETDATE()
        PRINT'Truncating Table:Bronze.crm_sales_details';
        TRUNCATE TABLE Bronze.crm_sales_details
        PRINT'Insering into:Bronze.crm_sales_details';
        BULK INSERT Bronze.crm_sales_details
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
             FIRSTROW= 2,
             FIELDTERMINATOR= ',',
             TABLOCK
        );
        SET @end_time= GETDATE()
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT'===================================';
        PRINT'Laoding ERP Tables';
        PRINT'======================================';
        SET @start_time= GETDATE()
        PRINT'Truncating Table:Bronze.erp_CUST_AZ12';
        TRUNCATE TABLE Bronze.erp_CUST_AZ12
        PRINT'Inserting into:Bronze.erp_CUST_AZ12';
        BULK INSERT Bronze.erp_CUST_AZ12
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
             FIRSTROW= 2,
             FIELDTERMINATOR= ',',
             TABLOCK
        );
        SET @end_time= GETDATE()
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT'------------------------------------';
        SET @start_time= GETDATE()
        PRINT'Truncating Table:Bronze.erp_LOC_A101'
        TRUNCATE TABLE Bronze.erp_LOC_A101
        PRINT'Inserting into:Bronze.erp_LOC_A101'
        BULK INSERT Bronze.erp_LOC_A101
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
             FIRSTROW= 2,
             FIELDTERMINATOR= ',',
             TABLOCK
        );
        SET @end_time= GETDATE()
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

        PRINT'-----------------------------------------';
        SET @start_time= GETDATE()
        PRINT'Truncating Table:Bronze.erp_PX_CAT_G1V2'
        TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2
        PRINT'Inserting into: Bronze.erp_PX_CAT_G1V2'
        BULK INSERT Bronze.erp_PX_CAT_G1V2
        FROM 'C:\Users\LENOVO\Desktop\COMPLETE SQL RESOURCES\SQL data warehouse project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
             FIRSTROW= 2,
             FIELDTERMINATOR= ',',
             TABLOCK
        );
        SET @end_time= GETDATE()
        PRINT'Duration is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT'--------------------------'
        PRINT'Loading Bronze Layer is Completed'
        SET @end_time= GETDATE()
        PRINT'Duration of loading whole bronze layer is :' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';

     END TRY
        BEGIN CATCH 
            PRINT'======================================';
            PRINT'Error Message:' + ERROR_MESSAGE();
            PRINT'Error Message:' + CAST(ERROR_NUMBER()AS NVARCHAR);
            PRINT'Error Message:' + CAST(ERROR_STATE()AS NVARCHAR);
            PRINT'======================================';
        END CATCH 
END



