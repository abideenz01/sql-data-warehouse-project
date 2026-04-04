/*
================================================================================
Quality Checks
================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
================================================================================
*/

-------------Data Quality Checks-----------------
            
            --1st Table from CRM source system-- 

--1. Check for NULLS or Duplicates in the Primary Key
--Primary Key must be unique and NOT NULL
--Expectation: NO RESULT
USE DataWareHouse
SELECT 
cst_id,
COUNT(*) duplicate_values 
FROM Bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL

--2. Check for unwanted spaces--
--Expectation: No Resullt
SELECT 
cst_firstname
FROM Bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) --TRIM removes all leading and trailing values

SELECT * FROM Bronze.crm_cust_info

--Data standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM Bronze.crm_cust_info


--Data Quality Checks of Silver Layer After laoding data into Silver Layer--

--1. Check for NULLS or Duplicates in the Primary Key
--Primary Key must be unique and NOT NULL
--Expectation: NO RESULT
USE DataWareHouse
SELECT 
cst_id,
COUNT(*) duplicate_values 
FROM Silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id IS NULL

--2. Check for unwanted spaces--
--Expectation: No Resullt
SELECT 
cst_firstname
FROM Silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) AND cst_lastname!=TRIM(cst_lastname) --TRIM removes all leading and trailing values



--Data standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM Silver.crm_cust_info

                 --2nd Table from CRM source system--
--1. Check for NULLS or Duplicates in the Primary Key
--Primary Key must be unique and NOT NULL
--Expectation: NO RESULT


SELECT 
prd_id,
COUNT(*) duplicate_values 
FROM Bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL


--2. Check for unwanted spaces--
--Expectation: No Result
SELECT 
prd_nm
FROM Bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) AND prd_nm!=TRIM(prd_nm) --TRIM removes all leading and trailing 



--Check for NULLS Or Negative Numbers 
SELECT 
prd_cost
FROM Bronze.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

--Data standardization and Consistency
SELECT DISTINCT prd_line --Ask data source system experts to identify full abbreviations
FROM Bronze.crm_prd_info

--Check for invalid Date Orders  --prd_end_dt is younger than prd_start_dt 
SELECT * FROM Bronze.crm_prd_info
WHERE prd_end_dt<prd_start_dt

                    
--Data Quality Checks of Silver Layer After laoding data into Silver Layer--

--1. Check for NULLS or Duplicates in the Primary Key
--Primary Key must be unique and NOT NULL
--Expectation: NO RESULT


SELECT 
prd_id,
COUNT(*) duplicate_values 
FROM Silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*)>1 OR prd_id IS NULL


--2. Check for unwanted spaces--
--Expectation: No Result
SELECT 
prd_nm
FROM Silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm) AND prd_nm!=TRIM(prd_nm) --TRIM removes all leading and trailing 



--Check for NULLS Or Negative Numbers 
SELECT 
prd_cost
FROM Silver.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

--Data standardization and Consistency
SELECT DISTINCT prd_line --Ask data source system experts to identify full abbreviations
FROM Silver.crm_prd_info

--Check for invalid Date Orders  --prd_end_dt is younger than prd_start_dt 
SELECT * FROM Silver.crm_prd_info
WHERE prd_end_dt<prd_start_dt

SELECT * FROM 
Silver.crm_prd_info

                   --Third Table from CRM source system--
SELECT * FROM 
Bronze.crm_sales_details

--1. Check for unwanted spaces--
--Expectation: No Result
SELECT 
*
FROM Bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)  --TRIM removes all leading and trailing 


--2. Check for integrity of sls_prd_key in crm_sales_details since we have to connect sls_prd_key of crm_sales_details with prd_key of crm_prd_info
SELECT *
FROM Bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info)

--3. Check for integrity of sls_cust_id in crm_prd_info since we have to connect sls_cust_id of crm_sales_details with cust_id of crm_cust_info
SELECT *
FROM Bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info)

--4. Check for invalid order dates
SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt<=0 OR LEN(sls_order_dt)!=8
OR sls_order_dt > 20500101 OR sls_order_dt< 190001010

--5. Check for invalid dates
SELECT 
NULLIF(sls_due_dt,0) sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_due_dt<=0 OR LEN(sls_due_dt)!=8
OR sls_due_dt > 20500101 OR sls_due_dt< 190001010

--6. Check for invalid dates 
SELECT *
FROM Bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--7.
--Check data consistency between Sales,Quantity and Price 
--Values must not be NULL,Zero OR negative 
-- Business Rule: Sales = Quantity * Price 

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales = 0 OR sls_quantity=0 OR sls_price =0 
OR sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
ORDER BY 
sls_sales,
sls_quantity,
sls_price

--Rules to clean messy sales,quantity and price data 
--1. If Sales is negative,NULL OR Zero. Derive it using quantity and price
--2. If Price is NULL or Zero. Derive it using Sales and Quantity
--3. If Price is negative, convert it into positive.

