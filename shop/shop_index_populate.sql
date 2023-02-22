-- shop

-- POPULATE FOR INDEXES
-- always use indexes instead of seqscan
-- SET enable_seqscan = off;

SET client_min_messages = LOG;
-- SET log_duration = on;
-- additional statistics
-- SET log_statement_stats = on;
-- or
SET log_duration = off;
SET log_statement = none;
-- greate than 10 ms
SET log_min_duration_statement = 1;

-- heavy procedure
CALL create_admin_user('manager', 'manager@mail.com');

CALL update_account_amount_for_user(1, 10000);

INSERT INTO shops(name)
VALUES ('Lidl'), ('Carefour'), ('Zabka'), ('Biedronka');

CREATE OR REPLACE PROCEDURE generate_units(st INT, fin INT)
LANGUAGE PLPGSQL AS
$$
BEGIN
    INSERT INTO units (
        shop_id, name, weight, amount, price, created_at
    )
    SELECT
        floor(random()*(4-1+1))+1 AS shop_id,
        concat(substr(md5(random()::text), 0, 12), '-', counter),
        random()*(1-0.1)+0.1 AS weight,
        floor(random()*(15-5))+5 AS amount,
        random()*(10-1)+1 AS price,
        (('2015-01-01 0:00'::timestamptz) + (FORMAT('%s seconds', 30 * counter))::interval) AS created_at
    FROM generate_series(st, fin) AS counter;
COMMIT;
END;
$$;

-- inclusive
CALL generate_units(1, 200000);
SELECT count(*) FROM units;

-- heavy procedure
CREATE OR REPLACE PROCEDURE reserve_units_in_a_loop(num INT)
LANGUAGE PLPGSQL AS
$$
DECLARE counter INT := 1;
BEGIN
    WHILE counter <= num LOOP
        CALL reserve_unit_for_user(1,counter,1);
        counter = counter + 1;
    END LOOP;

COMMIT;
END;
$$;


