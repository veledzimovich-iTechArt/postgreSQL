-- shop

-- ADMIN

TABLE all_shops;
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
END
$$;

CALL clear(1);
CALL clear(2);
CALL clear(3);

TABLE all_units;
TABLE all_reserved_units;
