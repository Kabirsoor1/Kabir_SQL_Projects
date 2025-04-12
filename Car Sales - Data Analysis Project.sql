-- Car Sales - Data Analysis Project

SELECT *
FROM carsales
;

SELECT DISTINCT manufacturer 
FROM carsales
;

-- These are some of the questions I am going to answer. I downloaded a dataset from online and asked ChatGPT to give me some questions I could answer. 

/* Sales Performance & Trends
1.Which manufacturer sold the most cars overall? 
2.What are the top 5 models by total sales volume? 
3.Which models had sales above the average?
4.Which manufacturers had models that underperformed in sales (bottom 10%)?

Revenue & Pricing
5.What is the average sale price per manufacturer?
6.Which models generate the most revenue (Sales × Price)?
7.Which manufacturers offer the best resale value on average?
8.What’s the price range (min, max, avg) for each manufacturer?

Performance vs. Price
9.Is there a correlation between horsepower and price?
10.Which models provide the best horsepower per dollar?
11.Are more fuel-efficient cars cheaper or more expensive on average?
12. How does engine size affect pricing across different manufacturers?
 
Market Fit & Product Strategy
13.Which models are the most fuel-efficient but also have high sales?
14.Which manufacturers focus more on performance (high horsepower, price) vs economy (low price, high fuel efficiency)?
15.What’s the average resale value per manufacturer — and how does that compare to price?

Launch Timing Insights
16.Are newer models (based on Latest_Launch) priced higher on average?
17.Which manufacturers have launched the most new models in the past year?
18.What’s the relationship between latest launch date and sales volume?

Weight, Size & Efficiency
19.Do heavier cars tend to have lower fuel efficiency?
20.Which models are the most compact but offer strong performance (power per weight)? */

-- 1. Which manufacturer sold the most cars overall?

SELECT *
from carsales
;

SELECT manufacturer, sum(sales_in_thousands)
from carsales
GROUP BY Manufacturer
;

-- this will allow me to see how much they made in 1000s
SELECT manufacturer, sum(sales_in_thousands), (sum(sales_in_thousands) *1000) 
from carsales
GROUP BY Manufacturer
;

-- this will allow me to see sales rounded to nearest thousand
SELECT manufacturer, sum(sales_in_thousands), (sum(sales_in_thousands) *1000), ROUND((sum(sales_in_thousands) *1000))
from carsales
GROUP BY Manufacturer
;

SELECT manufacturer, ROUND((sum(sales_in_thousands) *1000)) AS total_Sales
from carsales
GROUP BY Manufacturer
ORDER BY total_sales DESC
LIMIT 1
;

-- 2.What are the top 5 models by total sales volume?

SELECT model, SUM(sales_in_thousands) AS total_sales, ROUND((sum(sales_in_thousands) *1000))
FROM carsales
GROUP BY model
ORDER BY total_sales DESC
LIMIT 5
;

-- 3.Which models had sales above the average?
SELECT avg(sales_in_thousands)
from carsales
;

SELECT model, SUM(sales_in_thousands) AS total_sales
FROM carsales
GROUP BY model
ORDER BY total_sales DESC
;

SELECT model, SUM(sales_in_thousands) AS total_sales
FROM carsales
GROUP BY model
HAVING SUM(sales_in_thousands) > (SELECT AVG(sales_in_thousands) FROM carsales)
ORDER BY total_sales DESC;

-- 4a.Which manufacturers underperformed in sales (bottom 10%)?

SELECT SUM(sales_in_thousands) * 0.1
FROM carsales
;

SELECT manufacturer, sum(Sales_in_thousands) AS total_Sales
FROM carsales
GROUP BY manufacturer
ORDER by total_Sales DESC
;

SELECT manufacturer, SUM(sales_in_thousands) AS total_Sales
FROM carsales
GROUP BY manufacturer
HAVING SUM(sales_in_thousands) <= (SELECT SUM(sales_in_thousands) * 0.1
FROM carsales) 
ORDER BY total_Sales DESC
;

-- 4b.Which manufacturers had models that underperformed in sales (bottom 10%)?

