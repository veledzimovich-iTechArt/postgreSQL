-- basic

-- JOIN

-- CROSS JOIN (Decart join)
SELECT i.interest, c.last_name
FROM interests as i CROSS JOIN my_contacts AS c;

SELECT interests.interest, my_contacts.last_name
FROM interests, my_contacts;

SELECT * FROM my_contacts CROSS JOIN interests;

SELECT * FROM contact_seeking, seekings;

-- all combos
SELECT i1.interest, i2.interest
FROM interests i1 CROSS JOIN interests i2;

-- INNER JOIN
INSERT INTO professions VALUES(DEFAULT, 'Sailor');

SELECT c.last_name, c.first_name, p.profession
FROM my_contacts AS c INNER JOIN professions as p
-- condition
ON c.prof_id = p.id;

SELECT p.profession
FROM my_contacts AS c INNER JOIN professions as p
ON c.prof_id = p.id
GROUP BY profession
ORDER BY profession;

SELECT c.last_name, c.first_name, s.status
FROM my_contacts AS c INNER JOIN statuses as s
ON c.status_id = s.id;

SELECT c.last_name, ci.interest_id
FROM my_contacts AS c INNER JOIN contact_interest AS ci
ON c.contact_id = ci.contact_id;

SELECT c.last_name, c.first_name, final_location.state
FROM my_contacts AS c INNER JOIN (
    SELECT l.id, s.name AS state
    FROM states AS s INNER JOIN locations as l
    ON s.id = l.state_id
) as final_location
ON c.location_id = final_location.id;

-- non-equal <>
SELECT c.last_name, c.first_name, p.profession
FROM my_contacts AS c INNER JOIN professions AS p
ON c.prof_id <> p.id
ORDER BY c.contact_id;

SELECT c.last_name, c.first_name, s.status
FROM my_contacts AS c INNER JOIN statuses AS s
ON c.status_id <> s.id;

-- NATURAL JOIN use same collumns names
-- useful when contact_id presented in both tables
SELECT c.last_name, ci.interest_id
FROM my_contacts AS c NATURAL JOIN contact_interest AS ci;

-- but could be useless
SELECT s.status, p.profession
FROM statuses AS s NATURAL JOIN professions AS p;




-- OUTER AND INNER SUBQUERY
SELECT mc.first_name AS firstname, mc.last_name AS lastname, jc.title
FROM job_current AS jc NATURAL JOIN my_contacts AS mc
WHERE jc.title IN (
                   SELECT title FROM job_listings
                   GROUP BY title
                   ORDER BY title
                );
-- same with JOIN
SELECT mc.first_name AS firstname, mc.last_name AS lastname, jc.title
FROM job_current AS jc NATURAL JOIN my_contacts AS mc
INNER JOIN job_listings as jl ON jc.title = jl.title;

-- NOT IN
SELECT mc.first_name AS firstname, mc.last_name AS lastname, jc.title
FROM job_current AS jc NATURAL JOIN my_contacts AS mc
WHERE jc.title NOT IN (
                   SELECT title FROM job_listings
                   GROUP BY title
                   ORDER BY title
                );

SELECT first_name, last_name
FROM my_contacts
WHERE location_id = (
                   SELECT l.id FROM locations AS l
                   INNER JOIN states AS s
                   ON l.state_id = s.id
                   WHERE s.name = 'CA'
                );

SELECT mc.first_name, mc.last_name, jc.salary
FROM my_contacts AS mc
NATURAL JOIN job_current AS jc
WHERE jc.salary = (SELECT MAX(salary) FROM job_current);

SELECT mc.first_name, mc.last_name, jc.salary
FROM my_contacts AS mc
NATURAL JOIN job_current AS jc
ORDER BY jc.salary DESC LIMIT 1;

-- COLUMN SUBQUERY
SELECT mc.first_name, mc.last_name,
    (SELECT profession FROM  professions WHERE mc.prof_id = id) AS prof
FROM my_contacts AS mc;

-- ALL ANY SOME
SELECT * FROM job_current
WHERE salary IN
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);
-- select values greater than maximal value from selection
SELECT * FROM job_current
WHERE salary > ALL
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);
-- select values smaller or equal than minimal value from selection
SELECT * FROM job_current
WHERE salary <= ALL
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);

-- select values greater than minimal value from selection
SELECT * FROM job_current
WHERE salary > ANY
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);
-- select values smaller than maximal value from selection
SELECT * FROM job_current
WHERE salary <= ANY
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);
-- SOME same ANY
SELECT * FROM job_current
WHERE salary <= SOME
(SELECT salary FROM job_current WHERE salary > 900 AND salary < 1500);

-- NATURAL JOIN
-- NON CORRELATED SUBQUERY (SUBQUERY without references to OUTER QUERY)
-- INNER QUERY is independent
SELECT mc.first_name, mc.last_name, jc.salary
FROM my_contacts AS mc NATURAL JOIN job_current AS jc
WHERE jc.salary >
    (SELECT salary FROM my_contacts AS mc NATURAL JOIN job_current
     WHERE mc.contact_id = 2);

