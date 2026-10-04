-- Clip 2: The MotherDuck UI
-- Module 3: MotherDuck
-- Run these queries in the MotherDuck browser UI (app.motherduck.com)

-- Task 3 – Run your first query
SELECT COUNT(*) FROM sample_data.hn.hacker_news;

-- Task 4 – Explore post types and scores
SELECT
    type,
    COUNT(*)        AS post_count,
    AVG(score)      AS avg_score
FROM sample_data.hn.hacker_news
WHERE score > 0
GROUP BY type
ORDER BY post_count DESC;
