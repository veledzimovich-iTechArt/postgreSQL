-- shop

-- CUSTOMER
TABLE all_units;
TABLE all_reserved_units;

CALL reserve_unit_for_user(3,4,2);

TABLE all_units;
TABLE all_reserved_units;

CALL update_unit_for_user(3,4,1);

TABLE all_units;
TABLE all_reserved_units;

CALL buy(3);

TABLE all_units;
TABLE all_reserved_units;
TABLE all_users;

CALL reserve_unit_for_user(2,3,2);

TABLE all_units;
TABLE all_reserved_units;
TABLE all_users;

DO
$$
DECLARE
    tea_amount int;
    total_reserved_amount int;
    whoami_to_pay_amount decimal;
    whoami_account_amount decimal;
BEGIN
    SELECT amount INTO tea_amount FROM units WHERE unit_id = 4;

    SELECT count(*) INTO total_reserved_amount FROM reserved_units;

    SELECT to_pay_for_user(3) INTO whoami_to_pay_amount;

    SELECT amount INTO whoami_account_amount
    FROM app_accounts WHERE app_accounts.user_id = 3;

    ASSERT tea_amount = 1, 'Wrong tea amount';

    ASSERT total_reserved_amount = 0, 'Wrong reserved amount';
    ASSERT whoami_to_pay_amount = 0.00, 'Wrong whoami to pay amount';
    ASSERT whoami_account_amount = 2.00, 'Wrong whoami account amount';
END
$$;
