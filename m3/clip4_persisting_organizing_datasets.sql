-- Clip 4: Persisting and Organizing Shared Datasets
-- Module 3: MotherDuck
-- Run from a local DuckDB terminal session

-- Task 1 – Create a named database in MotherDuck
ATTACH 'md:' AS md;

CREATE DATABASE duckdb_course;

SHOW DATABASES;

USE duckdb_course;

-- Task 2 – Load data into the cloud database
CREATE TABLE releases AS
SELECT * FROM (
    VALUES
        ('v1.0.0', 'Nivis',        '2024-01-17', 12400,  6100000),
        ('v1.1.0', 'Eatoni',       '2024-04-25', 17800,  6800000),
        ('v1.2.0', 'Histrionicus', '2024-07-09', 22300,  7400000),
        ('v1.3.0', 'Ossivalis',    '2024-11-12', 27600,  8200000),
        ('v1.4.0', 'Andium',       '2025-02-05', 34100,  9600000),
        ('v1.5.0', 'Variegata',    '2025-06-02', 41800, 11300000)
) AS t(version, codename, release_date, stars_at_release, monthly_downloads);

CREATE TABLE core_extensions AS
SELECT * FROM (
    VALUES
        ('json',       'core', 'auto-loaded',      'JSON reading, writing, and path extraction'),
        ('parquet',    'core', 'auto-loaded',      'Parquet file reading and writing'),
        ('httpfs',     'core', 'install required', 'S3, GCS, and HTTPS file access'),
        ('spatial',    'core', 'install required', 'Geometry types and spatial functions'),
        ('motherduck', 'core', 'install required', 'MotherDuck cloud connection'),
        ('delta',      'core', 'install required', 'Delta Lake table reading'),
        ('iceberg',    'core', 'install required', 'Apache Iceberg table reading'),
        ('excel',      'core', 'install required', 'Excel (xlsx) file reading'),
        ('azure',      'core', 'install required', 'Azure Blob Storage access'),
        ('fts',        'core', 'install required', 'Full-text search indexes')
) AS t(extension_name, tier, load_mode, description);

SHOW TABLES;

-- Task 3 – Reconnect in a fresh session and confirm data persisted
-- (open a new terminal, then run:)
ATTACH 'md:' AS md;

SELECT version, codename, monthly_downloads
FROM duckdb_course.releases
ORDER BY release_date;

-- Task 4 – Query across both tables
SELECT
    e.extension_name,
    e.load_mode,
    e.description,
    CASE
        WHEN e.extension_name IN ('json', 'parquet', 'httpfs', 'spatial', 'motherduck')
            THEN 'established'
        ELSE 'added post-1.3'
    END AS maturity
FROM duckdb_course.core_extensions AS e
ORDER BY maturity, e.extension_name;

SELECT
    MIN(stars_at_release)                           AS stars_at_v1_0,
    MAX(stars_at_release)                           AS stars_at_latest,
    MAX(stars_at_release) - MIN(stars_at_release)   AS growth,
    ROUND(
        MAX(stars_at_release)::DOUBLE / MIN(stars_at_release), 1
    )                                               AS multiplier
FROM duckdb_course.releases;

-- Task 5 – Share the database with a teammate (SQL alternative to the UI)
SELECT SHARE_DATABASE('duckdb_course', 'teammate@example.com', 'read');

-- Teammate verification (run from their session)
ATTACH 'md:' AS md;
SELECT * FROM duckdb_course.releases;
