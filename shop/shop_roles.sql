-- shop

-- ROLES

DROP USER shop_admin;

DROP POLICY accounts_for_customers ON app_accounts;
DROP POLICY reserved_for_customers ON reserved_units;

REVOKE SELECT ON users FROM shop_customer;
REVOKE SELECT ON shops FROM shop_customer;

REVOKE SELECT, UPDATE ON app_accounts FROM shop_customer;
REVOKE SELECT, UPDATE ON units FROM shop_customer;

REVOKE USAGE, SELECT ON SEQUENCE reserved_units_reserved_unit_id_seq FROM shop_customer;
REVOKE ALL ON reserved_units FROM shop_customer;

REVOKE EXECUTE ON PROCEDURE delete_without_trigger FROM shop_customer;

-- REVOKE VIEWS

REVOKE SELECT ON all_shops FROM shop_customer;
REVOKE SELECT ON all_units FROM shop_customer;
REVOKE SELECT ON all_reserved_units FROM shop_customer;
REVOKE SELECT ON all_reserved_units_with_user_id FROM shop_customer;
REVOKE SELECT ON all_reserved_total FROM shop_customer;
REVOKE SELECT ON all_users FROM shop_customer;

DROP USER shop_customer;

CREATE ROLE shop_admin WITH PASSWORD 'shop_admin' LOGIN SUPERUSER;
CREATE ROLE shop_customer WITH PASSWORD 'shop_customer' LOGIN;

GRANT SELECT ON users TO shop_customer;
GRANT SELECT ON shops TO shop_customer;

GRANT SELECT, UPDATE ON app_accounts TO shop_customer;
GRANT SELECT, UPDATE ON units TO shop_customer;

GRANT USAGE, SELECT ON SEQUENCE reserved_units_reserved_unit_id_seq
TO shop_customer;
GRANT ALL ON reserved_units TO shop_customer;

-- GRANT EXECUTE

GRANT EXECUTE ON PROCEDURE delete_without_trigger TO shop_customer;
GRANT EXECUTE ON PROCEDURE refresh_all_reserved_units_with_user_id
TO shop_customer;

-- GRANT VIEWS

GRANT SELECT ON all_shops TO shop_customer;
GRANT SELECT ON all_units TO shop_customer;
GRANT SELECT ON all_reserved_units TO shop_customer;
-- for logic
GRANT SELECT ON all_reserved_units_with_user_id TO shop_customer;
GRANT SELECT ON all_reserved_total TO shop_customer;
GRANT SELECT ON all_users TO shop_customer;


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
