-- shop

-- POPULATE FOR INDEXES

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
-- create user
-- create account
CALL create_admin_user('manager', 'manager@mail.com');

CALL update_account_amount_for_user(1, 10000);


INSERT INTO shops(name)
VALUES ('Lidl'), ('Carefour'), ('Zabka'), ('Biedronka');



CREATE OR REPLACE PROCEDURE generate_units_in_a_loop(st INT, fin INT)
LANGUAGE PLPGSQL AS
$$
DECLARE counter INT := st;
BEGIN
    WHILE counter <= fin LOOP
        INSERT INTO units (shop_id, name, weight, amount, price)
        VALUES (
            floor(random()*(4-1+1))+1,
            concat(substr(md5(random()::text), 0, 12), '-', counter),
            random()*(1-0.1)+0.1,
            floor(random()*(10-1+1))+1,
            random()*(10-1)+1
        );
        counter = counter + 1;
    END LOOP;

COMMIT;
END;
$$;

-- inclusive
CALL generate_units_in_a_loop(1, 50000);
SELECT count(*) FROM units;

CREATE OR REPLACE PROCEDURE generate_units(st INT, fin INT)
LANGUAGE PLPGSQL AS
$$
BEGIN
    INSERT INTO units (shop_id, name, weight, amount, price)
    SELECT
        floor(random()*(4-1+1))+1 AS shop_id,
        concat(substr(md5(random()::text), 0, 12), '-', counter),
        random()*(1-0.1)+0.1 AS weight,
        floor(random()*(10-1+1))+1 AS amount,
        random()*(15-5)+5 AS price
    FROM generate_series(st, fin) AS counter;
COMMIT;
END;
$$;

-- inclusive
CALL generate_units(50001, 100000);
SELECT count(*) FROM units;

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


