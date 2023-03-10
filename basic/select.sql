-- basic

-- SELECT
-- SELECT [DISTINCT | ALL] fields
-- FROM tables
-- [WHERE limit strings by condition]
-- [GROUP BY field]
-- [HAVING filter after group]
-- [ORDER BY sort by [ASC | DESC]]
-- [LIMIT number of strings]

-- order
-- FROM WHERE GROUP BY HAVING SELECT DISTINCT ORDER BY LIMIT
-- priority
-- NOT AND OR

-- SELECT
TABLE my_contacts;
-- * all
SELECT * FROM my_contacts;
-- one
SELECT last_name FROM my_contacts;
-- some
SELECT first_name, last_name FROM my_contacts;
-- DISTINCT
SELECT DISTINCT gender FROM my_contacts;
-- AS
SELECT last_name AS ln FROM my_contacts;


-- AGGREGATE

-- SUM
SELECT SUM(salary) FROM job_current
WHERE title LIKE '%developer';

SELECT title, SUM(salary) AS sum_salary FROM job_current
GROUP BY title
ORDER BY sum_salary DESC;

-- AVG
SELECT title, round(AVG(salary),2) AS avg_salary FROM job_current
GROUP BY title
ORDER BY AVG(salary) DESC;

-- MIN MAX
SELECT title, MIN(salary), MAX(salary) FROM job_current
GROUP BY title;

-- COUNT
SELECT COUNT(gender) FROM my_contacts;

SELECT gender, COUNT(gender) FROM my_contacts
GROUP BY gender;

-- COUNT DISTINCT
SELECT COUNT(DISTINCT gender) FROM my_contacts;

-- LIMIT
SELECT title, SUM(salary) FROM job_current
GROUP BY title
ORDER BY SUM(salary) DESC
LIMIT 2;

--OFFSET
SELECT title, SUM(salary) FROM job_current
GROUP BY title
ORDER BY SUM(salary) DESC
LIMIT 1 OFFSET 1;


-- ORDER BY
SELECT last_name, birthday FROM my_contacts
ORDER BY birthday;
-- by second selected column
SELECT last_name, birthday FROM my_contacts
ORDER BY 2;

SELECT last_name, email FROM my_contacts
WHERE email LIKE '%gmail.com'
ORDER BY last_name;

SELECT last_name, birthday, gender FROM my_contacts
WHERE email LIKE '%gmail.com'
ORDER BY last_name ASC, birthday DESC, gender;


-- GROUP BY
SELECT gender FROM my_contacts
GROUP BY gender;

SELECT COUNT(gender) AS g FROM my_contacts
GROUP BY gender;
