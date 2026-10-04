-- Clip 4: Combining External + Local Data
-- Module 2: Querying External Data
-- Run from the repo root: duckdb

-- Task 1 – Create a local reference table
CREATE TABLE conference_budgets AS
SELECT * FROM (
    VALUES
        ('Amsterdam',     8500),
        ('Seattle',       6200),
        ('Berlin',        5800),
        ('San Francisco', 9100),
        ('London',        7400)
) AS t(city, sponsor_budget_usd);

SELECT * FROM conference_budgets;

-- Task 2 – Inspect the external file before joining
SELECT *
FROM read_parquet('m2/data/duckdb_community_events.parquet')
LIMIT 5;

SELECT DISTINCT city
FROM read_parquet('m2/data/duckdb_community_events.parquet')
ORDER BY city;

-- Task 3 – Join the external file against the local table
SELECT
    e.city,
    COUNT(*)                        AS events_held,
    SUM(e.attendees_est)            AS total_attendees,
    MAX(b.sponsor_budget_usd)       AS budget_usd,
    ROUND(
        SUM(e.attendees_est) / MAX(b.sponsor_budget_usd), 1
    )                               AS attendees_per_dollar
FROM read_parquet('m2/data/duckdb_community_events.parquet') AS e
JOIN conference_budgets AS b
    ON e.city = b.city
GROUP BY e.city
ORDER BY total_attendees DESC;

-- Task 4 – Filter the external side before joining
SELECT
    e.city,
    COUNT(*)                  AS events_held,
    SUM(e.attendees_est)      AS total_attendees,
    MAX(b.sponsor_budget_usd) AS budget_usd
FROM read_parquet('m2/data/duckdb_community_events.parquet') AS e
JOIN conference_budgets AS b
    ON e.city = b.city
WHERE e.event_date >= '2024-01-01'
GROUP BY e.city
ORDER BY total_attendees DESC;

-- Task 5 – Same join against an S3-hosted file (optional)
-- Requires httpfs loaded and S3 credentials configured (see clip3 script)
LOAD httpfs;

SELECT
    e.city,
    COUNT(*)                  AS events_held,
    SUM(e.attendees_est)      AS total_attendees,
    MAX(b.sponsor_budget_usd) AS budget_usd
FROM read_parquet('s3://course-demo-bucket/data/duckdb_community_events.parquet') AS e
JOIN conference_budgets AS b
    ON e.city = b.city
GROUP BY e.city
ORDER BY total_attendees DESC;

-- Task 6 – Export the joined result to a local CSV
COPY (
    SELECT
        e.city,
        COUNT(*)                        AS events_held,
        SUM(e.attendees_est)            AS total_attendees,
        MAX(b.sponsor_budget_usd)       AS budget_usd,
        ROUND(
            SUM(e.attendees_est) / MAX(b.sponsor_budget_usd), 1
        )                               AS attendees_per_dollar
    FROM read_parquet('m2/data/duckdb_community_events.parquet') AS e
    JOIN conference_budgets AS b
        ON e.city = b.city
    GROUP BY e.city
    ORDER BY total_attendees DESC
) TO 'event_budget_summary.csv' (FORMAT CSV, HEADER TRUE);
