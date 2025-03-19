-- SQL Retail Sales Analysis - P1

-- Topics: 
	-- Database & Table Management – CREATE DATABASE, CREATE TABLE, ALTER TABLE, DROP TABLE
	-- Data Insertion & Retrieval – INSERT INTO, SELECT, LIMIT
    -- Data Cleaning – Handling NULL values with WHERE IS NULL, DELETE
	-- Filtering Data – WHERE, AND, OR, BETWEEN, IN, LIKE
	-- Aggregations – COUNT, SUM, AVG, DISTINCT
	-- Grouping & Ordering – GROUP BY, ORDER BY
	-- Date & Time Functions – EXTRACT(YEAR | MONTH | HOUR FROM date_column), TO_CHAR()
	-- Subqueries & Common Table Expressions (CTEs) – WITH ... AS, nested SELECT statements
	-- Window Functions – RANK() OVER(PARTITION BY ... ORDER BY ...)
	-- Case Statements – CASE WHEN ... THEN ... END (for shift classification)

CREATE DATABASE sql_project_p1;

-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

SELECT * FROM retail_sales
LIMIT 10


    

SELECT 
    COUNT(*) 
FROM retail_sales

-- Data Cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL

SELECT * FROM retail_sales
WHERE sale_date IS NULL

SELECT * FROM retail_sales
WHERE sale_time IS NULL

SELECT * FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;
    
-- 
DELETE FROM retail_sales
WHERE 
    transaction_id IS NULL
    OR
    sale_date IS NULL
    OR 
    sale_time IS NULL
    OR
    gender IS NULL
    OR
    category IS NULL
    OR
    quantity IS NULL
    OR
    cogs IS NULL
    OR
    total_sale IS NULL;

-- The table has mistakenly created by wrong column name quantiy instead of quantity, edit the table to change the column name

ALTER TABLE retail_sales
RENAME COLUMN  quantiy to quantity;

-- Import data, making sure the first row is taken as headers
    
-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales

-- How many unique customers we have ?

SELECT COUNT(DISTINCT customer_id) as total_sale FROM retail_sales



SELECT DISTINCT category FROM retail_sales


-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 2 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)



 -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

-- METHOD 1
SELECT 
            *
FROM retail_sales 
            WHERE category = 'Clothing' 
	AND
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity > 2;

-- METHOD 2
SELECT 	*
FROM retail_sales 
	WHERE category = 'Clothing' 
	AND
	Extract(MONTH FROM sale_date) = '11'
	AND
            Extract(YEAR FROM sale_date) = '2022'
	AND
	quantity > 2;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'


-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT * FROM retail_sales
WHERE total_sale > 1000


-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1


-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1
    
-- ORDER BY 1, 3 DESC

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT
 customer_id
FROM (SELECT 
customer_id,
count(DISTINCT(category)) as count_of_distinct_categories
FROM 
retail_sales
GROUP BY customer_id 
)
WHERE count_of_distinct_categories = 3

-- Q.10 Write a SQL query to find the total number of unique customers for each category of items
SELECT
	category,
	count(distinct(customer_id))
	FROM
	retail_sales
	Group by category	

-- Q.11 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- METHOD 1 : Using CTE

With hourly_sale AS
( SELECT 
	*,
	CASE
            WHEN Extract( Hour from sale_time) < 12  THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) >= 12 AND EXTRACT(HOUR FROM sale_time) < 17   THEN 'Afternoon'
            ELSE 'Evening'
            END as shift
	FROM 
	retail_sales )
SELECT shift, count(*) as number_of_orders FROM  hourly_sale Group by shift

-- METHOD 2 : Not using of CTE
SELECT
            CASE
	WHEN Extract( Hour from sale_time) < 12  THEN 'Morning'
	WHEN EXTRACT(HOUR FROM sale_time) >= 12 AND EXTRACT(HOUR FROM sale_time) < 17   THEN 'Afternoon'
	ELSE 'Evening'
	END AS shift,
	COUNT(*) AS number_of_orders
FROM retail_sales
GROUP BY 1;


-- End of project

