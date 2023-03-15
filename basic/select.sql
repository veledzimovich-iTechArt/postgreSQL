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

-- = equal
SELECT ('1' = '1') AS equal;
-- <> != not equal
SELECT ('1' <> '1') AS not_equal;
-- < <=
SELECT ('1' <= '1') AS lt_equal;
-- > >=
SELECT ('1' >= '1') AS gt_equal;

-- WHERE
-- records are selected by condition first
-- and then can be grouped and/or sorted

-- AND OR NOT
SELECT contact_id AS gender_and_birthday FROM my_contacts
WHERE gender IS NOT NULL AND birthday IS NOT NULL;

SELECT contact_id AS gender_or_birthday FROM my_contacts
WHERE gender IS NOT NULL OR birthday IS NOT NULL;

-- XOR
SELECT contact_id AS not_gender_and_birthday FROM my_contacts
WHERE NOT (gender IS NOT NULL AND birthday IS NOT NULL);
-- XAND
SELECT contact_id AS not_gender_and_birthday FROM my_contacts
WHERE NOT (gender IS NOT NULL OR birthday IS NOT NULL);

-- IN
SELECT last_name as in_gender FROM my_contacts
WHERE gender IN ('M', 'F');
-- NOT IN
SELECT last_name as not_in_gender FROM my_contacts
WHERE NOT gender IN ('M', 'F');

-- NULL is special
-- NULL is NULL but value NULL != NULL
-- IS NULL
SELECT last_name as null_gender FROM my_contacts
WHERE gender IS NULL;

SELECT last_name AS birthday_is_null FROM my_contacts
WHERE birthday IS NULL;
-- IS NOT NULL
SELECT last_name AS birthday_is_not_null FROM my_contacts
WHERE birthday IS NOT NULL;
-- get NULL
SELECT last_name as get_gender FROM my_contacts
WHERE gender = 'F' AND last_name = 'Gordon';

-- > <
SELECT birthday AS birthday_1983_and_1992 FROM my_contacts
WHERE birthday > '1983-07-19' AND birthday < '1990-12-31';
-- >= <=
SELECT birthday AS birthday_1983_and_1992 FROM my_contacts
WHERE birthday >= '1983-07-19' AND birthday <= '1990-12-31';
-- BETWEEN inclusive
SELECT birthday AS birthday_between_1983_and_1992 FROM my_contacts
WHERE birthday BETWEEN '1983-07-19' AND '1990-12-31';
-- NOT BETWEEN inclusive
SELECT birthday AS birthday_between_1983_and_1992 FROM my_contacts
WHERE birthday NOT BETWEEN '1983-07-19' AND '1990-12-31';
-- lexical order based on first chars
SELECT last_name FROM my_contacts
WHERE last_name > 'A' AND last_name < 'G';

SELECT last_name FROM my_contacts
WHERE last_name BETWEEN 'A' AND 'G';

-- =
SELECT last_name FROM my_contacts
NATURAL JOIN job_current
WHERE job_current.title = 'python developer';

SELECT last_name FROM my_contacts
WHERE gender = 'M';

-- <>
SELECT last_name FROM my_contacts
WHERE gender <> 'M';

SELECT last_name FROM my_contacts
WHERE NOT gender <> 'M';

-- E or \
SELECT last_name AS escape_E FROM my_contacts
WHERE last_name = E'O\'Keefe';
-- or two apostrophes
SELECT last_name AS escape_apo FROM my_contacts
WHERE last_name = 'O''Keefe';

-- EXISTS
SELECT last_name FROM my_contacts
WHERE EXISTS(
    SELECT 1
    FROM job_current
    WHERE my_contacts.contact_id = job_current.contact_id AND salary > 1200
);
-- EXISTS NULL
SELECT last_name FROM my_contacts WHERE EXISTS (SELECT NULL)

-- UNIQUE MATCH

-- LIKE
-- _ one symbol
-- % sequence
-- default escape symbol \
-- performance on large databases can be slow
SELECT last_name AS last_name_like FROM my_contacts
WHERE first_name LIKE 'w%';
-- ILIKE
SELECT last_name AS last_name_ignore_case FROM my_contacts
WHERE first_name ILIKE 'w%';

SELECT last_name FROM my_contacts
WHERE first_name LIKE '___';

SELECT last_name FROM my_contacts
WHERE last_name LIKE '%e';

SELECT last_name FROM my_contacts
WHERE last_name ILIKE E'_\'%';

SELECT last_name FROM my_contacts
WHERE NOT last_name ILIKE 'V%' AND NOT last_name ILIKE 'O%';

-- ESCAPE
SELECT email AS email_with_escape FROM my_contacts
WHERE email LIKE 'me!_%' ESCAPE '!';

