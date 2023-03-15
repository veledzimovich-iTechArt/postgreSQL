-- basic

-- NORMALIZATION


-- DEFAULT
CREATE TABLE professions(
    id SERIAL NOT NULL PRIMARY KEY,
    profession VARCHAR(50)
);

INSERT INTO professions(profession)
    SELECT profession AS my_prof FROM my_contacts
    GROUP BY my_prof
    ORDER BY my_prof;

ALTER TABLE my_contacts
DROP COLUMN profession;

ALTER TABLE my_contacts
ADD COLUMN prof_id INT NOT NULL DEFAULT 1;

ALTER TABLE my_contacts
ADD CONSTRAINT my_contacts_prof_id_fkey
FOREIGN KEY (prof_id) REFERENCES professions(id);

UPDATE my_contacts
    SET prof_id =
        CASE
            WHEN contact_id = 1 OR contact_id = 4 THEN 2
            WHEN contact_id = 3 THEN 3
            WHEN contact_id = 2 THEN 1
            ELSE prof_id
        END;

ALTER TABLE my_contacts
DROP COLUMN status;
ALTER TABLE my_contacts ALTER COLUMN prof_id DROP DEFAULT;


-- NOT NULL
CREATE TABLE statuses(
    id SERIAL NOT NULL PRIMARY KEY,
    status VARCHAR(50)
);

INSERT INTO statuses
    VALUES
        (DEFAULT, 'Single'),
        (DEFAULT, 'Married');

ALTER TABLE my_contacts ADD COLUMN status_id INT NOT NULL DEFAULT 1;

ALTER TABLE my_contacts
ADD CONSTRAINT my_contacts_status_id_fkey
FOREIGN KEY (status_id) REFERENCES statuses(id);

UPDATE my_contacts
    SET status_id = 2 WHERE contact_id = 3;


-- CASCADE
ALTER TABLE my_contacts DROP COLUMN city;
ALTER TABLE my_contacts DROP COLUMN state;
ALTER TABLE my_contacts DROP COLUMN country;

