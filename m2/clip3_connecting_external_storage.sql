-- Clip 3: Connecting to External Storage/Services
-- Module 2: Querying External Data

-- Task 1 – Install and load the httpfs extension
INSTALL httpfs;
LOAD httpfs;

SELECT extension_name, loaded, installed
FROM duckdb_extensions()
WHERE extension_name = 'httpfs';

-- Task 2 – Query a public file over HTTPS (no credentials needed)
SELECT *
FROM read_csv_auto('https://raw.githubusercontent.com/Ian-Fogelman/ps_extend_duckdb_with_extensions_and_motherduck/refs/heads/main/m2/data/sample_records.csv')
LIMIT 10;

SELECT region, COUNT(*) AS record_count
FROM read_csv_auto('https://raw.githubusercontent.com/Ian-Fogelman/ps_extend_duckdb_with_extensions_and_motherduck/refs/heads/main/m2/data/sample_records.csv')
GROUP BY region
ORDER BY record_count DESC;

-- Task 3 – Configure S3 credentials (mock local server for demo)
-- Swap these values for your real AWS credentials in production
SET s3_endpoint='127.0.0.1:5555';
SET s3_access_key_id='test-key';
SET s3_secret_access_key='test-secret';
SET s3_region='us-east-1';
SET s3_use_ssl=false;
SET s3_url_style='path';

-- Confirm settings took effect
SELECT current_setting('s3_endpoint') AS endpoint,
       current_setting('s3_url_style') AS url_style,
       current_setting('s3_use_ssl')   AS use_ssl;

-- Task 4 – Query S3 data directly
SELECT *
FROM read_parquet('s3://course-demo-bucket/data/sales_2024.parquet')
LIMIT 10;

SELECT product_category, SUM(revenue) AS total_revenue
FROM read_parquet('s3://course-demo-bucket/data/sales_2024.parquet')
WHERE order_date >= '2024-06-01'
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Glob pattern across an entire S3 prefix
SELECT COUNT(*) AS total_rows
FROM read_parquet('s3://course-demo-bucket/data/monthly/*.parquet');

-- Task 5 – Inspect credentials and clean up
SELECT current_setting('s3_endpoint')       AS endpoint,
       current_setting('s3_access_key_id')  AS key_id;

RESET s3_endpoint;
RESET s3_access_key_id;
RESET s3_secret_access_key;
RESET s3_use_ssl;
RESET s3_url_style;

SELECT current_setting('s3_endpoint') AS endpoint;

-- Task 6 – The full pattern for reference
INSTALL httpfs;
LOAD httpfs;

SET s3_endpoint='127.0.0.1:5555';
SET s3_access_key_id='test-key';
SET s3_secret_access_key='test-secret';
SET s3_region='us-east-1';
SET s3_use_ssl=false;
SET s3_url_style='path';

SELECT * FROM read_parquet('s3://course-demo-bucket/data/sales_2024.parquet');