SELECT manufacturer, model, sales_in_thousands
FROM carsales
ORDER by Sales_in_thousands
;

WITH percentage_model AS 
(SELECT Manufacturer, model, Sales_in_thousands, PERCENT_RANK () OVER (ORDER BY sales_in_thousands) AS pct_rank
FROM carsales)

SELECT manufacturer, model, sales_in_thousands, ROUND(pct_rank, 2)
FROM percentage_model
WHERE pct_rank <= 0.1
;

-- 5a.What is the average sale price per manufacturer?

SELECT *
from carsales
;

-- I can see that Acura CL is missing a price, so i will make sure to only get an average on the ones that have a price

SELECT manufacturer, ROUND(AVG(price_in_thousands) * 1000, 2)AS price
FROM carsales
WHERE price_in_thousands IS NOT NULL
GROUP BY manufacturer
;

-- I multiplied by 1000 and also rounded it to 2 dp so that I could get a more accurate answer 

-- 5b. Which manufacturer has the most expensive average price
SELECT manufacturer, ROUND(AVG(price_in_thousands) * 1000, 2)AS price
FROM carsales
WHERE price_in_thousands IS NOT NULL
GROUP BY manufacturer
ORDER by price DESC
LIMIT 1
;

-- 5C. Which manufacturer has the least expensive average price
SELECT manufacturer, ROUND(AVG(price_in_thousands) * 1000, 2)AS price
FROM carsales
WHERE price_in_thousands IS NOT NULL
GROUP BY manufacturer
ORDER by price ASC
LIMIT 1
;

-- 6.Which models generate the most revenue (Sales × Price)?

SELECT *
FROM carsales
;

SELECT Manufacturer, model, Sales_in_thousands, Price_in_thousands, (sales_in_thousands * price_in_thousands) AS total_rev
FROM carsales
ORDER by total_rev DESC
;

SELECT Manufacturer, model, Sales_in_thousands, Price_in_thousands, ROUND((sales_in_thousands * price_in_thousands) * 1000, 2) AS total_rev
FROM carsales
ORDER by total_rev DESC
LIMIT 5
;

-- 7.Which manufacturers offer the best resale value on average?

SELECT *
FROM carsales
;

SELECT manufacturer, AVG(__year_resale_value) * 1000 AS resale_price
FROM carsales
GROUP by Manufacturer
ORDER by resale_price DESC
LIMIT 5
;

-- 8.What’s the price range (min, max, avg) for each manufacturer?

SELECT *
FROM carsales
;

SELECT manufacturer, MIN(price_in_thousands), MAX(price_in_thousands), AVG(price_in_thousands)
FROM carsales
GROUP BY manufacturer
;

-- 9.Is there a correlation between horsepower and price?
-- Don't have the capabiltiies to work this one out yet

-- 10.Which models provide the best horsepower per dollar?

SELECT *
FROM carsales
;

SELECT manufacturer, model, price_in_thousands * 1000 AS price, horsepower, ROUND(horsepower / (price_in_thousands * 1000) , 4) AS horsepower_per_dollar
FROM carsales
ORDER by horsepower_per_dollar DESC
LIMIT 5
;

-- 11.Are more fuel-efficient cars cheaper or more expensive on average?
SELECT *
FROM carsales
;

SELECT manufacturer, model, price_in_thousands, fuel_efficiency
FROM carsales
ORDER by Fuel_efficiency DESC
;

WITH fuel_efficiency_ranks AS
(SELECT
CASE
WHEN fuel_efficiency between 15 and 25 THEN 'low efficiency'
WHEN fuel_efficiency between 25 and 35 THEN 'med efficiency'
ELSE 'high efficiency'
END efficiency_ranks, ROUND(AVG(price_in_thousands) * 1000, 2) AS avg_price_fuel_efficiency
FROM carsales
GROUP BY efficiency_ranks
ORDER BY avg_price_fuel_efficiency)

-- this will allow me to see what the answer to the question would be
SELECT *
FROM fuel_efficiency_ranks
LIMIT 1
;

-- 12. How does engine size affect pricing across different manufacturers?

SELECT *
FROM carsales
;

