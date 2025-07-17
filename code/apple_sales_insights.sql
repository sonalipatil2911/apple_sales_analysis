/*** Performance analysis of Apple products across global markets and time frames.***/


-- Find the number of stores in each country.
SELECT 	country,
		COUNT(*) total_stores
FROM stores
GROUP BY 1
ORDER BY 2 DESC;


-- Calculate the total number of units sold by each store.
SELECT 	s.store_id,
		store_name,
		SUM(quantity) AS units_sold
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY 1, 2
ORDER BY 3 DESC;


-- Identify how many sales occurred in December 2023.
SELECT COUNT(sale_id) AS sales_in_DEC2023
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023'


-- Determine how many stores have never had a warranty claim filed.
SELECT COUNT(*) AS stores_not_claimed_warranty
FROM stores
WHERE store_id NOT IN (SELECT DISTINCT store_id FROM sales s RIGHT JOIN warranty w ON s.sale_id = w.sale_id);



-- Calculate the percentage of warranty claims marked as "Rejected".
SELECT ROUND
			(COUNT(claim_id)/(SELECT COUNT(*) FROM warranty)::NUMERIC * 100,
		2) AS percent_rejected
FROM warranty
WHERE repair_status LIKE '%Rejected%' 



-- Identify which store had the highest total units sold in the last year.
SELECT 	store_name,
		SUM(quantity) AS units_sold
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE sale_date >= (SELECT CURRENT_DATE - INTERVAL '1 YEAR')
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1


-- Count the number of unique products sold in the last year.
SELECT	COUNT(DISTINCT product_name) AS unique_products_sold_last_year 
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE sale_date >= (SELECT CURRENT_DATE - INTERVAL '1 YEAR')



-- Find the average price of products in each category.
SELECT 	p.category_id,
		c.category_name,
		AVG(price) AS avg_price
FROM products p 
JOIN category c ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 3 DESC



-- How many warranty claims were filed in 2024?
SELECT COUNT(*) number_claims
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2024
  



-- For each store, identify the best-selling day based on highest quantity sold.
SELECT 	day_name AS best_selling_day,
		store_name
FROM(
	SELECT 	store_name,
			TO_CHAR(sale_date, 'DAY') AS day_name,
			SUM(quantity * price) AS total_sales,
			RANK() OVER(PARTITION BY store_name ORDER BY SUM(quantity * price) DESC) AS rank_n
	FROM sales s
	JOIN stores st ON s.store_id = st.store_id
	JOIN products p ON p.product_id = s.product_id
	GROUP BY 1, 2
)t
WHERE rank_n = 1



-- Identify the least selling product in each country for each year based on total units sold.
SELECT 	sale_year,
		country,
		product_name,
		total_units_sold
FROM(
	SELECT 	EXTRACT(YEAR FROM sale_date) AS sale_year,
			country,
			product_name,
			SUM(quantity) total_units_sold,
			RANK() OVER(PARTITION BY country, EXTRACT(YEAR FROM sale_date) ORDER BY COUNT(quantity) ASC) AS rank_n
	FROM sales s
	JOIN products p ON s.product_id = p.product_id
	JOIN stores st ON s.store_id = st.store_id
	GROUP BY 2, 3, 1
	ORDER BY 1, 4
)t
WHERE rank_n = 1



-- Calculate how many warranty claims were filed within 180 days of a product sale.
SELECT COUNT(*) AS claims_filed_within_180_days
FROM sales s
JOIN warranty w ON s.sale_id = w.sale_id
WHERE (claim_date - sale_date) <= 180 



-- Determine how many warranty claims were filed for products launched in the last two years.
SELECT 	product_name,
		COUNT(w.claim_id) AS total_claims_filed,
		COUNT(s.sale_id) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
LEFT JOIN warranty w ON s.sale_id = w.sale_id
WHERE launch_date >= CURRENT_DATE - INTERVAL '2 YEARS'
GROUP BY 1
HAVING COUNT(w.claim_id) > 0;




-- List the months in the last three years where sales exceeded 5,000 units in the USA.
SELECT 	TO_CHAR(sale_date, 'YYYY-MM'),
		SUM(quantity) AS total_units_sold
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE country LIKE '%United States%'
AND sale_date >= CURRENT_DATE - INTERVAL '3 YEARS'
GROUP BY 1
HAVING SUM(quantity) > 5000




-- Identify the product category with the most warranty claims filed in the last two years.
SELECT category_name, product_name, most_warranty_claims
FROM(
	SELECT 	category_name,
			product_name,
			COUNT(w.claim_id) AS most_warranty_claims,
			DENSE_RANK() OVER(PARTITION BY category_name ORDER BY COUNT(w.claim_id) DESC) AS rank_n
	FROM sales s
	JOIN products p ON s.product_id = p.product_id
	JOIN warranty w ON s.sale_id = w.sale_id
	JOIN category c ON c.category_id = p.category_id
	WHERE claim_date >= CURRENT_DATE - INTERVAL '2 YEARS'
	GROUP BY 1, 2
)a
WHERE rank_n = 1




