-- Clip 5: Pitfalls and Housekeeping
-- Module 1: Extending DuckDB with Extensions

-- Task 1 – Install from the wrong place
-- This will fail — crypto is a community extension, not in the core repo
INSTALL crypto;

-- Fix: specify the community repository
INSTALL crypto FROM community;
LOAD crypto;

SELECT md5('hello world');
SELECT sha256('hello world');

-- Task 2 – Autoinstall and autoload settings
SELECT name, value, description
FROM duckdb_settings()
WHERE name IN ('autoinstall_known_extensions', 'autoload_known_extensions');

-- Enable autoinstall and autoload
SET autoinstall_known_extensions = true;
SET autoload_known_extensions = true;

-- Now call a spatial function with no explicit INSTALL or LOAD
SELECT ST_Distance(ST_Point(40.7128, -74.0060), ST_Point(34.0522, -118.2437));

-- Task 3 – Fix a version mismatch after upgrading DuckDB
-- Force a fresh install to get the version matching your current DuckDB binary
INSTALL spatial;
LOAD spatial;

-- Task 4 – Offline / locked-down environment
-- Copy the .duckdb_extension file manually to the target machine, then:
LOAD spatial;
