PostgreSQL

Content

- [basic](#basic)
- [hacks](#hacks)
- [shop](#shop)
- [pgcli](#pgcli)

## basic

[Download](https://postgresapp.com)

```bash
# PATH
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:${PATH}"
```

```json
// PostgreSQL.sublime-build
{
    "env": {"DB": "basic_sql"},
    "shell": true,
    "cmd": [
        "/Applications/Postgres.app/Contents/Versions/latest/bin/psql -U \\${USER} -p 5432 -d \\${DB} -f $file"
    ],
    "selector": "source.sql"
}

```

```bash
# config
~/Library/Application\ Support/Postgres/var-15/postgresql.conf
```

```bash
# upgrade
pg_upgrade -U postgres -b ~/Downloads/Postgres.app/Contents/Versions/latest/bin -B /Applications/Postgres.app/Contents/Versions/15/bin -d '~/Library/Application Support/Postgres/var-15' -D '~/Library/Application Support/Postgres/var-16'
```

[Intro](https://www.postgresqltutorial.com)

```bash
psql postgres
>> psql (15.2)
>> Type "help" for help.
\q
```
Create/Delete
``` bash
psql
CREATE DATABASE basic;
ALTER DATABASE basic RENAME TO basic_sql;
\c basic_sql
\c postgres;
DROP DATABASE basic_sql;
```
Help
```bash
# commands
\?
# help
\h CREATE TABLE
```
Commands
```bash
# databases
\l
# relations
\d
\d+ [table]
# views
\dv
# tables
\dt
# functions
\df
# triggers
\dS
# users
\du
\du+
# execute from file
\i [filename]
# command history
\s
#output
\a default
\H html
# time of the command
\timing
# re-execution of commands.
\watch 5
```
Settings
```bash
psql
SHOW ALL;
\set AUTOCOMMIT off
\echo :AUTOCOMMIT
# set null for NULL
\pset null '[null]'
# default
\pset null ''
```

```sql
-- always use indexes instead of seqscan
SET enable_seqscan = off;
-- Logs
-- use LOG
SET client_min_messages = LOG;
-- SET log_duration = on;
-- additional statistics
-- SET log_statement_stats = on;
-- or
SET log_duration = off;
SET log_statement = none;
-- greate than 10 ms
SET log_min_duration_statement = 1;
```
Statistics
```sql
SELECT VERSION();

DROP TABLE IF EXISTS temp_table;
CREATE TABLE temp_table (
    id SERIAL NOT NULL PRIMARY KEY
);

INSERT INTO temp_table VALUES (DEFAULT), (DEFAULT), (DEFAULT);

-- size
SELECT pg_database_size(current_database()),
    pg_database_size('basic_sql'),
    pg_relation_size('temp_table');
SELECT pg_size_pretty(pg_database_size(current_database()));

-- user info about connections
SELECT datid, datname, usename, state FROM pg_stat_activity;

SELECT CURRENT_USER, CURRENT_DATE, CURRENT_TIME;

```

Run basic examples

```bash
dropdb basic_sql
createdb -U postgres basic_sql
psql -U postgres -p 5432 -d basic_sql -f basic/types.sql
psql -U postgres -p 5432 -d basic_sql -f basic/numeric.sql
psql -U postgres -p 5432 -d basic_sql -f basic/date_time.sql
psql -U postgres -p 5432 -d basic_sql -f basic/string.sql
```

Dump/Load

```bash
pg_dump --host 127.0.0.1 --port 5432 --user postgres basic_sql > basic_sql.sql
psql -h 127.0.0.1 -d basic_sql -U postgres -f basic_sql.sql
 # copy to docker
docker cp basic_sql.sql [container ID]:/basic_sql.sql
docker exec -it [container ID] psql -h 127.0.0.1 -d basic_sql -U postgres -f basic_sql.sql
```

Export

```bash
psql
\c basic_sql
COPY users TO '/Users/aliaksandr/Documents/DB/sql/postgres/basic_sql_users.csv' WITH (FORMAT CSV, HEADER);
```

## hacks

```bash
psql -U postgres -p 5432 -d shop_sql -f hacks.sql
```

## shop

Run commands to create DB and run examples one by one

```bash
dropdb shop_sql
createdb -U postgres shop_sql
# setup
psql -U postgres -p 5432 -d shop_sql -f shop/shop_init.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_roles.sql
psql -U postgres -p 5432 -d shop_sql -f shop/shop_populate.sql
# execute
psql -U shop_admin -p 5432 -d shop_sql -f shop/shop_admin.sql
psql -U whoami -p 5432 -d shop_sql -f shop/shop_customer.sql
```
Run commands to check performance without and with indexes
```bash
./shop/indexes.sh
```

## pgcli

- autocompletion
- SSH tunnels for you if you cannot access the database directly.

```bash
# install
pip install pgcli
# The config file for pgcli ~/.config/pgcli/config
```

```bash
# uninstall
pip3 uninstall wcwidth typing-extensions tabulate sqlparse six setproctitle pytzdata Pygments prompt-toolkit click python-dateutil psycopg configobj pgspecial pendulum cli-helpers pgcli
```
