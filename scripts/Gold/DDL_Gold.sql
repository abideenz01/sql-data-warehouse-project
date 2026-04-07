/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/


/*We have two sources for Gender info one from CRM and other from ERP
Have to build business logic >> always prefer MASTER TABLE which in our case 
is CRM source system and only in case Master Table is not offering any info
prefer SLAVE tabel*/

-- =============================================================================
-- Create Dimension: Gold.dim_customers
-- =============================================================================

--Connecting crm_cust_info with erp_cust_AZ12 AND erp_LOC_A101
IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO
CREATE VIEW Gold.dim_customers AS --creating view 
SELECT 
ROW_NUMBER() OVER(ORDER BY inf.cst_id) AS customer_key, --generating surrogate key
inf.cst_id AS customer_id, --Re-naming column to friendly names using snake_case
inf.cst_key AS customer_number,
inf.cst_firstname AS first_name,
inf.cst_lastname AS last_name,
loc.CNTRY AS country,
inf.cst_marital_status AS marital_status,
CASE WHEN inf.cst_gndr!= 'n/a' THEN inf.cst_gndr  --CRM is the master for Gender Info
     ELSE COALESCE(bir.GEN,'n/a') --data integration of gender info from CRM and ERP source system
END AS Gender, 
bir.BDATE AS Birthdate,
inf.cst_create_date AS create_date 
FROM Silver.crm_cust_info AS inf
LEFT JOIN Silver.erp_CUST_AZ12 AS bir
ON        inf.cst_key=bir.CID
LEFT JOIN Silver.erp_LOC_A101 AS loc
ON        inf.cst_key=loc.CID

-- =============================================================================
-- Create Dimension: Gold.dim_products
-- =============================================================================


--Connecting crm_prd_info with erp_PX_CAT_G1V2
--Only dealing with current data. No history is required
IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO
CREATE VIEW Gold.dim_products AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key, --generating surrogate key
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.CAT AS category,
pc.SUBCAT AS subcategory,
pc.MAINTENANCE ,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS product_start_date
FROM Silver.crm_prd_info AS pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 AS pc
ON        pn.cat_id= pc.ID
WHERE prd_end_dt IS NULL  --filter out all historical data

SELECT *
FROM Gold.fact_sales

-- =============================================================================
-- Create Fact Table: Gold.fact_sales
-- =============================================================================
IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO
--Creating Fact Sales Table 
CREATE VIEW Gold.fact_sales AS
SELECT 
sd.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS ship_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM Silver.crm_sales_details AS sd
LEFT JOIN Gold.dim_customers AS cu
ON sd.sls_cust_id=cu.customer_id
LEFT JOIN Gold.dim_products As pr
ON sd.sls_prd_key=pr.product_number