--Data Quality Checks of Silver Layer After laoding data into Silver Layer--

--1. Check for unwanted spaces--
--Expectation: No Result
SELECT 
*
FROM Silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num)  --TRIM removes all leading and trailing 


--2. Check for integrity of sls_prd_key in crm_sales_details since we have to connect sls_prd_key of crm_sales_details with prd_key of crm_prd_info
SELECT *
FROM Silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM Silver.crm_prd_info)

--3. Check for integrity of sls_cust_id in crm_prd_info since we have to connect sls_cust_id of crm_sales_details with cust_id of crm_cust_info
SELECT *
FROM Silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM Silver.crm_cust_info)


--4. Check for invalid dates 
SELECT *
FROM Silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

--5.
--Check data consistency between Sales,Quantity and Price 
--Values must not be NULL,Zero OR negative 
-- Business Rule: Sales = Quantity * Price 

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM Silver.crm_sales_details
WHERE sls_sales!= sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales = 0 OR sls_quantity=0 OR sls_price =0 
OR sls_sales<=0 OR sls_quantity<=0 OR sls_price<=0
ORDER BY 
sls_sales,
sls_quantity,
sls_price
USE DataWareHouse

          --1st Table from ERP source system-- 
 SELECT 
 CID
 FROM Bronze.erp_CUST_AZ12
 WHERE CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID)) --Remove NAS prefix if present
      ELSE CID
 END NOT IN (SELECT cst_key FROM Silver.crm_cust_info)

 --2. identify Out of Range Date
 --Check for very old birthdays and birthdays in future 
 SELECT 
 BDATE
 FROM Bronze.erp_CUST_AZ12
 WHERE BDATE < '1930-01-10' OR BDATE> GETDATE()

 --3. Data Standardization and Consistency
 SELECT DISTINCT 
 GEN,
 CASE WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
      WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
      ELSE 'n/a'
 END GEN --Normalize gender values and handles unknowns 
 FROM BRONZE.erp_CUST_AZ12

 --Data Quality Checks of Silver Layer After laoding data into Silver Layer

 --1. identify Out of Range Date
 --Check for very old birthdays and birthdays in future 
 --No Transformations for very old birthdays
 --Only future birthdays are handled 
 --Expectation: Only vey old birthdays 

 SELECT 
 BDATE
 FROM Silver.erp_CUST_AZ12
 WHERE BDATE < '1930-01-10' OR BDATE> GETDATE()

 --2. Data Standardization and Consistency
 SELECT DISTINCT 
 GEN
 FROM Silver.erp_CUST_AZ12

 -----2nd Table from ERP source system----- 

 --1. Data matching for connecting keys 
 SELECT 
 REPLACE(CID,'-','') CID --Removing invlaid values
 FROM Bronze.erp_LOC_A101

 --2. Check for data consistency and standardization 
SELECT
CASE  WHEN UPPER(TRIM(CNTRY))='DE' THEN 'Germany'
      WHEN UPPER(TRIM(CNTRY)) IN ('US','USA') THEN 'United States'
      WHEN CNTRY= ' ' OR CNTRY IS NULL THEN 'n/a'
      ELSE TRIM(CNTRY) --Normalize and Handle missing or blank country codes
END AS CNTRY
FROM Bronze.erp_LOC_A101
 
--3.Comparing Distinct values for any anomoly
SELECT DISTINCT
CNTRY AS old_cntry,
CASE  WHEN UPPER(TRIM(CNTRY))='DE' THEN 'Germany'
      WHEN UPPER(TRIM(CNTRY)) IN ('US','USA') THEN 'United States'
      WHEN CNTRY= ' ' OR CNTRY IS NULL THEN 'n/a'
      ELSE TRIM(CNTRY)
END AS CNTRY
FROM Bronze.erp_LOC_A101

 --Data Quality Checks of Silver Layer After laoding data into Silver Layer
SELECT DISTINCT
CNTRY
FROM Silver.erp_LOC_A101

 -----3rd Table from ERP source system----- 
 --1. Removing unmatched ID
 SELECT 
 CASE WHEN ID='CO_PD' THEN 'n/a'
      ELSE ID
 END AS ID,
 CAT,
 SUBCAT,
 MAINTENANCE
 FROM Bronze.erp_PX_CAT_G1V2



 
 --2. checking unwanted spaces
 SELECT *
 FROM BRONZE.erp_PX_CAT_G1V2
 WHERE CAT!=TRIM(CAT) OR SUBCAT!=TRIM(SUBCAT) OR MAINTENANCE!= TRIM(MAINTENANCE)
 
 --3. Data consistency and Standardization 
 SELECT DISTINCT
 *
 FROM BRONZE.erp_PX_CAT_G1V2



















