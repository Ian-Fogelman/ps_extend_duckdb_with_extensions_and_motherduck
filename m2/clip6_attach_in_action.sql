-- Clip 6: ATTACH in Action
-- Module 2: Querying External Data

-- Task 1 – Create the releases database
-- Run in a terminal: duckdb releases.duckdb
CREATE TABLE releases AS
SELECT * FROM (
    VALUES
        ('v1.0.0', 'Nivis',        '2024-01-17', 12400),
        ('v1.1.0', 'Eatoni',       '2024-04-25', 17800),
        ('v1.2.0', 'Histrionicus', '2024-07-09', 22300),
        ('v1.3.0', 'Ossivalis',    '2024-11-12', 27600),
        ('v1.4.0', 'Andium',       '2025-02-05', 34100),
        ('v1.5.0', 'Variegata',    '2025-06-02', 41800)
) AS t(version, codename, release_date, stars_at_release);

SELECT * FROM releases;
-- .quit

-- Create the extensions database
-- Run in a terminal: duckdb extensions.duckdb
CREATE TABLE ext_changelog AS
SELECT * FROM (
    VALUES
        ('json',    'v1.0.0', 'auto-loaded'),
        ('parquet', 'v1.0.0', 'auto-loaded'),
        ('httpfs',  'v1.0.0', 'install required'),
        ('spatial', 'v1.0.0', 'install required'),
        ('delta',   'v1.1.0', 'install required'),
        ('iceberg', 'v1.2.0', 'install required'),
        ('excel',   'v1.3.0', 'install required'),
        ('azure',   'v1.3.0', 'install required'),
        ('inet',    'v1.4.0', 'auto-loaded')
) AS t(extension_name, added_in_version, load_mode);

SELECT * FROM ext_changelog;
-- .quit

-- Task 2 – Open releases.duckdb and attach the extensions database
-- Run in a terminal: duckdb releases.duckdb
SHOW TABLES;

ATTACH 'extensions.duckdb' AS ext;

SHOW DATABASES;

SHOW ALL TABLES;

-- Task 3 – Cross-database join
SELECT
    r.version,
    r.codename,
    r.release_date,
    r.stars_at_release,
    e.extension_name,
    e.load_mode
FROM releases AS r
JOIN ext.ext_changelog AS e
    ON r.version = e.added_in_version
ORDER BY r.release_date, e.extension_name;

-- Count extensions added per release
SELECT
    r.version,
    r.codename,
    COUNT(e.extension_name) AS extensions_added,
    r.stars_at_release
FROM releases AS r
LEFT JOIN ext.ext_changelog AS e
    ON r.version = e.added_in_version
GROUP BY r.version, r.codename, r.release_date, r.stars_at_release
ORDER BY r.release_date;

-- Task 4 – Detach when done
DETACH ext;

SHOW DATABASES;
