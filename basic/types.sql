-- postgreSQL
CREATE EXTENSION postgis;

SELECT 'Data types' AS data_types;

SELECT
    'NULL special SQL value for missing unknown data' AS null,
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

-- NUMERIC
SELECT 'NUMERIC numeric.sql' AS numeric;

-- CHAR VARCHAR
SELECT 'CHAR VARCHAR TEXT string.sql' AS string;

-- DATE
SELECT 'DATE TIME date_time.sql' AS date_time;

SELECT 'ENUM' AS enum;
DROP TABLE IF EXISTS person;
DROP TYPE mood;
CREATE TYPE mood AS ENUM ('sad', 'ok', 'happy');
CREATE TABLE person (
    name text,
    current_mood mood
);
INSERT INTO person VALUES ('Alex', 'happy');
TABLE person;

-- JSON
SELECT 'JOSN JSONB json.sql' AS json;

-- Universally unique identifier
-- UUID RFC4122 better than serial (hide sensetive data)

-- Geometric types (PostGIS) spatial type (SP)
-- POINT two- or three-dimensional plane
-- LINESTRING
-- POLYGON
-- MULTIPOINT
-- MULTILINESTRING
-- MULTIPOLYGON
-- spatial reference system identifier (SRID) Unique ID

-- well-known text (WKT)
-- WKT representation

-- GEOGCS geographic coordinate system
-- PRIMEM prime meridian
SELECT srtext FROM spatial_ref_sys WHERE srid = 4326;

-- GEOGRAPHY a data type based on a sphere, using the round-Earth coordinate system (longitude and latitude)
-- globe, large area, less functions, more precise, in meters
-- GEOMETRY a data type based on a plane, using the Euclidean coordinate system.
-- plane, small area, more functions, less precise, in coord sys units

-- extended well-known binary (EWKB)

-- first Longitude second Latitude
SELECT ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326),
ST_AsEWKT(ST_GeomFromText('POINT(-74.9233606 42.699992)', 4326));

-- within 10 km
SELECT ST_DWithin(
    ST_GeogFromText('POINT(-93.674728 41.6209851)'),
    ST_GeogFromText('POINT(-93.6204386 41.5853202)'), 10000);

-- from Oliva star to Mount Mansfield in Vermont
SELECT ST_Distance(
   ST_GeogFromText('POINT(18.570457 54.403635)'),
   ST_GeogFromText('POINT(-72.81431 44.543947)')
) / 1000 AS to_mansfield_in_km;
-- from Oliva star to Golebia
SELECT ST_Distance(
   ST_GeogFromText('POINT(18.607817441983332 54.38537632950609)'),
   ST_GeogFromText('POINT(18.570457 54.403635)')
) / 1000 AS to_golebia_in_km;

-- To perform calculations related to driving distances, check out the extension pgRouting

-- Shapefiles hold information describing the shape of a feature (such as a county, a road, or a lake)
-- shp2pgsql

-- Network address types
-- CIDR INET MACADDR (MAC address)

-- Range

-- Binary

-- XML

-- Arrays
SELECT ARRAY[1,2,3];
SELECT (ARRAY[1,2,3])[1] AS first;

SELECT UNNEST(ARRAY[1,2,3]) LIMIT 1;

-- Text search types
-- TSVECTOR
-- reduces text to a sorted list of lexemes
-- removes stop words that don’t play a role in search ('the' or 'it').
-- It orders the words alphabetically, with position in the string
SELECT ARRAY_AGG(cfgname) FROM pg_ts_config;
SELECT to_tsvector(
    'english', 'I am walking across the sitting room to sit with you.'
);
-- TSQUERY
-- full-text search query optimized as lexemes
-- provides operators for controlling the search
-- & (AND)
-- | (OR)
-- ! (NOT)
SELECT to_tsquery('english', 'walking & sitting');


WITH my_messages(value) AS (
   VALUES ('I am walking across the sitting room')
)
-- @@ Match Operator for Searching
SELECT to_tsvector('english', value) @@
       to_tsquery('english', 'walking & running') AS and
    ,
    to_tsvector('english', value)
    @@ to_tsquery('english', 'walking | running') AS or,
    -- <-> immediately followed
    to_tsvector('english', value) @@
       to_tsquery('english', 'walking <-> across') as followed,
    -- <2>  two words apart
    to_tsvector('english', value) @@
       to_tsquery('english', 'walking <1> sitting') as two_appart
FROM my_messages;

SELECT ts_headline(
    'I am walking across the sitting room',
    to_tsquery('english', 'walking & sitting'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1'
);

SELECT ts_headline(
    'I am walking across the sitting room',
    to_tsquery('english', 'walking & !sitting'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1'
)
WHERE to_tsvector(
    'english', 'I am walking across the sitting room')
    @@
       to_tsquery('english', 'walking & !sitting');

-- ts_rank() returned as a variable-precision real data type based on how often the lexemes you’re searching for appear in the text
WITH my_text(message) AS (
   SELECT * FROM UNNEST(
        ARRAY[
            'I am walking and walking across the sitting room',
            'I am walking across the sitting room',
            'The big sitting room',
            'sitting Walker'
        ]
    )
)
SELECT message,
    ts_rank(
        to_tsvector('english', message),
        to_tsquery('english', 'walking | sitting')
    ) as score,
    -- 2 instructs the function to divide the score by the length of the data in the message
    ts_rank(
        to_tsvector('english', message),
        to_tsquery('english', 'walking | sitting'), 2
    ) as divided_score
FROM my_text
ORDER BY score DESC;


-- ts_rank_cd() considers how close the lexemes searched are to each other.

SELECT message,
    ts_rank_cd(
        to_tsvector('english', message),
        to_tsquery('english', 'walking | sitting'), 2
    ) as score
FROM UNNEST(ARRAY[
        'I am walking and walking across the sitting room',
        'I am walking across the sitting room',
        'The big sitting room',
        'sitting Walker'
    ]
) AS message
ORDER BY score DESC;
