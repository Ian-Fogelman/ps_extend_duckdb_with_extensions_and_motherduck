-- Clip 4: Install, Load, Manage
-- Module 1: Extending DuckDB with Extensions

-- Task 2 – Try a function without its extension loaded
SELECT ST_Point(40.7128, -74.0060);
-- Expected: error — extension not loaded yet

-- Task 3 – Install the spatial extension
INSTALL spatial;

-- Task 4 – Load the extension into your session
LOAD spatial;

SELECT ST_Point(40.7128, -74.0060);

-- Task 5 – Inspect what's installed and loaded
SELECT extension_name, loaded, installed
FROM duckdb_extensions();

-- Task 7 – Find where extensions live on disk
SELECT extension_name, install_path
FROM duckdb_extensions()
WHERE installed = true;