-- ~ regexp
SELECT last_name, mobile FROM my_contacts
WHERE mobile ~ '[0-9]';

-- start with vowels and end with vowels
SELECT DISTINCT first_name AS start_end_vowels FROM my_contacts
WHERE (
    LOWER(first_name) ~ '^[aeoui]'
    AND LOWER(first_name) ~ '[aeoui]$'
);
-- do not start with vowels or do not end with vowels
SELECT DISTINCT first_name AS start_end_vowels FROM my_contacts
WHERE (
    LOWER(first_name) ~ '^[^aeoui]'
    OR LOWER(first_name) ~ '^[^aeoui]$'
);

-- LATERAL

SELECT last_name, length(last_name), avg(mc.len_last_name)
FROM my_contacts, LATERAL (
    SELECT length(last_name) AS len_last_name FROM my_contacts
) AS mc
GROUP BY last_name;

SELECT last_name, js.title
FROM my_contacts, LATERAL (
    SELECT title FROM job_current
    WHERE job_current.contact_id = my_contacts.contact_id
) as js;

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


-- HAVING
SELECT last_name, job_current.title, job_current.salary
FROM my_contacts
NATURAL JOIN job_current
WHERE job_current.title IS NOT NULL
GROUP BY last_name, job_current.title, job_current.salary
HAVING job_current.salary > (SELECT AVG(salary) FROM job_current);


-- GROUP BY
SELECT gender FROM my_contacts
GROUP BY gender;

SELECT gender, COUNT(gender) FROM my_contacts
GROUP BY gender;


-- WITH
WITH lowest_salary AS (
    SELECT max(salary_low) AS max_salary FROM job_desired
)
SELECT
    last_name,
    first_name,
    job_current.title
FROM my_contacts
NATURAL JOIN job_current
WHERE job_current.salary >= (SELECT max_salary FROM lowest_salary);


-- Window
-- first value
-- unordered
SELECT
    *,
    first_value(years_exp) OVER () AS rn
FROM job_desired
WHERE title IS NOT NULL
ORDER BY rn;
-- order by
SELECT
    *,
    first_value(years_exp) OVER (ORDER BY years_exp) AS lowest_exp
FROM job_desired
WHERE title IS NOT NULL
ORDER BY lowest_exp;
-- partition
SELECT
    *,
    first_value(years_exp) OVER (
        PARTITION BY available ORDER BY years_exp
    ) AS lowest_exp
FROM job_desired
WHERE title IS NOT NULL
ORDER BY lowest_exp;
-- row number
SELECT
    title, salary_high, available,
    row_number() OVER (
        PARTITION BY available ORDER BY salary_high
    ) AS rn
FROM job_desired
WHERE title IS NOT NULL;
-- rank
SELECT
    title, salary_high, available,
    rank() OVER (
        PARTITION BY available ORDER BY salary_high
    ) AS rn
FROM job_desired
WHERE title IS NOT NULL;
-- dense_rank
SELECT
    title, salary_high, available,
    dense_rank() OVER (
        PARTITION BY available ORDER BY salary_high
    ) AS rn
FROM job_desired
WHERE title IS NOT NULL;

-- simple sum
SELECT
    start_date,
    salary,
    SUM(salary) OVER () as total_budjet
FROM job_current
WHERE start_date IS NOT NULL
ORDER BY start_date;
-- cumulative
SELECT
    start_date,
    salary,
    SUM(salary) OVER (
        ORDER BY start_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_budjet
FROM job_current
WHERE start_date IS NOT NULL
ORDER BY start_date;
-- sliding window
SELECT
    start_date,
    salary,
    SUM(salary) OVER (
        ORDER BY start_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS sliding_budjet
FROM job_current
WHERE start_date IS NOT NULL
ORDER BY start_date;
-- sliding window with partition
SELECT
    get_year,
    salary,
    SUM(salary) OVER (
        PARTITION BY get_year
        ORDER BY start_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS sliding_budjet
FROM job_current, LATERAL SUBSTRING(start_date::text, 1, 4) AS get_year
WHERE start_date IS NOT NULL
ORDER BY start_date;

-- LAG
SELECT
    start_date,
    salary,
    LAG(salary, 1) OVER (ORDER BY start_date) prev_budget
FROM job_current
WHERE start_date IS NOT NULL
ORDER BY start_date;

-- LEAD
SELECT
    start_date,
    salary,
    LEAD(salary, 1) OVER (ORDER BY start_date) next_budget
FROM job_current
WHERE start_date IS NOT NULL
ORDER BY start_date;

-- LAG PARTITION
SELECT
    title,
    available,
    salary_high,
    LAG(salary_high, 1) OVER (
        PARTITION BY available ORDER BY salary_high
    ) AS partition_lead
FROM job_desired
WHERE title IS NOT NULL;
