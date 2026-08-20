-- 1. DATA STANGING
CREATE DATABASE world_layoffs;
USE world_layoffs;

/*
Note: The date column is imported as text because its format in the raw file does not meet SQL standards. 
This will be fixed during the standardization stage.
*/

CREATE TABLE layoffs (
    company TEXT,
    `location` TEXT,
    industry TEXT,
    total_laid_off TEXT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions TEXT
);

-- Create staging table for safe data cleaning

SELECT * 
FROM world_layoffs.layoffs;

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;


INSERT INTO layoffs_staging 
SELECT * 
FROM world_layoffs.layoffs;

-- 2.REMOVE DUPLICATES

/* 
Verification Query - run manually to inspect duplicate records before deletion

SELECT *
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
        ) AS row_num
    FROM world_layoffs.layoffs_staging
) duplicates
WHERE row_num > 1;
*/

-- Create target staging table with a row_num column
CREATE TABLE `world_layoffs`.`layoffs_staging2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` TEXT,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` TEXT,
  `row_num` INT
);

-- Insert data while partitioning and numbering duplicate rows
INSERT INTO `world_layoffs`.`layoffs_staging2`
SELECT 
    `company`,
    `location`,
    `industry`,
    `total_laid_off`,
    `percentage_laid_off`,
    `date`,
    `stage`,
    `country`,
    `funds_raised_millions`,
    ROW_NUMBER() OVER (
        PARTITION BY company, location, industry, total_laid_off, 
                     percentage_laid_off, `date`, stage, country, funds_raised_millions
    ) AS row_num
FROM world_layoffs.layoffs_staging;

-- Delete identified duplicates
DELETE 
FROM world_layoffs.layoffs_staging2
WHERE row_num >= 2;

--Drop the temporary helper column
ALTER TABLE world_layoffs.layoffs_staging2
DROP COLUMN row_num;

-- 3. DATA STANDARDIZATION

-- Convert literal 'NaN', 'NULL', and empty strings to actual database NULLs
UPDATE world_layoffs.layoffs_staging2
SET total_laid_off = NULLIF(NULLIF(NULLIF(total_laid_off, 'NaN'), 'NULL'), ''),
    percentage_laid_off = NULLIF(NULLIF(NULLIF(percentage_laid_off, 'NaN'), 'NULL'), ''),
    funds_raised_millions = NULLIF(NULLIF(NULLIF(funds_raised_millions, 'NaN'), 'NULL'), ''),
    `date` = NULLIF(NULLIF(NULLIF(`date`, 'NaN'), 'NULL'), ''),
    industry = NULLIF(NULLIF(NULLIF(industry, 'NaN'), 'NULL'), ''),
    stage = NULLIF(NULLIF(NULLIF(stage, 'NaN'), 'NULL'), '');

--Change date format from MM/DD/YYYY to YYYY-MM-DD
UPDATE world_layoffs.layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Modify column data types in the table schema
ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN `date` DATE,
MODIFY COLUMN total_laid_off INT,
MODIFY COLUMN percentage_laid_off DOUBLE,
MODIFY COLUMN funds_raised_millions INT;