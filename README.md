# 🛍️ Retail Sales Analysis SQL Project

## 📌 Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner to Intermediate  
**Database**: `SQL_P1`

This project demonstrates a comprehensive analysis of retail sales data using SQL (MySQL). The goal is to transform raw sales data into actionable insights regarding customer behavior, product performance, and sales trends.

The analysis covers the entire data pipeline: from database setup and data cleaning to advanced exploratory data analysis (EDA) using complex queries, window functions, and CTEs.

---

## 🛠️ Tech Stack
* **Database**: MySQL 8.0
* **Language**: SQL (DDL, DML, DQL, TCL)
* **Tools**: MySQL Workbench

---

## 🗄️ Database Architecture

The project utilizes a relational database named `SQL_P1` with a main table `RetailSales_Info`.

**Schema Structure:**

```sql
CREATE DATABASE SQL_P1;

CREATE TABLE RetailSales_Info(
    transactions_id INTEGER PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INTEGER,
    gender VARCHAR(6),
    age INTEGER,
    category VARCHAR(15),
    quantity INTEGER,
    price_per_unit DECIMAL,
    cogs DECIMAL,
    total_sale INTEGER
);
```

##🧹 Data Preparation & Sanity Checks
Before analysis, the data underwent a rigorous cleaning process. We checked for missing values in critical columns and removed or imputed them to ensure reliability.

  ```sql
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
```

##📝 Analysis & Solutions
Here are the solutions to the key business questions posed during the analysis.

### 1. Shift Analysis (Morning, Afternoon, Evening)
**Question:** Write a SQL query to categorize orders into shifts (Morning <12, Afternoon 12-17, Evening >17) and count orders per shift.

**Reasoning:** Uses Common Table Expressions (CTE) and CASE statements to bin continuous time data into discrete categories.
```sql
WITH hourly_sale AS (
    SELECT 
        CASE 
            WHEN HOUR(sale_time) < 12 THEN 'Morning'
            WHEN HOUR(sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END as Shift
    FROM RetailSales_Info
)
SELECT 
    Shift,
    COUNT(*) as Total_Orders 
FROM hourly_sale
GROUP BY Shift
ORDER BY Total_Orders DESC;
```

### 2. Trend Analysis (Best Selling Months)
**Question:** Calculate the average sale for each month and identify the best-selling month in each year.

**Reasoning:** Utilizes Window Functions (RANK()) and subqueries to isolate top performers within partition groups.
```sql
SELECT 
    Year,
    Month,
    Average_Sale
FROM (
    SELECT 
        YEAR(sale_date) as Year,
        MONTH(sale_date) as Month,
        AVG(total_sale) as Average_Sale,
        RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) as rnk
    FROM RetailSales_Info
    GROUP BY 1, 2
) as x
WHERE x.rnk = 1;
```

### 3. Customer Demographics
**Question:** Find the total number of transactions made by each gender in each category.

**Reasoning:** Demonstrates multivariate aggregation.
```sql
SELECT 
    Category,
    Gender,
    COUNT(transactions_id) as Total_Transactions 
FROM RetailSales_Info
GROUP BY Category, Gender
ORDER BY Category;
```

## Standard Analysis Queries
<details> 
<summary><strong>Click here to view solutions for Basic Analysis (Q1-Q5, Q8-Q9)</strong></summary>

### Q1. Sales on Specific Date
```sql
SELECT * FROM RetailSales_Info WHERE sale_date = '2022-11-05';
```

### Q2. High Volume Clothing Sales (Nov 2022)
```sql
SELECT * FROM RetailSales_Info 
WHERE Category = 'Clothing' 
AND quantity >= 4 
AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11';
```

### Q3.Total Sales by Category
```sql
SELECT 
    Category, 
    SUM(total_sale) as Net_Sales, 
    COUNT(*) as Total_Orders 
FROM RetailSales_Info 
GROUP BY Category;
```

### Q4. Average Age for 'Beauty' Customers
```sql
SELECT Round(Avg(Age), 2) as Avg_Age FROM RetailSales_Info WHERE Category = 'Beauty';
```

### Q5.High Value Transactions (>1000)
```sql
SELECT * FROM RetailSales_Info WHERE total_sale > 1000;
```

### Q8. Top 5 Customers by Spending
```sql
SELECT customer_id, SUM(total_sale) as total_spend
FROM RetailSales_Info
GROUP BY customer_id
ORDER BY total_spend DESC
LIMIT 5;
```

### Q9. Unique Customers per Category
```sql
SELECT Category, COUNT(DISTINCT customer_id) as unique_shoppers
FROM RetailSales_Info
GROUP BY Category;
```


## Key Insights & Final Thoughts
Based on the analysis, the following patterns emerged:

1. **Peak Hours:** The majority of sales occur during the Afternoon shift, suggesting a need for higher staffing levels between 12 PM and 5 PM.

2. **Demographics:** The Beauty category is popular among a specific age demographic (Avg Age: ~XX), which can inform targeted ad campaigns.

3. **Seasonality:** Sales spikes are consistent in specific months (identified in Query 2), indicating seasonal demand.
