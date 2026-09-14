# DataRefine: Layoffs Analysis

## Project Overview

This project focuses on cleaning and preparing a real-world layoffs dataset for analysis using MySQL. The goal is to transform raw data into a clean, structured, and consistent dataset by identifying and addressing common data quality issues.

## Data Source
* **Source:** [Kaggle - Layoffs 2022 Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022/data)

* **Raw Data State:** The original file had messy dates and 'NaN' values in numeric fields. To avoid database import errors, all columns were loaded as `TEXT`. This raw import contains 2,361 rows, including duplicate records.

## Data Cleaning Roadmap
* [x] **Data Staging**

  * Created an exact clone (`layoffs_staging`) of the raw dataset to preserve original data integrity.
  * All cleaning operations are executed strictly on staging tables to ensure fully reproducible and reversible workflows.

* [x] **Remove Duplicates**

  * **Logic:** Used `ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions)` to identify unique and repeated rows across all attributes.
  * **Engine Constraint & Solution:** MySQL does not support directly deleting from a CTE/subquery derived from a `ROW_NUMBER()` window function.
  * **Fix:** Engineered a secondary staging table (`layoffs_staging2`) with an explicit `row_num INT` column, populated it, deleted rows where `row_num >= 2`, and subsequently dropped the temporary column.

* [x] **Standardize Data**

  * **Null & String Sanitization:** Replaced literal string artifacts (`'NaN'`, `'NULL'`, `''`) with standard SQL `NULL` values across numeric, date, and text fields using nested `NULLIF()` functions.
  * **Type Casting & Dates:** Converted text-formatted dates (`MM/DD/YYYY`) into proper SQL `DATE` format (`STR_TO_DATE`) and altered table schema column data types (`date` to `DATE`, `total_laid_off` & `funds_raised_millions` to `INT`, `percentage_laid_off` to `DOUBLE`).
  * **Text & Industry Uniformity:** Trimmed leading/trailing whitespace from company names, populated missing industries via self-joins on matching company records, standardized variations under `Crypto`, and consolidated `Fin-Tech` into `Finance`.
  * **Geography & Brand Consistency:** Stripped trailing punctuation from country names, fixed local accent character formatting (e.g., `Düsseldorf`, `Malmö`), and normalized corporate brand casing (e.g., `SalesLoft`, `ByteDance`).

* [x] **Final Cleanup**

  * **Useless Record Removal:** Dropped entries where both `total_laid_off` **and** `percentage_laid_off` were `NULL`, as these missing target metrics provide no actionable quantitative value for downstream analysis.
  * **Result:** Left a fully sanitized, production-ready analytical table (`layoffs_staging2`).
