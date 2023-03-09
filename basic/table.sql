-- basic

-- TABLE

DROP TABLE IF EXISTS my_contacts;
CREATE TABLE my_contacts (
    last_name VARCHAR(30) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    gender CHAR(1),
    birthday DATE,
    profession VARCHAR(50),
    location VARCHAR(50),
    status VARCHAR(20),
    interests VARCHAR(100),
    seeking VARCHAR(100)
);
-- DEFAULT
ALTER TABLE my_contacts ALTER COLUMN status SET DEFAULT 'SINGLE';


-- INSERT INTO
INSERT INTO my_contacts(last_name, first_name, email, gender, birthday, profession, location, status, interests, seeking)
VALUES
    ('Ami', 'Who', 'whoami@gmail.com', 'M', '1992-01-01', 'Writer', 'Los Angeles, CA', 'Single', 'Sci-Fi, Photography', 'Friends'),
    ('Who', 'Ami', 'amiwho@gmail.com', 'F', '1991-01-01', 'Developer', 'Los Angeles, CA', 'Single', 'Astronomy, Photography', 'Friends'),
    ('42', '196', 'sense@gmail.com', 'M', '1983-07-19', 'Developer', 'Los Angeles, CA', 'Single', 'Cooking', 'Board games');

INSERT INTO my_contacts(last_name, first_name, email, gender)
VALUES (
    'Me',
    'Me',
    'me@gmail.com',
    (SELECT gender FROM my_contacts WHERE last_name = 'Ami')
);

-- single quotes and 'E' with escape symbols
INSERT INTO my_contacts
VALUES ('Richard', E'O\'Keefe', 'keefe@gmail.com', 'M', '1960-05-01', 'Scientiest', 'Ireland', 'Single', 'Computers', 'Haskell'
);


-- SELECT
TABLE my_contacts;

SELECT * FROM my_contacts WHERE first_name = E'O\'Keefe';
-- or two apostrophes
SELECT * FROM my_contacts WHERE first_name = 'O''Keefe';

SELECT email FROM my_contacts
WHERE profession = 'Developer';

-- AND
SELECT last_name, first_name, email FROM my_contacts
WHERE gender = 'M' AND interests = 'Computers';

-- = <> < > <= >=
SELECT last_name, first_name, email FROM my_contacts
WHERE gender='M' AND birthday >= '1983-07-19';

SELECT last_name, first_name, email FROM my_contacts
WHERE gender <> 'M';

-- lexical order based on first chars
SELECT last_name, first_name FROM my_contacts
WHERE first_name > 'A' AND first_name < 'W';

-- OR
SELECT last_name, first_name FROM my_contacts
WHERE gender = 'M' OR gender = 'F';

-- NULL is special
-- NULL is NULL but value NULL != NULL
SELECT location FROM my_contacts
WHERE first_name = 'Nobody' AND gender = 'M';
-- get NULL
SELECT location FROM my_contacts
WHERE first_name = 'Nobody' OR status = 'Single';

SELECT gender FROM my_contacts
WHERE first_name = 'Me';

-- IS NULL
SELECT last_name, first_name, gender FROM my_contacts
WHERE gender IS NULL;

-- LIKE %
SELECT * FROM my_contacts
WHERE location LIKE '%CA';
-- LIKE _
SELECT * FROM my_contacts
WHERE first_name LIKE '__i';

-- BETWEEN <= >=
SELECT * FROM my_contacts
WHERE birthday BETWEEN '1990-01-01' AND '1991-01-01';

SELECT * FROM my_contacts
WHERE birthday < '1983-07-19' OR birthday > '1990-01-01';

SELECT * FROM my_contacts
WHERE first_name BETWEEN 'A' AND 'W';

-- IN
SELECT * FROM my_contacts
WHERE seeking IN ('Haskell', 'Board games');

-- NOT
SELECT * FROM my_contacts
WHERE seeking NOT IN ('Haskell', 'Board games');
SELECT * FROM my_contacts
WHERE NOT seeking IN ('Haskell', 'Board games');

SELECT * FROM my_contacts
WHERE NOT birthday BETWEEN '1990-01-01' AND '1991-01-01';

SELECT last_name FROM my_contacts
WHERE NOT last_name LIKE 'A%' AND NOT last_name LIKE 'W%';

SELECT * FROM my_contacts
WHERE NOT profession = 'Developer' AND NOT location LIKE 'I%';

SELECT profession FROM my_contacts
WHERE NOT profession <> 'Developer';
-- same
SELECT profession FROM my_contacts
WHERE profession = 'Developer';

SELECT * FROM my_contacts
WHERE profession IS NOT NULL;


-- ALTER
-- ADD COLUMN
ALTER TABLE my_contacts
ADD COLUMN contact_id SERIAL NOT NULL PRIMARY KEY;

ALTER TABLE my_contacts
ADD COLUMN mobile_phone VARCHAR(10);

ALTER TABLE my_contacts
RENAME COLUMN location TO country;

ALTER TABLE my_contacts
ALTER COLUMN country TYPE VARCHAR(30);

