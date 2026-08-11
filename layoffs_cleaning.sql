CREATE DATABASE world_layoffs;
USE world_layoffs;

/*
Note: The date column is imported as text because its format in the raw file does not meet SQL standards. 
This will be fixed during the standardization stage.
*/

CREATE TABLE layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off TEXT,
    percentage_laid_off TEXT,
    date TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions TEXT
);

-- Create staging table for safe data cleaning

SELECT * 
FROM world_layoffs.layoffs;

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * 
FROM world_layoffs.layoffs;
