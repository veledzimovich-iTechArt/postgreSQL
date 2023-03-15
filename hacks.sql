-- HACKS

CREATE EXTENSION tablefunc;

-- reset autoincrement
-- ALTER SEQUENCE users_user_id_seq RESTART WITH 1;

-- performance
EXPLAIN SELECT VERSION();
EXPLAIN ANALYZE SELECT * FROM generate_series(2,4);

-- vacuum
SELECT relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    vacuum_count,
    autovacuum_count
FROM pg_stat_user_tables;

VACUUM VERBOSE;
SELECT pg_size_pretty(pg_database_size(current_database()));
VACUUM FULL;
SELECT pg_size_pretty(pg_database_size(current_database()));

-- unnest
SELECT unnest(ARRAY[1,2,3,4]) AS unnest_array;

-- crosstab
SELECT * FROM crosstab (
'SELECT gender, prof_id, count(prof_id) FROM my_contacts
WHERE gender IS NOT NULL
GROUP BY gender, prof_id
ORDER BY gender',
'SELECT id FROM professions
GROUP BY id
ORDER BY id'
) AS (
    gender text,
    artist int,
    developer int,
    scientiest int,
    writer int
);

-- range
SELECT * FROM generate_series(2,4);

-- random
SELECT random()*(10-1)+1 AS random;
SELECT floor(random()*(10-1+1))+1 AS floor_random;

-- to table
WITH word_list(word) AS
(
    SELECT REGEXP_SPLIT_TO_TABLE(
        'Feynman: "What I cannot create, I do not understand."', '\s'
    )
)
SELECT
    LOWER(REGEXP_REPLACE(word, '[,.:"]+', '')) AS cleaned,
    count(*)
FROM word_list
WHERE LENGTH(word) >= 1
GROUP BY cleaned
ORDER BY count DESC;

-- variables
DO
$$
DECLARE tmpvar VARCHAR(32) := 'temp variable';
BEGIN
RAISE NOTICE '%', tmpvar;
END
$$;

-- sleep
DO
$$
DECLARE create_time TIME := NOW();
BEGIN
RAISE NOTICE '%', create_time;
PERFORM pg_sleep(1);
RAISE NOTICE '%', create_time;
END
$$;

-- while
CREATE OR REPLACE PROCEDURE dowhile()
LANGUAGE PLPGSQL AS
$$
DECLARE counter INT := 4;
BEGIN
    WHILE counter > 0 LOOP
        RAISE NOTICE '%', (SELECT REPEAT('* ', counter));
        counter = counter - 1;
    END LOOP;
COMMIT;
END;
$$;

CALL dowhile();

-- CTE as for loop
WITH RECURSIVE t(n) AS
(
    SELECT 1
    UNION ALL
    SELECT N + 1 FROM t
)
SELECT n FROM t LIMIT 10;

-- prime numbers
WITH RECURSIVE prime_cte AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1 FROM prime_cte WHERE n < 32
)

SELECT ARRAY_TO_STRING(ARRAY_AGG(n), '&') FROM prime_cte
WHERE n NOT IN (
    SELECT DISTINCT prime_cte.n FROM prime_cte
    CROSS JOIN prime_cte AS div
    WHERE prime_cte.n > div.n AND MOD(prime_cte.n, div.n) = 0
);


