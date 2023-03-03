-- shop

-- it could be created for template1 DB (it will auto add for new DB)
CREATE EXTENSION citext;
CREATE EXTENSION tablefunc;

CREATE DOMAIN phone_number_domain AS VARCHAR(15) CHECK(
    VALUE ~ '^(\+\d{2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{3}$'
);

CREATE DOMAIN email_domain AS CITEXT CHECK(
    VALUE ~ '^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$'
);


-- TABLES

CREATE TABLE users(
    user_id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    username VARCHAR(64) NOT NULL UNIQUE,
    first_name VARCHAR(64) UNIQUE,
    last_name VARCHAR(64) UNIQUE,
    email email_domain NOT NULL UNIQUE,
    phone phone_number_domain UNIQUE
);

CREATE TABLE app_accounts(
    user_id INT PRIMARY KEY REFERENCES users(user_id),
    amount DECIMAL(12, 2) DEFAULT 0 CHECK (amount >= 0)
);

CREATE TABLE shops(
    shop_id int PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name CITEXT NOT NULL UNIQUE
);

CREATE TABLE units(
    unit_id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    shop_id INT NOT NULL,
    name CITEXT NOT NULL,
    weight DECIMAL(12, 2) DEFAULT 1 CHECK(weight > 0),
    price DECIMAL(12, 2) DEFAULT 1 CHECK(price > 0),
    price_for_kg DECIMAL(12, 2) GENERATED ALWAYS AS ((1 / weight) * price) STORED,
    amount INT DEFAULT 1 CHECK(amount >= 0),
    FOREIGN KEY(shop_id) REFERENCES shops(shop_id),
    UNIQUE (shop_id, name, weight),
    created_at timestamptz NOT NULL
);

CREATE TABLE reserved_units(
    reserved_unit_id bigint PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id INT NOT NULL,
    unit_id INT NOT NULL,
    amount INT DEFAULT 1 CHECK(amount > 0),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(unit_id) REFERENCES units(unit_id),
    UNIQUE (user_id, unit_id)
);


-- FUNCTIONS

CREATE OR REPLACE FUNCTION create_user_app_account()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    INSERT INTO app_accounts VALUES (NEW.user_id);
    RAISE NOTICE 'App account created!';
    RETURN NULL;
    END;
$$;

CREATE OR REPLACE FUNCTION subtract_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount - New.amount
    WHERE unit_id = NEW.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    -- RAISE NOTICE 'Units amount subtracted!';
    RETURN NULL;
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE FUNCTION update_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount + (OLD.amount - NEW.amount)
    WHERE unit_id = OLD.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    -- RAISE NOTICE 'Units amount updated!';
    RETURN NULL;
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE FUNCTION add_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount + OLD.amount
    WHERE unit_id = OLD.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    -- RAISE NOTICE 'Units amount added!';
    RETURN NULL;
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE FUNCTION to_pay_for_user(sender_id INT)
RETURNS DECIMAL
LANGUAGE PLPGSQL
AS
$total_amount$
    DECLARE total_amount DECIMAL;
    BEGIN

    SELECT COALESCE(sum(total), 0)::DECIMAL INTO total_amount
    FROM (
        SELECT user_id, (units.price * reserved_units.amount) as total
        FROM reserved_units
        INNER JOIN units ON units.unit_id = reserved_units.unit_id
        WHERE user_id = sender_id
    ) as all_reserved_total;


    RETURN total_amount;
    END;
$total_amount$;


-- TRIGGERS

CREATE TRIGGER user_app_account_created
  AFTER INSERT
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE create_user_app_account();

CREATE TRIGGER unit_amount_updated_after_reserved_unit_has_been_inserted
  AFTER INSERT
  ON reserved_units
  FOR EACH ROW
  EXECUTE PROCEDURE subtract_unit_amount();

CREATE TRIGGER unit_amount_updated_after_reserved_unit_has_been_updated
  AFTER UPDATE
  -- AFTER UPDATE OF amount
  ON reserved_units
  FOR EACH ROW
  EXECUTE PROCEDURE update_unit_amount();

CREATE TRIGGER unit_amount_updated_after_reserved_unit_has_been_deleted
  AFTER DELETE
  ON reserved_units
  FOR EACH ROW
  EXECUTE PROCEDURE add_unit_amount();


