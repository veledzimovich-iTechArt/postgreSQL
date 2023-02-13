-- shop

-- INIT

CREATE DOMAIN phone_number_domain AS VARCHAR(15) CHECK(
    VALUE ~ '^(\+\d{2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{3}$'
);

CREATE DOMAIN email_domain AS CITEXT CHECK(
    VALUE ~ '^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$'
);


-- TABLES

CREATE TABLE users(
    user_id SERIAL NOT NULL PRIMARY KEY,
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
    shop_id SERIAL NOT NULL PRIMARY KEY,
    name CITEXT NOT NULL UNIQUE
);

CREATE TABLE units(
    unit_id SERIAL NOT NULL PRIMARY KEY,
    shop_id INT NOT NULL,
    name CITEXT NOT NULL,
    weight DECIMAL(12, 2) DEFAULT 1 CHECK(weight > 0),
    price DECIMAL(12, 2) DEFAULT 1 CHECK(price > 0),
    price_for_kg DECIMAL(12, 2) GENERATED ALWAYS AS ((1 / weight) * price) STORED,
    amount INT DEFAULT 1 CHECK(amount >= 0),
    FOREIGN KEY(shop_id) REFERENCES shops(shop_id),
    UNIQUE (shop_id, name, weight)
);

CREATE TABLE reserved_units(
    reserved_unit_id SERIAL NOT NULL PRIMARY KEY,
    user_id INT NOT NULL,
    unit_id INT NOT NULL,
    amount INT DEFAULT 1 CHECK(amount > 0),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(unit_id) REFERENCES units(unit_id),
    UNIQUE (user_id, unit_id)
);


-- FUNCTIONS

CREATE OR REPLACE FUNCTION create_user_app_account()
RETURNS trigger AS
$$
    BEGIN
    INSERT INTO app_accounts VALUES (NEW.user_id);
    RAISE NOTICE 'App account created!';
    RETURN NULL;
    END;
$$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION subtract_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount - New.amount
    WHERE unit_id = NEW.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    RAISE NOTICE 'Units amount subtracted!';
    RETURN NULL;
    END;
$$;

CREATE OR REPLACE FUNCTION update_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount + (OLD.amount - NEW.amount)
    WHERE unit_id = OLD.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    RAISE NOTICE 'Units amount updated!';
    RETURN NULL;
    END;
$$;

CREATE OR REPLACE FUNCTION add_unit_amount()
RETURNS trigger
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE units SET amount = amount + OLD.amount
    WHERE unit_id = OLD.unit_id;
    CALL refresh_all_reserved_units_with_user_id();
    RAISE NOTICE 'Units amount added!';
    RETURN NULL;
    END;
$$;

CREATE OR REPLACE FUNCTION to_pay_for_user(sender_id int)
RETURNS decimal
LANGUAGE PLPGSQL
AS
$total_amount$
    DECLARE
        total_amount decimal;
    BEGIN

    SELECT COALESCE(sum(total), 0)::decimal INTO total_amount
    FROM all_reserved_total
    WHERE all_reserved_total.user_id = sender_id;

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

CREATE OR REPLACE PROCEDURE delete_without_trigger(sender_id int)
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

CREATE OR REPLACE PROCEDURE buy(sender_id int)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE app_accounts
    SET amount = amount - (
        SELECT COALESCE(sum(total), 0)::decimal
        FROM all_reserved_total
        WHERE all_reserved_total.user_id = sender_id
    )
    WHERE app_accounts.user_id = sender_id;

    CALL delete_without_trigger(sender_id);

    RAISE NOTICE 'Reserved units bought!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE clear(sender_id int)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    DELETE FROM reserved_units WHERE user_id = sender_id;
    RAISE NOTICE 'Reserved units cleared!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE reserve_unit_for_user(
    sender_id int, unit_to_reserve_id int, quantity int
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    INSERT INTO reserved_units (user_id, unit_id, amount)
    VALUES (sender_id, unit_to_reserve_id, quantity);
    CALL refresh_all_reserved_units_with_user_id();
    RAISE NOTICE 'Unit reserved!';
    COMMIT;
    END;
$$;

CREATE OR REPLACE PROCEDURE update_unit_for_user(
    sender_id int, unit_to_reserve_id int, quantity int
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE reserved_units SET amount = quantity
    WHERE user_id = sender_id AND unit_id = unit_to_reserve_id;
    RAISE NOTICE 'Unit reserved!';
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

CREATE OR REPLACE PROCEDURE populate_account_for_user(
    sender_id int, quantity int
)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE app_accounts SET amount = quantity
    WHERE user_id = sender_id;
    RAISE NOTICE 'Account populated!';
    COMMIT;
    END;
$$;


-- VIEWS

CREATE VIEW all_users AS
SELECT users.user_id, users.username, users.email, app_accounts.amount FROM users
NATURAL JOIN app_accounts
ORDER BY users.user_id;

CREATE VIEW all_shops AS
SELECT name FROM shops
ORDER BY shops.shop_id;

CREATE VIEW all_units_with_unit_id AS
SELECT units.unit_id, shops.name AS shop_name, units.name, units.weight, units.price, units.price_for_kg, units.amount FROM units
INNER JOIN shops ON shops.shop_id = units.shop_id
ORDER BY units.unit_id;

CREATE VIEW all_units AS SELECT shop_name, name, weight,
price, price_for_kg, amount
FROM all_units_with_unit_id;

CREATE MATERIALIZED VIEW all_reserved_units_with_user_id AS
SELECT users.user_id, users.username, shops.name AS shop_name, units.name, units.weight, units.price, units.price_for_kg, reserved_units.amount,  (units.price * reserved_units.amount) as total FROM reserved_units
INNER JOIN units ON units.unit_id = reserved_units.unit_id
INNER JOIN users ON users.user_id = reserved_units.user_id
INNER JOIN shops ON shops.shop_id = units.shop_id
ORDER BY reserved_units.reserved_unit_id;

CREATE VIEW all_reserved_units AS
SELECT username, shop_name, name, weight, price, price_for_kg, amount, total
FROM all_reserved_units_with_user_id;

CREATE VIEW all_reserved_total AS
SELECT user_id, (units.price * reserved_units.amount) as total
FROM reserved_units
INNER JOIN units ON units.unit_id = reserved_units.unit_id;


