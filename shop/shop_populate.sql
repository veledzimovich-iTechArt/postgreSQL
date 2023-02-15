-- shop

-- POPULATE

-- ALTER SEQUENCE reserved_units_reserved_unit_id_seq RESTART WITH 1;

CALL create_admin_user('manager', 'manager@mail.com');
CALL create_customer_user('atkins', 'atkins@mail.com');
CALL create_customer_user('whoami', 'whoami@mail.com');

CALL update_account_amount_for_user(1, 10);
CALL update_account_amount_for_user(2, 10);
CALL update_account_amount_for_user(3, 10);

INSERT INTO shops(name)
VALUES ('Lidl'), ('Carefour'), ('Zabka');

INSERT INTO units (shop_id, name, weight, amount, price)
VALUES
    (1, 'Rice', 1.0, 2, 1.5),
    (1, 'Beef', 1.0, 2, 3),
    (2, 'Eggs', 0.7, 3, 2.5),
    (3, 'Tea', 0.1, 3, 4);


WITH units_stat(average, median) AS (
    SELECT
        avg(price),
        percentile_cont(.5) WITHIN GROUP (ORDER BY price)
    FROM units
)

SELECT
    name,
    price,
    st.average,
    price - st.average AS avg_diff,
    st.median,
    price - st.median AS median_diff
FROM units,
    LATERAL (SELECT average, median FROM units_stat) AS st
WHERE (price - st.median) BETWEEN -1 AND 1;


SELECT * FROM crosstab (
'SELECT shops.name, units.name, sum(units.amount) FROM units
INNER JOIN shops ON units.shop_id = shops.shop_id
GROUP BY shops.name, units.name
ORDER BY shops.name',
'SELECT name FROM units
GROUP BY name
ORDER BY name'
) AS (
    shop text,
    rice bigint,
    beef bigint,
    tea bigint,
    eggs bigint
);
