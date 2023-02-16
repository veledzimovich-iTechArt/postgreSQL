-- HACKS

-- reset autoincrement
-- ALTER SEQUENCE users_user_id_seq RESTART WITH 1;

-- performance
EXPLAIN SELECT VERSION();
EXPLAIN ANALYZE SELECT * FROM generate_series(2,4);

-- range
SELECT * FROM generate_series(2,4);

-- random
SELECT random()*(10-1)+1;
SELECT floor(random()*(10-1+1))+1;

-- variables
DO $$
DECLARE tmpvar VARCHAR(32) := 'temp variable';
BEGIN
RAISE NOTICE '%', tmpvar;
END $$;

DO $$
DECLARE create_time TIME := NOW();
BEGIN
RAISE NOTICE '%', create_time;
PERFORM pg_sleep(1);
RAISE NOTICE '%', create_time;
END $$;

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

-- prime numbers
WITH RECURSIVE cte AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 32
)

SELECT ARRAY_TO_STRING(ARRAY_AGG(n), '&') FROM cte
WHERE n NOT IN (SELECT DISTINCT cte.n FROM cte
    CROSS JOIN cte AS div
    WHERE cte.n > div.n AND MOD(cte.n, div.n) = 0);
