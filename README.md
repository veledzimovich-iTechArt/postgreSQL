## PostgreSQL

# Content

[basic](#basic)

- [run basic examples](#run-basic-examples)

- [statistic](#statistic)

- [config](#config)

- [dump load](#dump-load)

- [export import](#export-import)

[hacks](#hacks)

[shop](#shop)

[pgcli](#pgcli)

## basic

[Download Postgres](https://postgresapp.com)

```bash
# PATH
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:${PATH}"
```

```yaml
# PostgreSQL.sublime-build
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
# upgrade
pg_upgrade -U postgres -b ~/Downloads/Postgres.app/Contents/Versions/latest/bin -B /Applications/Postgres.app/Contents/Versions/15/bin -d '~/Library/Application Support/Postgres/var-15' -D '~/Library/Application Support/Postgres/var-16'
```

[Intro](https://www.postgresqltutorial.com)

create/delete
``` bash
psql
CREATE DATABASE basic;
ALTER DATABASE basic RENAME TO basic_sql;
\c basic_sql
\c postgres;
DROP DATABASE basic_sql;
\q
```
connect
```bash
createdb -U postgres -e basic_sql
psql -d basic_sql -U postgres -h localhost
# # hash mark indicates that you’re superuser
```
set .pgpass
```bash
# change local METHOD in pg_hba.conf from trust to password
psql
\password postges
\q
#set .pgpass
touch ~/.pgpass
echo -e 'localhost:5432:basic_sql:postgres:postgres' > ~/.pgpass
chmod 600 ~/.pgpass
```
help
```bash
# commands
\?
# options -U -d -h
\? options
# VERSION AUTOCOMMIT
\? variables
# help
\h CREATE TABLE
```
commands
```bash
# databases
\l
# relations
\d
\d+ [table]
# tables
\dt
# size
\dt+ [table]
# views
\dv
# functions
\df
# triggers
\dS
# users
\du
\du+
# vim
\e
# execute from file
\i [filename]
# command history
\s
# time of the command
\timing
# re-execution of commands.
\watch 5
```
settings
```bash
psql
SHOW ALL;
\set AUTOCOMMIT off
\echo :AUTOCOMMIT
# set null for NULL
\pset null '[null]'
# default for NULL
\pset null ''
# on/off pager
\pset pager
# border
\pset border 2
# format
\pset format csv
# file output
\o 'basic/output.csv'
# aligned/unaligned
\a
# html output
\H
# expanded auto
\x auto
```
logs
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
extension
```bash
# auto add for every new DB
psql -d template1
CREATE EXTENSION citext;
# check extensions
\dx
\q
```

### run basic examples
```bash
dropdb basic_sql
createdb -U postgres basic_sql
psql -U postgres -p 5432 -d basic_sql -f basic/types.sql
psql -U postgres -p 5432 -d basic_sql -f basic/numeric.sql
psql -U postgres -p 5432 -d basic_sql -f basic/date_time.sql
psql -U postgres -p 5432 -d basic_sql -f basic/string.sql
```

### statistic
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

### config
```bash
psql
SHOW config_file;
# autovacuum
# datestyle = 'iso, mdy'
# timezone = 'Europe/Warsaw'
# default_text_search_config
SHOW data_directory;
\q
# reload settings path to data_directory
pg_ctl reload -D [data_directory]
psql
SELECT NOW();
\q
pg_ctl restart -D [data_directory]
psql
SELECT NOW();
```

### dump load
```bash
pg_dump --host 127.0.0.1 --port 5432 --user postgres basic_sql > basic_sql.dump
#  -v verbose -Fc comressed format
pg_dump -Fc -v --host 127.0.0.1 --port 5432 --user postgres -d basic_sql -f basic_sql.dump
# -t table
pg_dump -Fc -v --host 127.0.0.1 --port 5432 --user postgres -d basic_sql -t 'users' -f basic_sql_users.dump
# restore
# get DB name from basic_sql.dump
dropdb basic_sql
pg_restore -C -v -d postgres -U postgres basic_sql.dump
psql -h 127.0.0.1 -d basic_sql -U postgres -f basic_sql.dump
 # copy to docker with your container_ID
docker cp basic_sql.sql [container ID]:/basic_sql.dump
docker exec -it [container_ID] psql -h 127.0.0.1 -d basic_sql -U postgres -f basic_sql.dump
# back up multiple databases
pg_basebackup --help
```

### export import
```bash
# export
psql -d basic_sql -U postgres
\copy users TO '/Users/aliaksandr/Documents/DB/sql/postgres/basic/basic_sql_users.csv' WITH (FORMAT CSV, HEADER);
DELETE FROM users;
# import with STDIN
psql -d basic_sql -U postgres -c 'COPY users FROM STDIN WITH (FORMAT CSV, HEADER);' < '/Users/aliaksandr/Documents/DB/sql/postgres/basic/basic_sql_users.csv'
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