CREATE TABLE countries(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO countries
    VALUES
        (DEFAULT, 'USA'),
        (DEFAULT, 'Ireland'),
        (DEFAULT, 'China');

CREATE TABLE states(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO states
    VALUES
        (DEFAULT, ''),
        (DEFAULT, 'CA'),
        (DEFAULT, 'NY');

CREATE TABLE cities(
    id SERIAL NOT NULL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO cities
    VALUES
        (DEFAULT, ''),
        (DEFAULT, 'Dublin'),
        (DEFAULT, 'Los Angeles'),
        (DEFAULT, 'New York');
TABLE cities;

CREATE TABLE locations(
    id SERIAL NOT NULL PRIMARY KEY,
    country_id INT NOT NULL,
    state_id INT NOT NULL,
    city_id INT NOT NULL,
    -- RESTRICT no action (default)
    CONSTRAINT locations_country_id_fkey FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    -- SET NULL
    CONSTRAINT locations_state_id_fkey FOREIGN KEY (state_id) REFERENCES states(id) ON DELETE SET NULL ON UPDATE CASCADE,
    -- SET DEFAULT
    CONSTRAINT locations_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET DEFAULT ON UPDATE CASCADE
);
-- ON DELETE
ALTER TABLE locations ALTER COLUMN state_id DROP NOT NULL;
ALTER TABLE locations ALTER COLUMN city_id SET DEFAULT 1;

INSERT INTO locations
    VALUES
        (DEFAULT, 1, 2, 3),
        (DEFAULT, 2, 1, 2),
        (DEFAULT, 3, 1, 1),
        (DEFAULT, 1, 3, 4);

ALTER TABLE my_contacts ADD COLUMN location_id INT NOT NULL DEFAULT 1;

ALTER TABLE my_contacts
ADD CONSTRAINT my_contacts_location_id_fkey
FOREIGN KEY (location_id) REFERENCES locations(id);

UPDATE my_contacts
    SET location_id =
        CASE
            WHEN contact_id IN (1, 4, 5) THEN 1
            WHEN contact_id = 2 THEN 2
            WHEN contact_id = 3 THEN 3
            ELSE location_id
        END;
ALTER TABLE my_contacts ALTER COLUMN location_id DROP DEFAULT;

ALTER TABLE locations DROP CONSTRAINT locations_state_id_fkey;
ALTER TABLE locations
ADD CONSTRAINT locations_state_id_fkey
FOREIGN KEY (state_id) REFERENCES states(id) ON DELETE CASCADE ON UPDATE CASCADE;
-- should delete entry with id from table location
DELETE FROM states WHERE id = 6;
-- ERROR:  update or delete on table "locations" violates foreign key constraint "my_contacts_location_id_fkey" on table "my_contacts"
-- DETAIL:  Key (id)=(1) is still referenced from table "my_contacts".

ALTER TABLE my_contacts
ADD CONSTRAINT my_contacts_locations_state_id_fkey
FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE;
-- should delete entry with id from  my_contacts
DELETE FROM states WHERE id = 6;
-- ERROR:  update or delete on table "locations" violates foreign key constraint "job_listings_location_id_fkey" on table "job_listings"
-- DETAIL:  Key (id)=(1) is still referenced from table "job_listings".

-- ON UPDATE
-- RESTRICT
ALTER TABLE locations DROP CONSTRAINT locations_state_id_fkey;
ALTER TABLE locations ADD CONSTRAINT locations_state_id_fkey FOREIGN KEY (state_id) REFERENCES states(id) ON DELETE CASCADE ON UPDATE RESTRICT;
UPDATE states SET id = 7 WHERE name='LA';
-- ERROR:  update or delete on table "states" violates foreign key constraint "locations_state_id_fkey" on table "locations"

-- SET NULL
ALTER TABLE locations DROP CONSTRAINT locations_state_id_fkey;
ALTER TABLE locations ADD CONSTRAINT locations_state_id_fkey FOREIGN KEY (state_id) REFERENCES states(id) ON DELETE CASCADE ON UPDATE SET NULL;
-- set NULL to the locations.state_id
UPDATE states SET id = 7 WHERE name='LA';
UPDATE states SET id = 6 WHERE name='LA';
UPDATE locations SET state_id = 6 WHERE state_id IS NULL;

-- SET DEFAULT
ALTER TABLE locations DROP CONSTRAINT locations_city_id_fkey;
ALTER TABLE locations ADD CONSTRAINT locations_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET DEFAULT ON UPDATE SET DEFAULT;

UPDATE cities SET id = 6 WHERE name='New York';
-- set default to the location.city_id
UPDATE cities SET id = 5 WHERE name='New York';
UPDATE locations SET city_id = 6 WHERE id = 5;

-- NO ACTION
ALTER TABLE locations DROP CONSTRAINT locations_city_id_fkey;
ALTER TABLE locations ADD CONSTRAINT locations_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET DEFAULT ON UPDATE NO ACTION;
-- ERROR: update or delete on table "cities" violates foreign key constraint "locations_city_id_fkey" on table "locations"


ALTER TABLE locations DROP CONSTRAINT locations_city_id_fkey;
ALTER TABLE locations ADD CONSTRAINT locations_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE SET DEFAULT ON UPDATE CASCADE;


-- MANY TO MANY

-- UNIQUE
CREATE TABLE interests(
    id SERIAL NOT NULL PRIMARY KEY,
    interest VARCHAR(50) UNIQUE
);
INSERT INTO interests(interest)
    SELECT DISTINCT
        TRIM(
            UNNEST(STRING_TO_ARRAY(STRING_AGG(interests, ','), ','))
        ) AS interest
    FROM my_contacts ORDER BY interest;

ALTER TABLE my_contacts DROP COLUMN interests;

-- third table
CREATE TABLE contact_interest(
    contact_id INT NOT NULL,
    interest_id INT NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES my_contacts(contact_id),
    FOREIGN KEY (interest_id) REFERENCES interests(id),
    PRIMARY KEY (contact_id, interest_id)
);

INSERT INTO contact_interest
    VALUES
        (2, 2),
        (5, 5),
        (5, 4),
        (4, 1),
        (4, 4),
        (1, 3);

ALTER TABLE my_contacts DROP COLUMN seeking;

CREATE TABLE seekings(
    id SERIAL NOT NULL PRIMARY KEY,
    seeking VARCHAR(50)
);

ALTER TABLE seekings ADD CONSTRAINT seekings_seeking_key UNIQUE(seeking);

INSERT INTO seekings
    VALUES
        (DEFAULT, 'Friends'),
        (DEFAULT, 'Parties'),
        (DEFAULT, 'Board games'),
        (DEFAULT, 'Outdoor activity'),
        (DEFAULT, 'Pair programming');


CREATE TABLE contact_seeking(
    contact_id INT NOT NULL,
    seeking_id INT NOT NULL,
    FOREIGN KEY (contact_id) REFERENCES my_contacts(contact_id),
    FOREIGN KEY (seeking_id) REFERENCES seekings(id),
    PRIMARY KEY (contact_id, seeking_id)
);

INSERT INTO contact_seeking
    VALUES
        (2, 5),
        (5, 1),
        (5, 2),
        (4, 1),
        (4, 3),
        (1, 4);


-- CHECK
ALTER TABLE my_contacts
ADD CONSTRAINT check_gender CHECK (gender IN ('M', 'F'));
-- ALTER TABLE my_contacts
-- DROP CONSTRAINT check_gender;

INSERT INTO my_contacts
VALUES (
    DEFAULT,
    'Gordon',
    'Freeman',
    '1988-07-19',
    'gfreeman@gmail.com',
    NULL,
    'M',
    2000,
    (SELECT id FROM professions WHERE profession = 'Developer'),
    DEFAULT,
    (SELECT id FROM locations
        WHERE state_id = (SELECT id FROM states WHERE name = 'CA') AND city_id = (SELECT id FROM cities WHERE name = 'Los Angeles') AND country_id = (SELECT id FROM countries WHERE name = 'USA')
    )
);

ALTER TABLE my_contacts
ADD CONSTRAINT check_mobile CHECK (
   mobile ~ '^[0-9\-\(\)\+]+$'
);
-- ALTER TABLE my_contacts
-- DROP CONSTRAINT check_mobile;


-- ONE TO ONE

CREATE TABLE job_current (
  contact_id INT PRIMARY KEY REFERENCES my_contacts(contact_id),
  title VARCHAR(50),
  salary INT,
  start_date DATE
);

INSERT INTO job_current(contact_id, salary)
SELECT contact_id, salary FROM my_contacts;

UPDATE job_current
SET
    title = 'python developer',
    start_date = '2020-07-19'
WHERE contact_id = 1;

UPDATE job_current
SET
    title = 'computer scientiest',
    start_date = '1999-06-09'
WHERE contact_id = 2;

UPDATE job_current
SET
    title = 'techical writer',
    start_date = '2015-03-10'
WHERE contact_id = 3;

UPDATE job_current
SET
    title = 'java developer',
    start_date = '2015-03-11'
WHERE contact_id = 4;

UPDATE job_current
SET
    title = 'figma designer',
    start_date = '2015-10-29'
WHERE contact_id = 5;


CREATE TABLE job_desired (
  contact_id INT PRIMARY KEY REFERENCES my_contacts(contact_id),
  title VARCHAR(50),
  years_exp SMALLINT,
  salary_low INT CHECK(salary_low > 0),
  salary_high INT CHECK(salary_high > 0),
  available CHAR(1)
);

INSERT INTO job_desired(contact_id, salary_low)
SELECT contact_id, salary FROM my_contacts;

ALTER TABLE my_contacts
DROP COLUMN salary;

UPDATE job_desired
SET
    title = 'python developer',
    years_exp = 5,
    salary_high = 1800,
    available = 'y'
WHERE contact_id = 1;

UPDATE job_desired
SET
    title = 'computer scientiest',
    years_exp = 10,
    salary_high = 1400,
    available = 'y'
WHERE contact_id = 2;

UPDATE job_desired
SET
    title = 'techical writer',
    years_exp = 8,
    salary_high = 1500,
    available = 'y'
WHERE contact_id = 3;

UPDATE job_desired
SET
    title = 'java developer',
    years_exp = 4,
    salary_high = 2000,
    available = 'n'
WHERE contact_id = 4;

UPDATE job_desired
SET
    title = 'figma designer',
    years_exp = 2,
    salary_high = 2000,
    available = 'y'
WHERE contact_id = 5;


CREATE TABLE job_listings (
    job_id SERIAL NOT NULL PRIMARY KEY,
    title VARCHAR(50),
    description VARCHAR(200),
    salary INT CHECK(salary > 0),
    location_id INT NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(id)
);

INSERT INTO job_listings
    VALUES
        (DEFAULT, 'techical writer', '', 2000, 1),
        (DEFAULT, 'web developer', '', 2300, 2),
        (DEFAULT, 'accountant', '', 2300, 2),
        (DEFAULT, 'python developer', '', 2500, 1);

SELECT mc.first_name, mc.last_name
FROM my_contacts AS mc
NATURAL JOIN job_desired AS jd
WHERE
    jd.title = 'python developer'
    AND jd.years_exp > 4
    AND jd.salary_high < 2500;


-- RecursiveForeignKey (RFK) / (Self-Referehcing Foreign key)
ALTER TABLE my_contacts ADD COLUMN boss_id INT NOT NULL DEFAULT 1;
ALTER TABLE my_contacts
ADD CONSTRAINT my_contacts_boss_id_fkey
FOREIGN KEY(boss_id) REFERENCES my_contacts(contact_id);

ALTER TABLE my_contacts ALTER COLUMN boss_id DROP DEFAULT;

UPDATE my_contacts
SET boss_id = 2 WHERE contact_id = 2;

UPDATE my_contacts
SET boss_id = 3 WHERE contact_id = 3;

UPDATE my_contacts
SET boss_id = 5 WHERE contact_id = 5;

UPDATE my_contacts
SET boss_id = 6 WHERE contact_id = 6;

UPDATE my_contacts
SET boss_id = 1 WHERE contact_id = 4;


-- VIEW
-- virtual table exists only when used in SUBQUERY

-- VIEW for INSERT UPDATE DELETE
-- used rarely
-- without aggregate functions
-- without BETWEEN, HAVING, IN, NOT IN

-- updatable VIEW should include all NOT NULL collumns
-- not updatable VIEW missed some NOT NULL collumns (we couldn't use to update base table)

CREATE VIEW available_python_developers AS
SELECT first_name, last_name, email FROM my_contacts
NATURAL JOIN job_desired
WHERE title = 'python developer' AND available = 'y';

-- \dv
-- \d+ available_python_developers

-- VIEWS behave like SUBQUERY
SELECT * from available_python_developers;

CREATE VIEW offers_techical_writers AS
SELECT * FROM job_listings
WHERE title = 'techical writer';

SELECT * from offers_techical_writers;

CREATE VIEW job_raised AS
SELECT first_name, last_name, email, jobs.salary, jobs.salary_high, (jobs.salary_high - salary) as raised
FROM my_contacts
NATURAL JOIN
(SELECT * FROM job_current
NATURAL JOIN job_desired) as jobs;

SELECT last_name, email, raised FROM job_raised
ORDER BY last_name;

-- create VIEW to check gender
CREATE VIEW my_contacts_with_check_gender AS
SELECT * FROM my_contacts
WHERE (gender IN ('M', 'F') OR gender IS NULL) WITH CHECK OPTION;

DROP VIEW my_contacts_with_check_gender;

-- Temporary tables
CREATE TEMPORARY TABLE tmp_table(
    contact_id INT
);

CREATE TEMPORARY TABLE tmp_contacts AS SELECT * FROM my_contacts;


-- INDEX
-- save additional information about column
EXPLAIN ANALYZE SELECT * FROM my_contacts
WHERE last_name = 'Ami' AND first_name = 'Who';
-- Planning Time: 0.043 m
-- Execution Time: 0.017 ms
CREATE INDEX my_contacts_names ON my_contacts(last_name, first_name);

DROP INDEX my_contacts_names;

-- show index
SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = 'public' AND tablename = 'my_contacts'
ORDER BY tablename, indexname;


-- PROCEDURE
CREATE OR REPLACE PROCEDURE set_boss_id(sender_id int)
LANGUAGE PLPGSQL
AS
$$
BEGIN
UPDATE my_contacts SET boss_id = sender_id
WHERE contact_id = sender_id;
COMMIT;
END;
$$;

ALTER ROUTINE set_boss_id(integer) RENAME TO reset_boss_id;
CALL reset_boss_id(14);
DROP PROCEDURE reset_boss_id;

CREATE OR REPLACE PROCEDURE increase_salary(sender_id int, amount int)
LANGUAGE PLPGSQL
AS
$$
BEGIN
UPDATE job_desired
SET salary_low = salary_low + amount
WHERE contact_id = sender_id;

UPDATE job_desired
SET salary_high = salary_high + amount
WHERE contact_id = sender_id;
COMMIT;
END;
$$;

CALL increase_salary(1, 200);


-- FUNCTION
CREATE OR REPLACE FUNCTION get_boss_id(sender_id int) RETURNS int
AS
'SELECT boss_id FROM my_contacts WHERE contact_id = sender_id;'
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;

SELECT get_boss_id(14);

DROP FUNCTION get_boss_id;


-- TRIGGER
CREATE OR REPLACE FUNCTION set_boss_id()
RETURNS TRIGGER
LANGUAGE PLPGSQL
AS
$$
BEGIN
UPDATE my_contacts SET boss_id = NEW.contact_id
WHERE contact_id = NEW.contact_id;
RAISE NOTICE 'boss_id updated!';
RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS boss_id_updated ON my_contacts;
CREATE TRIGGER boss_id_updated
  AFTER INSERT
  ON my_contacts
  FOR EACH ROW
  EXECUTE PROCEDURE set_boss_id();

INSERT INTO my_contacts VALUES(
    DEFAULT, 'V', 'Alex', '1983-07-19', 'v@mail.com', '123-9090', 'M', 2, 1, 1, 1
);

TABLE my_contacts;
