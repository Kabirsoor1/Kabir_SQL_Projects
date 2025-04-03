-- Exploratory Data Analysis 

SELECT *
FROM layoffs_staging2
;

SELECT max(total_laid_off), max(percentage_laid_off)
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER by 2 DESC
;

SELECT min(`date`), max(`date`)
FROM layoffs_staging2
;

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER by 2 DESC
;

SELECT country, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

SELECT `date`, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 2 DESC
;

SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY YEAR(`date`) DESC
;

SELECT location, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY location
ORDER by 2 DESC
;

SELECT country, sum(funds_raised_millions)
FROM layoffs_staging2
GROUP by country
;

SELECT country, COUNT(company) AS how_many_companies, SUM(total_laid_off) AS sum_total_laid_off, AVG(total_laid_off)
FROM layoffs_staging2
GROUP BY country
;

SELECT  SUBSTRING(`date`, 6, 2) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `month`
ORDER by `month`
;

SELECT  SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER by `month`
;

WITH rolling_total AS -- rolling total
(SELECT  SUBSTRING(`date`, 1, 7) AS `month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `month`
ORDER by `month`)

SELECT `month`, total_off, SUM(total_off) OVER(ORDER BY `month`)
FROM rolling_total
;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER by 2 DESC
;

SELECT company, YEAR(`date`), SUM(total_laid_off) -- this shows the amount of lay off by the companies in each year
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
ORDER BY company ASC
;

SELECT company, YEAR(`date`), SUM(total_laid_off) -- shows what company made the most lay offs between 2020 and 2023
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
ORDER BY 3 DESC
;

WITH company_year (company, years, total_sum) AS -- this ranks it by what company had the most lay offs in each year
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_sum DESC) AS most_per_year
FROM company_year
WHERE years IS NOT NULL
ORDER BY most_per_year
;

WITH company_year (company, years, total_sum) AS -- this ranks it by what company had the most lay offs in each year, but we only want to see top 5
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company, YEAR(`date`)
), Company_Rank_Year AS -- SECOND CTE
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_sum DESC) AS most_per_year
FROM company_year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Rank_Year
WHERE most_per_year <= 5 -- allow us to get top 5 ranking in each year instead of a whole list
ORDER by most_per_year
;

SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off) -- find out what industries had most lay offs each year
FROM layoffs_staging2
GROUP by industry, YEAR(`date`)
ORDER BY years
;

WITH industry_years (industry, years, total) AS -- add ranking to the industries to see which was most each year, then we added top 5
(SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry, YEAR(`date`)
ORDER BY years)
, top_five AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total) AS Ranking
FROM industry_years
WHERE years IS NOT NULL AND total IS NOT NULL AND industry IS NOT NULL
ORDER BY Ranking)
SELECT *
FROM top_five
WHERE ranking <= 5
ORDER BY years
;

SELECT *
FROM layoffs_staging2
ORDER BY company
;

SELECT company, COUNT(company), SUM(total_laid_off) -- Shows total occurances of each company, and their total laid off
FROM layoffs_Staging2
GROUP BY company
ORDER BY COUNT(company) DESC
;

WITH company_year_rank AS -- shows top company occurances and total in each year
(SELECT company, COUNT(company) AS count, SUM(total_laid_off) AS total, YEAR(`date`) AS years -- shows total occurances of companies in each year
FROM layoffs_Staging2
GROUP BY company, years
ORDER BY count DESC)
, Ranking_Companies AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY count DESC) AS Ranking
FROM company_year_rank
WHERE years IS NOT NULL
ORDER BY Ranking)
SELECT*
FROM Ranking_Companies
WHERE Ranking <= 1
ORDER BY Ranking
;


