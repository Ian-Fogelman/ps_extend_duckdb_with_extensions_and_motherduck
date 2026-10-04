-- Clip 3: Connecting and the Local + Cloud Model
-- Module 3: MotherDuck
-- Run from a local DuckDB terminal session

-- Task 1 – Attach MotherDuck (triggers browser auth on first use)
ATTACH 'md:' AS md;

-- Task 2 – Confirm local and cloud databases are both visible
SHOW DATABASES;

SELECT COUNT(*) FROM sample_data.hn.hacker_news;

-- Task 3 – Create a local in-memory table
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

SHOW TABLES;

-- Task 4 – Hybrid query: local table joined against cloud data
SELECT
    r.version,
    r.codename,
    r.release_date,
    COUNT(hn.id)        AS hn_mentions,
    MAX(hn.score)       AS top_score
FROM releases AS r
LEFT JOIN sample_data.hn.hacker_news AS hn
    ON hn.title ILIKE '%' || r.codename || '%'
    OR hn.title ILIKE '%DuckDB ' || r.version || '%'
GROUP BY r.version, r.codename, r.release_date
ORDER BY r.release_date;

-- Task 5 – Check which databases are local vs. cloud
SELECT database_name, type, path
FROM duckdb_databases()
ORDER BY type;

-- Task 6 – Detach and re-attach MotherDuck
DETACH md;

-- This should now fail (no cloud connection)
SELECT COUNT(*) FROM sample_data.hn.hacker_news;

-- Re-attach to restore access
ATTACH 'md:' AS md;
