-- shop

-- RUN SELECTS

-- always use indexes instead of seqscan
-- SET enable_seqscan = off;

SET client_min_messages = LOG;
-- SET log_duration = on;
-- additional statistics
-- SET log_statement_stats = on;
-- or
SET log_duration = off;
SET log_statement = none;
-- greate than 10 ms
SET log_min_duration_statement = 1;

CALL reserve_units_in_a_loop(100);
CALL update_unit_for_user(1,1,1);
CALL delete_unit_for_user(1,1);


-- faster because of index
EXPLAIN ANALYZE
SELECT count(*) FROM units WHERE name = '5807071383a91fb25df5c723-8';

EXPLAIN ANALYZE
SELECT count(*) FROM units WHERE name ILIKE '%c5-3%';

SELECT count(*) FROM units WHERE price > 1;
SELECT count(*) FROM units WHERE price > 1 AND weight > 0.2;
-- faster
SELECT count(*) FROM units WHERE amount > 7;

SELECT count(*) FROM all_units WHERE shop_name = 'Lidl';

-- faster because of foreign keys idx
EXPLAIN ANALYZE
SELECT count(*) FROM reserved_units
INNER JOIN units ON units.unit_id = reserved_units.unit_id
INNER JOIN users ON users.user_id = reserved_units.user_id
INNER JOIN shops ON shops.shop_id = units.shop_id
WHERE shops.name = 'Carefour' AND users.username = 'manager';

-- faster because of materilized view
EXPLAIN ANALYZE
SELECT count(*) FROM all_reserved_units
WHERE shop_name = 'Carefour' AND username = 'manager';

-- faster after using indexes
CALL clear(1);
CALL reserve_units_in_a_loop(10);

SELECT count(*) FROM all_reserved_units;
CALL buy(1);
SELECT count(*) FROM all_reserved_units;
