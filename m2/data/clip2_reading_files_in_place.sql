-- Clip 2: Reading Files in Place
-- Module 2: Querying External Data
-- Run from the m2/data directory: cd m2/data && duckdb

-- Step 1 – See what files are in the folder
SELECT * FROM glob('*');

-- Step 2 – Query a CSV file
SELECT * FROM read_csv_auto('sales_records.csv')
LIMIT 10;

SELECT region, SUM(units_sold) AS total_units
FROM read_csv_auto('sales_records.csv')
WHERE YEAR(order_date) = 2024
GROUP BY region
ORDER BY total_units DESC;

-- Step 3 – Query a JSON file
SELECT * FROM read_json_auto('events.json')
LIMIT 5;

-- Flatten the nested records array
SELECT UNNEST(records) AS record
FROM read_json_auto('events.json');

-- Pull specific fields using dot notation
SELECT record.event_name, record.city, record.attendees
FROM (
    SELECT UNNEST(records) AS record
    FROM read_json_auto('events.json')
);

-- Step 4 – Query a Parquet file
SELECT region, SUM(units_sold) AS total_units
FROM read_parquet('sales_records.parquet')
WHERE YEAR(order_date) = 2024
GROUP BY region
ORDER BY total_units DESC;

-- Step 5 – Read multiple files at once with a glob pattern
SELECT COUNT(*) AS total_rows FROM read_csv_auto('monthly_sales_*.csv');

-- Verify individual file counts add up
SELECT 'jan' AS file, COUNT(*) FROM read_csv_auto('monthly_sales_jan.csv')
UNION ALL
SELECT 'feb', COUNT(*) FROM read_csv_auto('monthly_sales_feb.csv')
UNION ALL
SELECT 'mar', COUNT(*) FROM read_csv_auto('monthly_sales_mar.csv');

-- Aggregate across all three months in one query
SELECT MONTH(order_date) AS month, SUM(revenue) AS total_revenue
FROM read_csv_auto('monthly_sales_*.csv')
GROUP BY month
ORDER BY month;

-- Step 6 – Convert CSV to Parquet for repeated querying
COPY (SELECT * FROM read_csv_auto('sales_records.csv'))
TO 'sales_records.parquet' (FORMAT PARQUET);