-- PROCEDURES
CREATE OR REPLACE PROCEDURE refresh_all_reserved_units_with_user_id()
LANGUAGE PLPGSQL
AS
$$
    -- run with priveligies of the user that defines the procedure
    BEGIN
        REFRESH MATERIALIZED VIEW all_reserved_units_with_user_id;
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE PROCEDURE delete_without_trigger(sender_id INT)
LANGUAGE PLPGSQL
AS
$$
    -- run with priveligies of the user that defines the procedure
    BEGIN
        ALTER TABLE reserved_units
        DISABLE TRIGGER unit_amount_updated_after_reserved_unit_has_been_deleted;

        DELETE FROM reserved_units WHERE user_id = sender_id;
        CALL refresh_all_reserved_units_with_user_id();

        ALTER TABLE reserved_units
        ENABLE TRIGGER unit_amount_updated_after_reserved_unit_has_been_deleted;
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE PROCEDURE buy(sender_id INT)
LANGUAGE PLPGSQL
AS
$$
    DECLARE total_amount DECIMAL;
    BEGIN
    SELECT amount INTO total_amount FROM app_accounts
    WHERE app_accounts.user_id = sender_id;

    SELECT (total_amount - (SELECT to_pay_for_user(sender_id)))
    INTO total_amount;

    CALL update_account_amount_for_user(
        sender_id, total_amount
    );

    CALL delete_without_trigger(sender_id);

    RAISE NOTICE 'Reserved units bought!';
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE PROCEDURE clear(sender_id INT)
LANGUAGE PLPGSQL
AS
$$
    BEGIN

    UPDATE units SET amount = units.amount + reserved.amount
    FROM (
        SELECT unit_id, amount FROM reserved_units
        WHERE user_id = sender_id
    ) AS reserved
    WHERE units.unit_id = reserved.unit_id;

    CALL delete_without_trigger(sender_id);
    RAISE NOTICE 'Reserved units cleared!';
    END;
$$ SECURITY DEFINER;

CREATE OR REPLACE PROCEDURE reserve_unit_for_user(
    sender_id INT, unit_to_reserve_id INT, quantity INT
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    INSERT INTO reserved_units (user_id, unit_id, amount)
    VALUES (sender_id, unit_to_reserve_id, quantity);
    CALL refresh_all_reserved_units_with_user_id();
    -- RAISE NOTICE 'Unit reserved!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE update_unit_for_user(
    sender_id INT, unit_to_reserve_id INT, quantity INT
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE reserved_units SET amount = quantity
    WHERE user_id = sender_id AND unit_id = unit_to_reserve_id;
    RAISE NOTICE 'Unit updated!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE delete_unit_for_user(
    sender_id INT, unit_to_delete_id INT
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN

    DELETE FROM reserved_units
    WHERE user_id = sender_id AND unit_id = unit_to_delete_id;
    RAISE NOTICE 'Unit deleted!';
    COMMIT;
    END;
$$;


CREATE OR REPLACE PROCEDURE create_admin_user(
    username varchar, email varchar
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    INSERT INTO users(username, email)
    VALUES (username, email);

    EXECUTE FORMAT('DROP USER IF EXISTS %s', username, username);
    EXECUTE FORMAT('CREATE USER %s', username);
    EXECUTE FORMAT('GRANT shop_admin TO %s', username);

    RAISE NOTICE 'Admin user created!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE create_customer_user(
    username varchar, email varchar
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    INSERT INTO users(username, email)
    VALUES (username, email);

    EXECUTE FORMAT('DROP USER IF EXISTS %s', username, username);
    EXECUTE FORMAT('CREATE USER %s', username);
    EXECUTE FORMAT('GRANT shop_customer TO %s', username);

    RAISE NOTICE 'Customer user created!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE update_account_amount_for_user(
    sender_id INT, quantity DECIMAL
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE app_accounts SET amount = quantity
    WHERE user_id = sender_id;
    RAISE NOTICE 'Account amount updated!';
    END;
$$;


-- VIEWS

CREATE VIEW all_users AS
SELECT users.user_id, users.username, users.email, app_accounts.amount FROM users
NATURAL JOIN app_accounts
ORDER BY users.user_id;

CREATE VIEW all_shops
WITH (security_barrier) AS
SELECT name FROM shops
-- The view itself will restrict updates rows matching the condition in the WHERE clause.
WHERE name = (
    SELECT name FROM shops AS old_shops
    WHERE shops.name = old_shops.name
)
-- The LOCAL CHECK OPTION also prevents a user from changing name.
ORDER BY shops.shop_id
WITH LOCAL CHECK OPTION;

CREATE VIEW all_units_with_unit_id AS
SELECT units.unit_id, shops.name AS shop_name, units.name, units.weight, units.price, units.price_for_kg, units.amount FROM units
INNER JOIN shops ON shops.shop_id = units.shop_id
ORDER BY units.unit_id;

CREATE VIEW all_units AS
SELECT shop_name, name, weight, price, price_for_kg, amount
FROM all_units_with_unit_id;

CREATE MATERIALIZED VIEW all_reserved_units_with_user_id AS
SELECT users.user_id, users.username, shops.name AS shop_name, units.unit_id, units.name,  units.weight, units.price, units.price_for_kg, reserved_units.amount,  (units.price * reserved_units.amount) as total FROM reserved_units
INNER JOIN units ON units.unit_id = reserved_units.unit_id
INNER JOIN users ON users.user_id = reserved_units.user_id
INNER JOIN shops ON shops.shop_id = units.shop_id
ORDER BY reserved_units.reserved_unit_id;

CREATE VIEW all_reserved_units AS
SELECT username, shop_name, unit_id, name, weight, price, price_for_kg, amount, total
FROM all_reserved_units_with_user_id;

CREATE VIEW all_reserved_units_for_customer
WITH (security_barrier) AS
SELECT username, shop_name, unit_id, name, weight, price, price_for_kg, amount, total
FROM all_reserved_units_with_user_id

WHERE current_user = (
    SELECT username
    FROM users
    WHERE user_id = all_reserved_units_with_user_id.user_id
);
