-- postgreSQL

SELECT 'Data types' AS data_types;

SELECT
    'NULL special SQL value for missing data or unknown values' AS null,
    NULL AS null;

SELECT true AS boolean,
    'true'::boolean AS boolean,
    'yes'::boolean AS boolean,
    'y'::boolean AS boolean,
    't'::boolean AS boolean,
    'on'::boolean AS boolean,
    '1'::boolean AS boolean;

SELECT false AS boolean,
    'false'::boolean AS boolean,
    'no'::boolean AS boolean,
    'n'::boolean AS boolean,
    'f'::boolean AS boolean,
    'off'::boolean AS boolean,
    '0'::boolean AS boolean;

SELECT 'NUMERIC numeric.sql' as numeric;

SELECT 'CHAR VARCHAR TEXT string.sql' as string;

SELECT 'DATE TIME date_time.sql' as date_time;

SELECT 'ENUM' as enum;
DROP TABLE IF EXISTS person;
DROP TYPE mood;
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE TABLE person (
    name text,
    current_mood mood
);
INSERT INTO person VALUES ('Alex', 'happy');
TABLE person;
DROP TABLE person;

-- JSON exact copy of the JSON text
-- JSONB fast process slow to insert + indexing

-- Universally unique identifier
-- UUID RFC4122 better than serial (hide sensetive data)

-- Geometric types
-- POINT BOX LINE LSEQ (line segment) POLYGON CIRCLE

-- Network address types
-- CIDR INET MACADDR (MAC address)

-- Range

-- Binary

-- XML

-- Arrays
-- Text search types
