-- shop

-- CUSTOMER
TABLE all_shops;
TABLE all_units;
TABLE all_reserved_units_for_customer;
TABLE app_accounts;
TABLE users;

CALL reserve_unit_for_user(3,3,1);
CALL reserve_unit_for_user(3,4,2);

TABLE all_units;
TABLE all_reserved_units_for_customer;

-- didn't show for manager
SELECT to_pay_for_user(1);
-- showed for whoami
SELECT to_pay_for_user(3);

CALL delete_unit_for_user(3,3);
CALL update_unit_for_user(3,4,1);

TABLE all_units;
TABLE all_reserved_units_for_customer;

CALL buy(3);

TABLE all_units;
TABLE all_reserved_units_for_customer;
TABLE app_accounts;

-- exception
CALL reserve_unit_for_user(1,3,1);
CALL update_unit_for_user(1,3,2);
CALL delete_unit_for_user(1,3);

TABLE reserved_units;

CALL reserve_unit_for_user(3,3,1);
CALL update_unit_for_user(3,3,2);

-- exception
UPDATE reserved_units SET amount = 0;
-- allows to update only for logged user
UPDATE reserved_units SET amount = 1;
TABLE reserved_units;

-- alows to delete only for logged user
DELETE FROM reserved_units;
TABLE reserved_units;

SELECT count(*) FROM reserved_units;

-- To check run query TABLE reserved_units; with postgres user;

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