SELECT manufacturer, engine_size, AVG(price_in_thousands) * 1000
FROM carsales
GROUP BY manufacturer, engine_size
ORDER BY manufacturer, engine_size
;

-- 13.Which models are the most fuel-efficient but also have high sales?

SELECT manufacturer, model, fuel_efficiency, Sales_in_thousands * 1000 AS sales
FROM carsales
ORDER BY Fuel_efficiency DESC, sales DESC
;

-- 14.Which manufacturers focus more on performance (high horsepower, price) vs economy (low price, high fuel efficiency)?

SELECT manufacturer, AVG(horsepower), ROUND(AVG(price_in_thousands * 1000), 2), AVG(fuel_efficiency)
FROM carsales
GROUP by manufacturer
ORDER by AVG(horsepower) DESC, ROUND(AVG(price_in_thousands * 1000), 2) DESC, AVG(fuel_efficiency) DESC
;

-- 15.What’s the average resale value per manufacturer — and how does that compare to price?

SELECT *
FROM carsales
;

SELECT manufacturer, ROUND(AVG(__year_resale_value) * 1000, 2), ROUND(AVG(price_in_thousands) * 1000, 2),
 ROUND((AVG(__year_resale_value) / AVG(price_in_thousands)) * 100, 2) AS resale_percent
FROM carsales
GROUP BY Manufacturer
;

-- 16. Are newer models (based on Latest_Launch) priced higher on average?

SELECT *
FROM carsales
;

SELECT model, price_in_thousands * 1000, latest_launch
FROM carsales
ORDER BY latest_launch 
;

-- I have noticed that the dates are not consistent, for example some have 09 & some have 0 - these will need to be corrected

SELECT latest_launch
FROM carsales
ORDER BY latest_launch 
;

UPDATE carsales
SET latest_launch = DATE_FORMAT(STR_TO_DATE(latest_launch, '%m/%d/%Y'), '%Y-%m-%d')
;

SELECT model, ROUND(price_in_thousands * 1000, 2), latest_launch
FROM carsales
ORDER BY latest_launch DESC, price_in_thousands DESC
;

SELECT model,
CASE
WHEN latest_launch LIKE '2012%' THEN 'New'
WHEN latest_launch LIKE '2011%' THEN 'Med'
ELSE 'Old'
END age_of_car,
AVG(Price_in_thousands *1000) AS avg_price_of_year_car
FROM carsales
GROUP BY model, age_of_car
ORDER BY avg_price_of_year_car DESC
;

-- the above query shows the average price per model within each age group, not the average price per age group, so instead i want to just group by age: 

SELECT 
CASE
WHEN latest_launch LIKE '2012%' THEN 'Newer'
WHEN latest_launch LIKE '2011%' THEN 'Middle'
ELSE 'Older'
END age_of_car,
ROUND(AVG(Price_in_thousands *1000), 2) AS avg_price_of_year_car
FROM carsales
GROUP BY age_of_car
ORDER BY avg_price_of_year_car DESC
;

-- 17.Which manufacturers have launched the most new models in the past year?
SELECT Manufacturer, COUNT(DISTINCT Model) as new_model_counts
FROM carsales
WHERE Latest_Launch LIKE '2012%'
GROUP BY Manufacturer
ORDER BY new_model_counts DESC
;

-- below query just to make sure what I did above was correct and the manufacturers had the right amount of models
SELECT manufacturer, model, latest_launch
from carsales
WHERE latest_launch LIKE '2012%'
;

-- 18.What’s the relationship between latest launch date and sales volume?

SELECT 
CASE
WHEN latest_launch LIKE '2012%' THEN 'Newer'
WHEN latest_launch LIKE '2011%' THEN 'Middle'
ELSE 'Older'
END age_of_model,
ROUND(AVG(sales_in_thousands * 1000), 2) AS avg_sales
FROM carsales
GROUP BY age_of_model
;

-- Final Conclusion - it would have saved me a lot of hassle if I cleaned the data at the start to make sure it was ready for data
-- For example, work out or get rid of the NULL values, format the date correctly, have the correct INT values instead of multiplying each time. 
