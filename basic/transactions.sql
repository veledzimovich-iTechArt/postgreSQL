-- basic

-- TRANSACTIONS

-- \set AUTOCOMMIT on (default can't rollback)
-- \set AUTOCOMMIT off

DROP TABLE piggy_bank;
CREATE TABLE piggy_bank (
    id SERIAL NOT NULL PRIMARY KEY,
    coin CHAR(1) NOT NULL,
    coin_year CHAR(4)
);

INSERT INTO piggy_bank (coin, coin_year) VALUES
    ('Q', '1950'),
    ('P', '1972'),
    ('N', '2005'),
    ('Q', '1999'),
    ('Q', '1981'),
    ('D', '1940'),
    ('Q', '1980'),
    ('P', '2001'),
    ('D', '1926'),
    ('Q', '1999');


CREATE VIEW pb_quarters AS
SELECT * FROM piggy_bank WHERE coin = 'Q';

SELECT * FROM pb_quarters;

CREATE VIEW pb_dimes AS
SELECT * FROM piggy_bank WHERE coin = 'D' WITH CHECK OPTION;

-- INSERT 0 1
INSERT INTO pb_quarters VALUES (DEFAULT, 'Q', 1993);

-- INSERT 0 1 (because no CHECK OPTION in pb_quarters)
INSERT INTO pb_quarters VALUES (DEFAULT, 'D', 1942);

-- error because of CHECK OPTION in pb_dimes
INSERT INTO pb_dimes VALUES (DEFAULT, 'Q', 2005);

-- DELETE 0
DELETE FROM pb_quarters WHERE coin = 'N' OR coin = 'P' OR coin = 'D';
-- UPDATE 0
UPDATE pb_quarters SET coin = 'Q' WHERE coin = 'P';

-- error because of CHECK OPTION in pb_dimes
UPDATE pb_dimes SET coin = 'Q' WHERE coin = 'D';


-- BEGIN START TRANSACTION
-- COMMIT END TRANSACTION

START TRANSACTION;
SELECT * FROM piggy_bank;
UPDATE piggy_bank set coin = 'Q' WHERE coin = 'P';
SELECT * FROM piggy_bank;
ROLLBACK;
SELECT * FROM piggy_bank;

START TRANSACTION;
SELECT * FROM piggy_bank;
UPDATE piggy_bank set coin = 'Q' WHERE coin = 'P';
SELECT * FROM piggy_bank;
END TRANSACTION;

SELECT * FROM piggy_bank;

UPDATE piggy_bank set coin = 'P' WHERE id IN (2, 8);

-- SAVEPOINT prevent errors for long transactions
-- partial rollback
BEGIN;
INSERT INTO piggy_bank VALUES(DEFAULT, 'Q', 1994);
SAVEPOINT my_save;
DELETE FROM piggy_bank WHERE id = (SELECT MAX(id) FROM piggy_bank);
ROLLBACK to my_save;
COMMIT;

-- READ ONLY
-- BEGIN READ ONLY;
-- UPDATE piggy_bank set coin = 'D' WHERE id = 1;
-- ERROR:  cannot execute UPDATE in a read-only transaction

SHOW default_transaction_isolation;

-- READ UNCOMMITTED READ COMMITTED REPEATABLE READ SERIALIZABLE
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SHOW default_transaction_isolation;
