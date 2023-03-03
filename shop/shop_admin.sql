-- shop

-- ADMIN

SELECT pg_size_pretty(
    pg_database_size(current_database())
);
SELECT pg_size_pretty(
    pg_total_relation_size('reserved_units')
) AS size_reserved_units;
SELECT pg_size_pretty(
    pg_total_relation_size('units')
) AS size_units;


TABLE all_shops;

-- security barier in shop
UPDATE all_shops SET name = 'Lidl2022' WHERE name = 'Lidl';

TABLE all_units;
TABLE all_reserved_units;
TABLE all_users;

CALL reserve_unit_for_user(1,1,2);
CALL reserve_unit_for_user(1,2,1);
CALL reserve_unit_for_user(2,3,1);
CALL reserve_unit_for_user(3,4,1);

TABLE all_units;
TABLE all_reserved_units;

-- clear for user with id 2
CALL clear(2);
-- buy for user with id 3
CALL buy(3);

TABLE all_units;
TABLE all_reserved_units;
TABLE all_users;


-- ASSERTS

DO
$$
DECLARE
    rice_amount int;
    beef_amount int;
    eggs_amount int;
    tea_amount int;
    total_reserved_amount int;
    admin_to_pay_amount decimal;
    atkins_to_pay_amount decimal;
    whoami_to_pay_amount decimal;
    admin_account_amount decimal;
    atkins_account_amount decimal;
    whoami_account_amount decimal;
    all_total_reserved_amount int;
BEGIN
    SELECT amount INTO rice_amount FROM units WHERE unit_id = 1;
    SELECT amount INTO beef_amount FROM units WHERE unit_id = 2;
    SELECT amount INTO eggs_amount FROM units WHERE unit_id = 3;
    SELECT amount INTO tea_amount FROM units WHERE unit_id = 4;

    SELECT count(*) INTO total_reserved_amount FROM reserved_units;

    SELECT to_pay_for_user(1) INTO admin_to_pay_amount;
    SELECT to_pay_for_user(2) INTO atkins_to_pay_amount;
    SELECT to_pay_for_user(3) INTO whoami_to_pay_amount;

    SELECT amount INTO admin_account_amount
    FROM app_accounts WHERE app_accounts.user_id = 1;

    SELECT amount INTO atkins_account_amount
    FROM app_accounts WHERE app_accounts.user_id = 2;

    SELECT amount INTO whoami_account_amount
    FROM app_accounts WHERE app_accounts.user_id = 3;

    ASSERT rice_amount = 0, 'Wrong rice amount';
    ASSERT beef_amount = 1, 'Wrong beef amount';
    ASSERT eggs_amount = 3, 'Wrong eggs amount';
    ASSERT tea_amount = 2, 'Wrong tea amount';

    ASSERT total_reserved_amount = 2, 'Wrong reserved amount';

    ASSERT admin_to_pay_amount = 6.00, 'Wrong admin to pay amount';
    ASSERT atkins_to_pay_amount = 0.00, 'Wrong atkins to pay amount';
    ASSERT whoami_to_pay_amount = 0.00, 'Wrong whoami to pay amount';

    ASSERT admin_account_amount = 10.00, 'Wrong admin account amount';
    ASSERT atkins_account_amount = 10.00, 'Wrong atkins account amount';
    ASSERT whoami_account_amount = 6.00, 'Wrong whoami account amount';

    SELECT count(*) INTO all_total_reserved_amount
    FROM all_reserved_units;
    ASSERT total_reserved_amount = all_total_reserved_amount, 'Wrong reserved view amount';
END
$$;

CALL clear(2);
CALL clear(3);

TABLE all_units;
TABLE all_reserved_units;


SELECT
    available.name,
    ordered.reserved_amount,
    available.available_amount,
    total_amount,
    round(
        available.available_amount/total_amount::numeric, 1
    ) AS percent
FROM (
    SELECT name, sum(amount) AS available_amount
    FROM units
    GROUP BY name
) AS available
JOIN (
    SELECT units.name, sum(reserved_units.amount) AS reserved_amount
    FROM reserved_units
    JOIN units ON reserved_units.unit_id = units.unit_id
    GROUP BY units.name
) AS ordered
ON available.name = ordered.name
JOIN LATERAL (
    SELECT ordered.reserved_amount + available.available_amount
    AS total_amount
) AS ta
ON true
ORDER BY percent DESC;

-- check size
SELECT pg_size_pretty(
    pg_database_size(current_database())
);

SELECT relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    vacuum_count,
    autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'reserved_units';

SELECT relname,
    n_live_tup,
    n_dead_tup,
    last_vacuum,
    last_autovacuum,
    vacuum_count,
    autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'units';

VACUUM VERBOSE reserved_units;

SELECT pg_size_pretty(
    pg_total_relation_size('reserved_units')
) AS size_reserved_units;

VACUUM VERBOSE units;

SELECT pg_size_pretty(
    pg_total_relation_size('units')
) AS size_units;

SELECT pg_size_pretty(
    pg_database_size(current_database())
);


VACUUM FULL units;


SELECT pg_size_pretty(
    pg_database_size(current_database())
);

VACUUM FULL;

SELECT pg_size_pretty(
    pg_database_size(current_database())
);
