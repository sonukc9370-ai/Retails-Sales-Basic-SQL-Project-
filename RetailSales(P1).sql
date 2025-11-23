CREATE DATABASE SQL_P1;
CREATE TABLE RetailSales_Info(
	transactions_id INTEGER ,
	sale_date DATE,
	sale_time TIME,
	customer_id INTEGER,
	gender VARCHAR(6),
	age INTEGER,
	category VARCHAR(15),
	quantiy INTEGER,
	price_per_unit DECIMAL,
	cogs DECIMAL,
	total_sale INTEGER
);

-- Data Imported Using Import Wizard of MySQL Workbench

-- fetching the imported data 
SELECT * FROM RetailSales_Info LIMIT 20;

-- Data Exploration and Data Cleaning
SELECT Count(*) as total_rows FROM RetailSales_Info;
SELECT Count(distinct customer_id) as Unique_Customers FROM RetailSales_Info;
SELECT Count(transactions_id) as Unique_Transaction FROM RetailSales_Info;
SELECT DISTINCT category FROM RetailSales_Info;
SELECT * FROM RetailSales_Info WHERE
	transactions_id IS NULL OR
    sale_date IS NULL OR
    sale_time IS NULL OR
    customer_id IS NULL OR
    gender IS NULL OR
    age IS NULL OR
    category IS NULL OR
    quantiy IS NULL OR
    price_per_unit IS NULL OR
    cogs IS NULL OR
    total_sale IS NULL;
    
    -- After confirming that only unique value exist in transactions_id, Assigning a Primary key constraint to it,
    ALTER TABLE RetailSales_Info ADD PRIMARY KEY (transactions_id);
    
-- Data Analysis & Findings--
-- Que:1) Write a SQL query to retrieve all columns for sales made on '2022-11-05: 

 SELECT * FROM RetailSales_Info
 WHERE sale_date='2022-11-05';
 

 -- Que:2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and 
 -- the quantity sold is more than or equal to 4 in the month of Nov-2022:
  SELECT * FROM RetailSales_Info WHERE 
  Category='Clothing' AND quantity>=4 AND date_format(sale_date,'%b-%Y') > 'Nov-2022';
  
--  Que:3 Write a SQL query to calculate the total sales  for each category.:
  SELECT 
	Category,
    sum(total_sale) as "Total Sales",
    count(*) as "Total Orders" 
FROM RetailSales_Info
GROUP BY 1;

-- Que:4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT	
	Category, 
    Round(Avg(Age),2) as Average_Age
FROM RetailSales_Info
WHERE Category='Beauty';

-- Que:5 Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT * FROM RetailSales_Info
WHERE total_sale>1000;

-- Que:6 Write a SQL query to find the total number of transactions made by each gender in each category.:
SELECT 
	Category,
    Gender,
	count(transactions_id) as Total_Transactions 
FROM RetailSales_Info
GROUP BY Category,Gender
ORDER BY 1;

-- Que:7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

SELECT 
	Year,
    Month,
    Average_Sale
FROM ( 
SELECT 
	year(sale_date) as Year,
    month(sale_date) as Month,
	Avg(total_sale) As Average_Sale,
    rank() over(partition by year(sale_date) order by avg(total_sale) desc) as rnk
FROM RetailSales_Info
GROUP BY 1,2) x
WHERE x.rnk=1;

-- Que: 8 Write a SQL query to find the top 5 customers based on the highest total sales
SELECT 
	Customer_id,
	sum(total_sale) as Total_Sales 
FROM RetailSales_Info
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Que: 9 Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT
	Category,
    count(distinct customer_id) as Unique_customers
FROM RetailSales_Info
GROUP BY Category;


-- Que: 10) Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale as (
SELECT 
	CASE 
		WHEN hour(sale_time) < 12 THEN 'Morning'
        WHEN hour(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END Shift
FROM retailSales_info )
SELECT
	Shift,
    count(*) as Total_Orders
FROM hourly_sale
GROUP BY Shift
ORDER BY 1;
    
