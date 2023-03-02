-- basic

-- AGGREGATE

-- SUM
SELECT SUM(salary) FROM my_contacts
WHERE country = 'USA';

SELECT country, SUM(salary) FROM my_contacts
GROUP BY country
ORDER BY SUM(salary) DESC;
-- AVG
SELECT country, AVG(salary) FROM my_contacts
GROUP BY country
ORDER BY AVG(salary) DESC;
-- MIN MAX
SELECT country, MIN(salary) FROM my_contacts
GROUP BY country;
SELECT country, MAX(salary) FROM my_contacts
GROUP BY country;
-- COUNT
SELECT COUNT(country) FROM my_contacts;
SELECT country, COUNT(country) FROM my_contacts
GROUP BY country;
-- COUNT DISTINCT
SELECT COUNT(DISTINCT country) FROM my_contacts;
-- LIMIT
SELECT country, SUM(salary) FROM my_contacts
GROUP BY country
ORDER BY SUM(salary) DESC
LIMIT 2;

SELECT country, SUM(salary) FROM my_contacts
GROUP BY country
ORDER BY SUM(salary) DESC
LIMIT 1 OFFSET 1;


-- ORDER BY
SELECT last_name, profession FROM my_contacts
WHERE country = 'USA'
ORDER BY last_name;

SELECT profession, last_name, birthday FROM my_contacts
WHERE country = 'USA'
ORDER BY profession, last_name ASC, birthday DESC;


-- GROUP BY
ALTER TABLE my_contacts
ADD COLUMN salary DECIMAL(10, 2);
UPDATE my_contacts
SET salary =
    CASE
        WHEN contact_id = 1 THEN 1000
        WHEN contact_id = 2 THEN 900
        WHEN contact_id = 3 THEN 1200
        WHEN contact_id = 4 THEN 1700
        WHEN contact_id = 5 THEN 1900
    END;
