-- Data Cleaning

SELECT *
FROM layoffs;


-- 1. Remove Duplicates
-- 2. Standardise the data
-- 3. Null Values & Blank Values
-- 4. Remove Columns that are unneccessary

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT layoffs_staging
SELECT*
FROM layoffs;

-- the reason why I have made a duplicate table is because we are about to change the raw data, and if there is a mistake we want the raw data available

-- 1. Remove Duplicates

SELECT*,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num -- backticks because `date` is a KW in MYSQL. Also partion over all columns. 
FROM layoffs_staging
;

WITH duplicate_cte AS -- this will show the duplicates as all the rows with 1 are unique values, if 2 above there means duplicates
(SELECT*,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;

SELECT * -- checking to see if duplicates there are before removing
FROM layoffs_staging
WHERE company = 'Casper';

WITH duplicate_cte AS
(SELECT*,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
DELETE 
FROM duplicate_cte
WHERE row_num > 1; -- this will not work because you cannot update from a CTE table. Instead, need to make a new database where you can filter by row nums and delete any with a 2. 

CREATE TABLE `layoffs_staging2` ( -- creating table
  `company` text, -- column and then datatype
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * -- table will be without values
FROM layoffs_staging2;

INSERT INTO layoffs_staging2 -- inputting values into table with a row number attached from table above
SELECT*,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT * -- finding duplicates
FROM layoffs_staging2
WHERE row_num > 1;

DELETE -- deleting duplicates
FROM layoffs_staging2
WHERE row_num > 1
 ;
 
 SELECT * -- running query without duplicates
FROM layoffs_staging2
;

-- Sometimes they'll be unique columns which makes it easier to remove dupilcates but because we did not have that we had to work around it. 
-- To recap, assigned a row number, any other that was more than 1 was not a unique value so we had to remove the duplicates
-- To do that, we had to see what had row number 2. Once established, we had to create a new table with the row numbers assigned to make it easier to remove the duplicates. 
-- We were then able to run the new table without the duplicates

-- 2. Standardizing Data -- Finding issues in data and fixing it
-- The plan is to go through each column 1 by 1 and see if there are differences or mistakes with the data, and updating the data so its standardised and the same
SELECT distinct company
FROM layoffs_staging2
;
SELECT distinct company, TRIM(company)
FROM layoffs_staging2
;
UPDATE layoffs_staging2
SET company = trim(company)
;
SELECT distinct industry
FROM layoffs_staging2
ORDER BY industry
;
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;
UPDATE layoffs_staging2
SET industry = 'Crypto' 
WHERE industry LIKE 'Crypto%'
;
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;
SELECT distinct industry
FROM layoffs_staging2
ORDER BY industry
;
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;
;
SELECT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1
;
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) AS triming_fullstop 
FROM layoffs_staging2
ORDER BY 1
;
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%'
;
SELECT *
FROM layoffs_staging2
;
SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y') -- this will convert the data from a text format to a date format
from layoffs_staging2
;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;
SELECT `date`
FROM layoffs_staging2
;
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- 3. Null Values & Blank Values

SELECT *
FROM layoffs_staging2; -- show everything to see which is possibly blank or null 

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL -- although this is NULL, hard to update data for this as we don't have the data for it (no total to work out percentage and total so can't use formulas to work out) 
;

SELECT DISTINCT industry
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry =''; -- if there are some companies that have the industry, we can use that info to update the ones that do not 

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb' 
;

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL OR t2.industry !='') -- join tables to see the same companies with the industry info and without it 
;

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND (t2.industry IS NOT NULL OR t2.industry !='') -- just to see the above but only industry column 
;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL -- Tried to update values where they were Null, however this did not work as some of them were blank
;

UPDATE layoffs_staging2 
SET industry = NULL
WHERE industry = '' -- Instead, have to update the blank values to null, and then run the query above again to update the null values to industry data
;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%' -- the reason bally didn't update with a industry is because there was not another one, so no data for it. 
;

SELECT *
FROM layoffs_staging2
WHERE stage = 'Unknown' -- Next, I want to find any stage which is unknown to see if i can find out if there is any same company thawt does have one 
;

SELECT *
FROM layoffs_staging2
WHERE company = '2TM' -- Checked to see if a company had data elsewhere for stage
;

SELECT *
FROM layoffs_staging2 ts1
JOIN layoffs_staging2 ts2
	ON ts1.company = ts2.company
WHERE ts1.stage = 'Unknown'
AND ts2.stage != 'Unknown' -- i wanted to join together the company's that had stage data so i could update the table to make sure they have them
;

UPDATE layoffs_staging2 ts1
JOIN layoffs_staging2 ts2
	ON ts1.company = ts2.company
SET ts1.stage = ts2.stage
WHERE ts1.stage = 'Unknown'
AND ts2.stage != 'Unknown' -- this updated any company without a stage to to have stage data as we could take it from where the company had it elswhere on the database
;

SELECT *
FROM layoffs_staging2 
WHERE stage = 'Unknown'
;

-- 4. Remove Columns - is there any columns we can take that are not relevant

SELECT * 
FROM layoffs_staging2
;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL; -- if no data, will be pointless as we don't know for sure how much was laid off so can get rid

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL -- Can't trust data. Using DELETE will remove the rows
;

SELECT *
FROM layoffs_Staging2
;

ALTER TABLE layoffs_staging2
DROP column row_num -- using DROP will delete the column, DELETE is to remove a row. 
;