ALTER TABLE my_contacts
ADD COLUMN city VARCHAR(20);
ALTER TABLE my_contacts
ADD COLUMN state VARCHAR(20);

-- RENAME
ALTER TABLE my_contacts RENAME TO old;
CREATE TABLE my_contacts (
-- better to user int PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY
    contact_id SERIAL NOT NULL PRIMARY KEY,
    last_name character varying(30) NOT NULL,
    first_name character varying(20) NOT NULL,
    birthday date,
    profession character varying(50),
    email character varying(50) NOT NULL,
    mobile_phone character varying(10),
    city character varying(20),
    state character varying(20),
    country character varying(30),
    gender character(1),
    status character varying(20) DEFAULT 'SINGLE'::character varying,
    interests character varying(100),
    seeking character varying(100)
);

-- Copy table to rearange columns
INSERT INTO my_contacts (contact_id, last_name, first_name, birthday, profession, email, mobile_phone, city, state, country, gender, status, interests, seeking)
SELECT contact_id, last_name, first_name, birthday, profession, email, mobile_phone, city, state, country, gender, status, interests, seeking FROM old;
DROP TABLE old;

ALTER TABLE my_contacts
ADD COLUMN salary INT DEFAULT 1000;

-- RENAME COLUMN
ALTER TABLE my_contacts
RENAME COLUMN mobile_phone TO mobile;
ALTER TABLE my_contacts
ALTER COLUMN mobile TYPE VARCHAR(16);

-- DROP COLUMN
ALTER TABLE my_contacts
ADD COLUMN social_media VARCHAR(32);

ALTER TABLE my_contacts
DROP COLUMN social_media;

-- REMOVE PRIMARY KEY (hard to back again)
ALTER TABLE my_contacts DROP CONSTRAINT my_contacts_pkey1;
ALTER TABLE my_contacts ALTER COLUMN contact_id DROP DEFAULT;
ALTER TABLE my_contacts ALTER COLUMN contact_id DROP NOT NULL;

-- RESET PRIMARY KEY
ALTER TABLE my_contacts ADD PRIMARY KEY (contact_id);
-- same
-- ALTER TABLE my_contacts
-- ADD CONSTRAINT my_contacts_pkey PRIMARY KEY(contact_id);

-- ADD DEFAULT INDENTITY
ALTER TABLE my_contacts
ALTER COLUMN contact_id
ADD GENERATED BY DEFAULT AS IDENTITY (START WITH 6);
-- DROP IDENTITY
-- ALTER TABLE my_contacts ALTER COLUMN contact_id DROP IDENTITY;

-- same
-- -- create side sequence and after add default value
-- CREATE SEQUENCE contact_id_seq;
-- ALTER TABLE my_contacts
-- ALTER COLUMN contact_id SET DEFAULT nextval('contact_id_seq');
-- -- DROP DEFAULT
-- -- ALTER TABLE my_contacts ALTER COLUMN contact_id DROP DEFAULT;
-- RESTART counter
-- ALTER SEQUENCE contact_id_seq RESTART WITH 6;
-- -- DROP SEQUENCE
-- -- DROP SEQUENCE contact_id_seq;


-- DELETE
INSERT INTO my_contacts(
    contact_id, last_name, first_name, email, status
)
VALUES (DEFAULT, 'Me', 'Me', 'me@gmail.com', 'Married');
DELETE FROM my_contacts WHERE status = 'Married' AND first_name='Me';

INSERT INTO my_contacts(
    contact_id, last_name, first_name, email, status
)
VALUES (DEFAULT, 'Me', 'Me', 'me@gmail.com', 'Married');


-- UPDATE
UPDATE my_contacts
SET
    email = 'meme@gmail.com',
    profession = 'Artist'
WHERE first_name = 'Me';

UPDATE my_contacts
SET
    last_name = E'O\'Keefe',
    first_name = 'Richard'
WHERE profession = 'Scientiest' AND email = 'keefe@gmail.com';

UPDATE my_contacts SET status = UPPER(status);

UPDATE my_contacts
SET state = RIGHT(country, 2);

UPDATE my_contacts
SET country = 'Ireland' WHERE state = 'nd';
UPDATE my_contacts
SET country = 'Los Angeles, CA' WHERE country = 'Los Angeles';

UPDATE my_contacts
SET city =
    CASE
        WHEN POSITION(',' IN country) <> 0
            THEN SUBSTRING(country, 0, POSITION(',' IN country))
        ELSE ''
    END;

UPDATE my_contacts
SET country =
    CASE
        WHEN country = 'Los Angeles, CA' THEN 'USA'
        WHEN country = 'Ireland' THEN country
        ELSE ''
    END;

UPDATE my_contacts
SET state = NULL WHERE state = 'nd';

UPDATE my_contacts
SET city = 'Dublin'
WHERE country = 'Ireland' AND last_name = E'O\'Keefe';

UPDATE my_contacts
SET country = 'China'
WHERE country = '';


-- RETURNING updated data
UPDATE my_contacts
SET birthday = birthday - 1
WHERE first_name = 'Ami' OR last_name = 'Ami'
RETURNING *;
