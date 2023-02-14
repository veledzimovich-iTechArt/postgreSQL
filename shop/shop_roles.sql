-- shop

-- ROLES

DROP USER shop_admin;

DROP POLICY reserved_for_customers ON reserved_units;
DROP POLICY accounts_for_customers ON app_accounts;
DROP POLICY users_for_customers ON users;

REVOKE SELECT ON users FROM shop_customer;
REVOKE SELECT ON shops FROM shop_customer;

REVOKE SELECT ON app_accounts FROM shop_customer;
REVOKE SELECT ON units FROM shop_customer;

REVOKE USAGE, SELECT ON SEQUENCE reserved_units_reserved_unit_id_seq
FROM shop_customer;
REVOKE SELECT, INSERT, UPDATE(amount), DELETE ON reserved_units FROM shop_customer;

-- REVOKE EXECUTE
-- SECURITY DEFINER
REVOKE EXECUTE ON FUNCTION subtract_unit_amount FROM shop_customer;
REVOKE EXECUTE ON FUNCTION update_unit_amount FROM shop_customer;
REVOKE EXECUTE ON FUNCTION add_unit_amount FROM shop_customer;
REVOKE EXECUTE ON PROCEDURE buy FROM shop_customer;
REVOKE EXECUTE ON PROCEDURE delete_without_trigger FROM shop_customer;
REVOKE EXECUTE ON PROCEDURE refresh_all_reserved_units_with_user_id
FROM shop_customer;

-- REVOKE VIEWS

REVOKE SELECT ON all_shops FROM shop_customer;
REVOKE SELECT ON all_units FROM shop_customer;
REVOKE SELECT ON all_reserved_units_for_customer FROM shop_customer;

DROP USER shop_customer;

CREATE ROLE shop_admin WITH PASSWORD 'shop_admin' LOGIN SUPERUSER;
CREATE ROLE shop_customer WITH PASSWORD 'shop_customer' LOGIN;

GRANT SELECT ON users TO shop_customer;
GRANT SELECT ON shops TO shop_customer;

GRANT SELECT ON app_accounts TO shop_customer;
GRANT SELECT ON units TO shop_customer;

GRANT USAGE, SELECT ON SEQUENCE reserved_units_reserved_unit_id_seq
TO shop_customer;
GRANT SELECT, INSERT, UPDATE(amount), DELETE
ON reserved_units TO shop_customer;

-- GRANT EXECUTE
-- SECURITY DEFINER
GRANT EXECUTE ON FUNCTION subtract_unit_amount TO shop_customer;
GRANT EXECUTE ON FUNCTION update_unit_amount TO shop_customer;
GRANT EXECUTE ON FUNCTION add_unit_amount TO shop_customer;
GRANT EXECUTE ON PROCEDURE buy TO shop_customer;
GRANT EXECUTE ON PROCEDURE delete_without_trigger TO shop_customer;
GRANT EXECUTE ON PROCEDURE refresh_all_reserved_units_with_user_id
TO shop_customer;

-- GRANT VIEWS

GRANT SELECT ON all_shops TO shop_customer;
GRANT SELECT ON all_units TO shop_customer;
GRANT SELECT ON all_reserved_units_for_customer TO shop_customer;

-- POLICY
ALTER TABLE reserved_units ENABLE ROW LEVEL SECURITY;
CREATE POLICY reserved_for_customers ON reserved_units
    USING (
        current_user = (
            SELECT username
            FROM users
            WHERE user_id = reserved_units.user_id
        )
    );

ALTER TABLE app_accounts ENABLE ROW LEVEL SECURITY;
CREATE POLICY accounts_for_customers ON app_accounts
    USING (
        current_user = (
            SELECT username
            FROM users
            WHERE user_id = app_accounts.user_id
        )
    );

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY users_for_customers ON users
    USING (
        current_user = username
    );

