-- shop

-- add data
-- check performance with indexes for app_accounts
-- add roles

-- DOMAINS

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
    REFRESH MATERIALIZED VIEW all_reserved_units_with_user_id;
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
    REFRESH MATERIALIZED VIEW all_reserved_units_with_user_id;
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
    REFRESH MATERIALIZED VIEW all_reserved_units_with_user_id;
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
    FROM all_reserved_units_with_user_id
    WHERE all_reserved_units_with_user_id.user_id = sender_id;

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

CREATE OR REPLACE PROCEDURE buy(sender_id int)
LANGUAGE PLPGSQL
AS
$$
    BEGIN
    UPDATE app_accounts
    SET amount = amount - (
        SELECT COALESCE(sum(total), 0)::decimal
        FROM all_reserved_units_with_user_id
        WHERE all_reserved_units_with_user_id.user_id = sender_id
    )
    WHERE app_accounts.user_id = sender_id;

    ALTER TABLE reserved_units
    DISABLE TRIGGER unit_amount_updated_after_reserved_unit_has_been_deleted;

    DELETE FROM reserved_units WHERE user_id = sender_id;
    REFRESH MATERIALIZED VIEW all_reserved_units_with_user_id;

    ALTER TABLE reserved_units
    ENABLE TRIGGER unit_amount_updated_after_reserved_unit_has_been_deleted;
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
    RAISE NOTICE 'Unit reserved!';
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


-- POPULATE

INSERT INTO users(username, email)
VALUES
    ('admin', 'admin@mail.com'),
    ('atkins', 'atkins@mail.com'),
    ('whoami', 'whoami@mail.com');

INSERT INTO shops(name)
VALUES ('Lidl'), ('Carefour'), ('Zabka');

INSERT INTO units (shop_id, name, weight, amount, price)
VALUES
    (1, 'Rice', 1.0, 2, 1.5),
    (1, 'Beef', 1.0, 2, 3),
    (2, 'Eggs', 0.7, 3, 2.5),
    (3, 'Tea', 0.1, 1, 4);


-- EXAMPLE

-- ALTER SEQUENCE reserved_units_reserved_unit_id_seq RESTART WITH 1;

CALL populate_account_for_user(1, 10);
CALL populate_account_for_user(2, 10);
CALL populate_account_for_user(3, 10);

CALL reserve_unit_for_user(1,1,2);
CALL reserve_unit_for_user(1,2,1);
CALL reserve_unit_for_user(2,3,1);
CALL reserve_unit_for_user(3,4,1);

-- clear for user with id 2
CALL clear(2);
-- buy for user with id 3
CALL buy(3);

TABLE all_shops;
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
    ASSERT tea_amount = 0, 'Wrong tea amount';

    ASSERT total_reserved_amount = 2, 'Wrong reserved amount';

    ASSERT admin_to_pay_amount = 6.00, 'Wrong admin to pay amount';
    ASSERT atkins_to_pay_amount = 0.00, 'Wrong atkins to pay amount';
    ASSERT whoami_to_pay_amount = 0.00, 'Wrong whoami to pay amount';

    ASSERT admin_account_amount = 10.00, 'Wrong admin account amount';
    ASSERT atkins_account_amount = 10.00, 'Wrong atkins account amount';
    ASSERT whoami_account_amount = 6.00, 'Wrong whoami account amount';

END
$$;


