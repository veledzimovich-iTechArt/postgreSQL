-- shop

-- INDEXES

CREATE EXTENSION pg_trgm;
-- default BTREE for =
CREATE INDEX CONCURRENTLY units_name_idx ON units(name);
-- use GIN for patern matching with gin_trgm_ops for ILIKE
CREATE INDEX CONCURRENTLY units_name_ilike_idx ON units
USING GIN(name gin_trgm_ops);

CREATE INDEX CONCURRENTLY units_weight_idx ON units(weight);
-- hash for equality
CREATE INDEX CONCURRENTLY units_price_hash_idx ON units USING HASH(price);
CREATE INDEX CONCURRENTLY units_amount_idx ON units(amount);

CREATE INDEX CONCURRENTLY shops_name_idx ON shops(name);
CREATE INDEX CONCURRENTLY users_username_idx ON users(username);

-- foreign keys
CREATE INDEX shop_idx ON units(shop_id);

-- created by default because of UNIQUE
-- CREATE UNIQUE INDEX user_unit_idx ON reserved_units (user_id, unit_id);

-- brin smaller
-- nice for timestamps
CREATE INDEX units_brin_idx ON units USING brin(created_at);

SELECT pg_size_pretty(pg_relation_size('units_brin_idx'));
--  pg_size_pretty
-- ----------------
--  24 kB
-- (1 row)
