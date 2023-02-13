-- shop

-- POPULATE

-- ALTER SEQUENCE reserved_units_reserved_unit_id_seq RESTART WITH 1;

CALL create_admin_user('manager', 'manager@mail.com');
CALL create_customer_user('atkins', 'atkins@mail.com');
CALL create_customer_user('whoami', 'whoami@mail.com');


INSERT INTO shops(name)
VALUES ('Lidl'), ('Carefour'), ('Zabka');

INSERT INTO units (shop_id, name, weight, amount, price)
VALUES
    (1, 'Rice', 1.0, 2, 1.5),
    (1, 'Beef', 1.0, 2, 3),
    (2, 'Eggs', 0.7, 3, 2.5),
    (3, 'Tea', 0.1, 3, 4);

CALL populate_account_for_user(1, 10);
CALL populate_account_for_user(2, 10);
CALL populate_account_for_user(3, 10);
