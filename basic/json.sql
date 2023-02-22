-- basic

-- JSON

-- When users or applications need to arbitrarily create key/value pairs.
-- When storing related data in a JSON column instead of a separate table (attributes that don’t apply to every employee).
-- When saving time by analyzing JSON data fetched from other systems without first parsing it into a set of tables.

-- JSON exact copy of the JSON text
-- (keeping white space)
-- (preserve the order of keys)
-- (preserve each of the repeated key/value)

-- JSONB fast process slow to insert + indexing
-- (removing white space)
-- (not maintaining the order of keys)
-- (preserve only the last of the key/value pairs)

DROP TABLE IF EXISTS silver_bullets;
CREATE TABLE silver_bullets (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    bullet jsonb NOT NULL
);
INSERT INTO silver_bullets(bullet) VALUES
    ('{
        "language" : "Red",
        "year": 2018,
        "projects": ["icon", "core"],
        "resources": {
            "home": "www.red-lang.org",
            "tutorials": "www.red-by-example.org"
        },
        "developers": [
            {"first_name": "Nenad ", "last_name": "Rakocevic"}
        ]
    }'),
    ('{
        "language" : "Haskell",
        "year": 2022,
        "projects": ["node"],
        "resources": {
            "home": "www.haskell.org"
        },
        "developers": [
            {"first_name": "Philip", "last_name": "Wadler"},
            {"first_name": "Lennart", "last_name": "Augustsson"}
        ]
    }');
TABLE silver_bullets;

-- Extracts a key value, specified as json data (raw)
SELECT id, bullet -> 'language' AS title
FROM silver_bullets
ORDER BY id;
-- Extracts a key value, specified as text
SELECT id, bullet ->> 'language' AS title
FROM silver_bullets
ORDER BY id;

-- Returns the entire array as a JSON data type
SELECT id, bullet -> 'projects' AS projects
FROM silver_bullets
ORDER BY id;
-- Extracts first element of the JSON array
SELECT id, bullet -> 'projects' -> 0 AS projects
FROM silver_bullets
ORDER BY id;
-- Extracts last element of the JSON array as text
SELECT id, bullet -> 'projects' ->> -1 AS projects
FROM silver_bullets
ORDER BY id;

-- #> path
SELECT id, bullet #> '{projects, 0}' AS idx
FROM silver_bullets
ORDER BY id;

SELECT id, bullet #> '{resources, home}' AS idx
FROM silver_bullets
ORDER BY id;

-- @> containment operator
SELECT id, bullet ->> 'language' AS title,
    bullet @> '{"language": "Red"}'::jsonb AS has_home
FROM silver_bullets
ORDER BY id;

SELECT bullet ->> 'language' AS title,
       bullet ->> 'year' AS year
FROM silver_bullets
WHERE bullet @> '{"language": "Red"}'::jsonb;
--flipped
SELECT bullet ->> 'language' AS title,
       bullet ->> 'year' AS year
FROM silver_bullets
WHERE '{"language": "Red"}'::jsonb <@ bullet;

-- ? text string exist as a top-level key or array element
SELECT id, bullet ->> 'language' AS title
FROM silver_bullets
WHERE bullet ? 'projects';
-- ?| any
SELECT id, bullet ->> 'language' AS title
FROM silver_bullets
WHERE bullet ?| '{projects, resources}';
-- ?&
SELECT id, bullet ->> 'language' AS title
FROM silver_bullets
WHERE bullet ?& '{projects, resources}';

-- GeoJSON format ("Feature", "properties", "geometry")

-- update
UPDATE silver_bullets
SET bullet = bullet || '{"type": "dynamic"}'::jsonb
WHERE bullet @> '{"language": "Red"}'::jsonb;

UPDATE silver_bullets
SET bullet = bullet || jsonb_build_object('type', 'static')
WHERE bullet @> '{"language": "Haskell"}'::jsonb;

TABLE silver_bullets;

UPDATE silver_bullets
SET bullet = jsonb_set(bullet,
                 '{projects}',
                  bullet #> '{projects}' || '["editor"]',
                  true)
WHERE bullet @> '{"language": "Haskell"}'::jsonb;

TABLE silver_bullets;

-- delete
UPDATE silver_bullets
SET bullet = bullet - 'type'
WHERE bullet @> '{"language": "Haskell"}'::jsonb;

-- delete with path
UPDATE silver_bullets
SET bullet = bullet #- '{projects, 1}'
WHERE bullet @> '{"language": "Haskell"}'::jsonb;

TABLE silver_bullets;

-- length of an array
SELECT id,
       bullet ->> 'language' AS title,
       jsonb_array_length(bullet -> 'projects') AS num_projects
FROM silver_bullets
ORDER BY id;

-- array elements as rows
SELECT id,
       jsonb_array_elements(bullet -> 'projects') AS project_jsonb,
       jsonb_array_elements_text(bullet -> 'projects') AS project_text
FROM silver_bullets
ORDER BY id;

-- key-values from each item in an array
WITH devs (id, json) AS (
    SELECT id,
           jsonb_array_elements(bullet -> 'developers')
    FROM silver_bullets
)
SELECT id,
       json ->> 'first_name' AS fn,
       json ->> 'last_name' AS ln
FROM devs
ORDER BY id;

-- Convert table to JSON
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id SERIAL NOT NULL PRIMARY KEY,
    last_name VARCHAR(30) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    birthday DATE
);

INSERT INTO users(last_name, first_name, email, birthday)
VALUES
    ('Ami', 'Who', 'whoami@gmail.com', '1992-01-01'),
    ('Who', 'Ami', 'amiwho@gmail.com', '1991-01-01'),
    ('Richard', E'O\'Keefe', 'keefe@gmail.com', '1960-05-01');

SELECT to_json(users) AS json_rows
FROM users;
-- generate with row
SELECT to_json(row(user_id, last_name)) AS json_rows
FROM users;
-- generate with subquery
SELECT to_json(u) AS json_rows
FROM (
    SELECT user_id, last_name AS ln FROM users
) AS u;

-- aggregating the rows and converting to JSON
SELECT json_agg(to_json(u)) AS js
FROM (
    SELECT user_id, last_name, first_name FROM users
) AS u;