-- Determine the percentage chance of receiving warranty claims after each purchase for each country.
SELECT *,
		ROUND(
			(total_claims::numeric / total_sales::numeric) * 100, 
			2)AS claim_percentage
FROM(
	SELECT 	country,
			COUNT(DISTINCT s.sale_id) AS total_sales,
			COUNT(w.claim_id) AS total_claims
	FROM sales s
	LEFT JOIN warranty w ON s.sale_id = w.sale_id
	JOIN stores st ON s.store_id = st.store_id
	GROUP BY 1
)t
ORDER BY 2 DESC




-- Analyze the year-by-year growth ratio for each store.
WITH cte_check_revenue AS
(
	SELECT  st.store_id,
			EXTRACT(YEAR FROM sale_date),
			SUM(quantity * price) AS revenue,
			LAG(SUM(quantity * price)) OVER(PARTITION BY st.store_id ORDER BY EXTRACT(YEAR FROM sale_date)) AS last_year_rev
	FROM sales s
	JOIN products p ON s.product_id = p.product_id
	JOIN stores st ON s.store_id = st.store_id
	GROUP BY 1, 2 
	ORDER BY 1, 2
)
SELECT *,
		ROUND(
			CASE
				WHEN last_year_rev > 0 THEN (((revenue-last_year_rev)/last_year_rev)*100)::numeric
				ELSE NULL
			END, 2
		)AS growth_ratio
FROM cte_check_revenue
WHERE last_year_rev IS NOT NULL



-- Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.
SELECT 
		CASE
			WHEN p.price < 500  THEN 'lower cost'
			WHEN p.price BETWEEN 500 AND 1000 THEN 'moderate cost'
			ELSE 'High cost'
		END AS price_segment,
		COUNT(w.claim_id) AS total_claim
FROM warranty AS w 
LEFT JOIN sales AS s ON s.sale_id = w.sale_id
JOIN products AS p ON p.product_id = s.product_id
WHERE claim_date >= CURRENT_DATE - INTERVAL '5 YEARS'
GROUP BY 1
ORDER BY 2 DESC;



-- Identify the store with the highest percentage of "Completed" claims relative to total claims filed.
WITH cte_completed AS
(
	SELECT  store_id,
			COUNT(claim_id) AS completed
	FROM sales s
	JOIN warranty w ON s.sale_id = w.sale_id
	WHERE repair_status = 'Completed'
	GROUP BY 1
),
cte_repaired AS
(
	SELECT  store_id,
			COUNT(claim_id) AS total_claims
	FROM sales s
	JOIN warranty w ON s.sale_id = w.sale_id
	GROUP BY 1
)
SELECT  cc.store_id,
		total_claims,
		completed,
		ROUND(
			(completed::numeric / total_claims::numeric) * 100, 2
		) AS percent_completed
FROM cte_completed cc 
JOIN cte_repaired cr ON cc.store_id = cr.store_id
ORDER BY 4 DESC



-- Write a query to calculate the monthly running total of sales for each store over the past four years 
-- and compare trends during this period.
WITH cte_monthly_sales AS
(
	SELECT  store_id,
			EXTRACT(YEAR FROM sale_date) AS sale_year,
			EXTRACT(MONTH FROM sale_date) AS sale_month,
			SUM(quantity * price) AS total_sales
	FROM sales s
	JOIN products p ON s.product_id = p.product_id
	WHERE sale_date >= CURRENT_DATE - INTERVAL '4 YEARS'
	GROUP BY 1, 2, 3
	ORDER BY 1, 2, 3
)
SELECT  store_id,
	    sale_year,
    	sale_month,
    	total_sales,
		SUM(total_sales) OVER(PARTITION BY store_id ORDER BY sale_year, sale_month) AS running_sale
FROM cte_monthly_sales
ORDER BY 1, 2, 3



-- Analyze product sales trends over time, segmented into key periods: 
-- from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
SELECT 
    p.product_name,
    CASE 
        WHEN s.sale_date < p.launch_date + INTERVAL '6 months' THEN '0–6 months'
        WHEN s.sale_date < p.launch_date + INTERVAL '12 months' THEN '6–12 months'
        WHEN s.sale_date < p.launch_date + INTERVAL '18 months' THEN '12–18 months'
        ELSE '18+ months'
    END AS launch_period,
    SUM(s.quantity * p.price) AS total_sales
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date >= p.launch_date
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- Makes trend comparison easier. for example, spotting if products peak early or show slow, steady growth.













