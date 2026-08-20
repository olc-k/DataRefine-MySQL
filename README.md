# DataRefine: Layoffs Analysis

## Project Overview

This project focuses on cleaning and preparing a real-world layoffs dataset for analysis using MySQL. The goal is to transform raw data into a clean, structured, and consistent dataset by identifying and addressing common data quality issues.

## Data Source
* **Source:** [Kaggle - Layoffs 2022 Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022/data)

* **Raw Data State:** The original file had messy dates and 'NaN' values in numeric fields. To avoid database import errors, all columns were loaded as `TEXT`. This raw import contains 2,361 rows, including duplicate records.

## Data Cleaning Roadmap

* [x] **Data Staging** 
<div style="margin-left: 20px;">
<p>— Created an exact clone (`layoffs_staging`) of the raw dataset to preserve original data integrity.
<p>— All cleaning operations are executed strictly on staging tables to ensure fully reproducible and reversible workflows.
</div>

* [x] **Remove Duplicates**
<div style="margin-left: 20px;">
<p>— <strong>Logic:</strong> Used `ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)` to identify unique vs. repeated rows across all attributes.
<p>— <strong>Engine Constraint & Solution:</strong> MySQL does not support directly deleting from a CTE/subquery derived from a `ROW_NUMBER()` window function. 
<p>— <strong>Fix:</strong> Engineered a secondary staging table (`layoffs_staging2`) with an explicit `row_num INT` column, populated it, deleted rows where `row_num >= 2`, and subsequently dropped the temporary column.  
</div>

* [ ] **Standardize Data** — Address inconsistent values, naming, and formatting across the dataset.
* [ ] **Handle Nulls & Blanks** — Identify missing or incomplete values and determine how they should be handled.
* [ ] **Final Cleanup** — Remove unnecessary columns, rows, or temporary elements and prepare the final cleaned dataset.