SELECT first_name, last_name, salary, (
    salary - (
              SELECT AVG(salary)
              FROM job_current WHERE title LIKE '%developer'
            )
    ) AS diff
FROM my_contacts NATURAL JOIN job_current
WHERE title LIKE '%developer';


SELECT title, salary FROM job_listings
WHERE salary = (SELECT MAX(salary) FROM job_listings);
-- same with ORDER BY and LIMIT
SELECT title, salary FROM job_listings
ORDER BY salary DESC LIMIT 1;


SELECT first_name, last_name, salary
FROM my_contacts NATURAL JOIN job_current
WHERE salary > (SELECT AVG(salary) FROM job_current);

SELECT first_name, last_name, location_id, title
FROM my_contacts NATURAL JOIN job_current
WHERE title LIKE '%developer' AND location_id IN (
    SELECT location_id FROM job_listings
    WHERE title LIKE '%developer'
);

SELECT first_name, last_name, salary, location_id
FROM my_contacts NATURAL JOIN job_current
-- because we can have two people with MAX salary
WHERE location_id IN (
    SELECT location_id
    FROM my_contacts NATURAL JOIN job_current
    WHERE salary = (SELECT MAX(salary) FROM job_current)
);

-- CORRELATED QUERY
SELECT mc.first_name, mc.last_name
FROM my_contacts AS mc
WHERE
2 = (
    SELECT COUNT(*) FROM contact_interest
    WHERE contact_id = mc.contact_id
);

-- EXISTS NOT EXISTS
SELECT mc.first_name, mc.last_name
FROM my_contacts AS mc
WHERE NOT EXISTS (
    SELECT * FROM job_current AS jc
    WHERE mc.contact_id = jc.contact_id
);

SELECT mc.first_name, mc.last_name, mc.email
FROM my_contacts AS mc
WHERE EXISTS (
    SELECT * FROM contact_interest
    WHERE contact_id = mc.contact_id
);

SELECT mc.email
FROM my_contacts AS mc
WHERE (
    SELECT COUNT(*) FROM contact_interest
    WHERE contact_id = mc.contact_id
) > 1
AND NOT EXISTS (
    SELECT * FROM job_current AS jc
    WHERE mc.contact_id = jc.contact_id
);

-- OUTER JOIN
-- LEFT
SELECT mc.first_name, mc.last_name, mc.email, pr.profession
FROM professions AS pr
LEFT JOIN my_contacts AS mc ON pr.id = mc.prof_id;
-- RIGHT
SELECT mc.first_name, mc.last_name, mc.email, pr.profession
FROM my_contacts AS mc
RIGHT JOIN professions AS pr ON mc.prof_id = pr.id;

-- LEFT
SELECT mc.first_name, mc.last_name, mc.email, pr.profession
FROM my_contacts AS mc
LEFT JOIN professions AS pr ON mc.prof_id = pr.id;
-- RIGHT
SELECT mc.first_name, mc.last_name, mc.email, pr.profession
FROM professions AS pr
RIGHT JOIN my_contacts AS mc ON pr.id = mc.prof_id;

-- FULL OUTER JOIN
SELECT mc.first_name, mc.last_name, mc.email, pr.profession
FROM professions AS pr
FULL JOIN my_contacts AS mc ON pr.id = mc.prof_id;

-- RFK
SELECT mc1.last_name, mc2.last_name AS boss
FROM my_contacts AS mc1
INNER JOIN my_contacts AS mc2 ON mc1.boss_id = mc2.contact_id;
-- same with SUBQUERY
SELECT mc1.last_name,
(SELECT last_name FROM my_contacts
 WHERE mc1.boss_id = contact_id) AS boss
FROM my_contacts AS mc1;

-- UNION uniq
-- ERROR
-- SELECT * FROM job_current
-- UNION
-- SELECT * FROM job_desired
-- UNION
-- SELECT * FROM job_listings ORDER BY title;
-- ERROR
-- SELECT * FROM job_current ORDER BY title
-- UNION
-- SELECT * FROM job_desired ORDER BY title
-- UNION
-- SELECT * FROM job_listings ORDER BY title;

SELECT title FROM job_current
UNION
SELECT title FROM job_desired
UNION
SELECT title FROM job_listings ORDER BY title;

-- UNION ALL non-uniq
SELECT title FROM job_current
UNION ALL
SELECT title FROM job_desired
UNION ALL
SELECT title FROM job_listings ORDER BY title;


CREATE TABLE my_union AS
SELECT contact_id FROM job_current
UNION
SELECT salary FROM job_listings;

-- INTERSECT
SELECT title FROM job_current
INTERSECT
SELECT title FROM job_desired;
-- EXCEPT
SELECT title FROM job_desired
EXCEPT
SELECT title FROM job_current;
