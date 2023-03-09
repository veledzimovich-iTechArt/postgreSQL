-- basic

-- USERS ROLES GROUPS POLICY

-- Users, groups, and roles are the same thing in PostgreSQL, with the only difference being that users have permission to log in by default
-- check ~/Library/Application\ Support/Postgres/var-15/pg_hba.conf

-- set METHOD password
-- sudo -u postgres createuser --interactive

DROP POLICY IF EXISTS own_contact ON my_contacts;
DROP POLICY IF EXISTS own_delete_contact ON my_contacts;
DROP POLICY IF EXISTS own_update_contact ON my_contacts;

CREATE USER super SUPERUSER;
-- same
-- CREATE ROLE super LOGIN SUPERUSER;
DROP USER super;

DROP USER IF EXISTS root;
CREATE USER root;
-- same
-- CREATE ROLE root WITH LOGIN;

DROP USER IF EXISTS root;
CREATE USER root WITH PASSWORD 'root' CREATEROLE CREATEDB;
-- INHERIT(default) NOINHERIT
-- REPLICATION NOREPLICATION(default)

-- SELECT, UPDATE, INSERT, DELETE
GRANT ALL ON locations TO root;
-- for all table in DB basic_sql
GRANT ALL ON ALL TABLES IN SCHEMA public TO root;

ALTER USER postgres PASSWORD 'postgres';
ALTER USER aliaksandr PASSWORD 'aliaksandr';

REVOKE ALL ON my_contacts FROM director;
DROP ROLE IF EXISTS director;
CREATE ROLE director WITH PASSWORD 'director' LOGIN;
-- \c basic_sql director
-- You are now connected to database "basic_sql" as user "director".
SET ROLE director;
SELECT * FROM my_contacts;
-- ERROR:  permission denied for table my_contacts
SET ROLE postgres;
GRANT SELECT ON my_contacts TO director;
SET ROLE director;
SELECT * FROM my_contacts;
SET ROLE postgres;

GRANT SELECT(salary) ON job_current TO director;
SET ROLE director;
SELECT * FROM job_current;
SELECT salary FROM job_current;
SET ROLE postgres;

SET ROLE root;
GRANT INSERT, UPDATE, DELETE ON my_contacts TO director;
SET ROLE postgres;
GRANT SELECT, INSERT, UPDATE, DELETE ON my_contacts TO root
WITH GRANT OPTION;
SET ROLE root;
GRANT INSERT, UPDATE, DELETE ON my_contacts TO director;
SET ROLE postgres;

-- REVOKE
REVOKE SELECT(salary) ON job_current FROM director;

-- CASCADE remove root and all granted by root
REVOKE GRANT OPTION FOR SELECT, UPDATE, DELETE ON my_contacts
FROM root CASCADE;

-- check that director couldn't update
SET ROLE director;
SELECT * FROM my_contacts;
UPDATE my_contacts SET gender = 'F';
SET ROLE postgres;

-- RESTRICT
REVOKE GRANT OPTION FOR INSERT ON my_contacts FROM root RESTRICT;
DROP TRIGGER IF EXISTS boss_id_updated ON my_contacts;
-- check that director could INSERT
SET ROLE director;
INSERT INTO my_contacts VALUES(
    DEFAULT, 'V', 'Alex', '1983-07-19', 'v@mail.com', '123-9090', 'M', 2, 1, 1, 1
);

SET ROLE postgres;
REVOKE GRANT OPTION FOR INSERT ON my_contacts FROM root CASCADE;
-- check that director couldn't INSERT
SET ROLE director;
INSERT INTO my_contacts VALUES(
    DEFAULT, 'V', 'Alex', '1983-07-19', 'v@mail.com', '123-9090', 'M', 2, 1, 1, 1
);
SET ROLE postgres;

-- check that director still have SELECT granted by postgres
SET ROLE director;
SELECT * FROM my_contacts;
SET ROLE postgres;

-- revoke all for root
REVOKE ALL ON locations
FROM root;
REVOKE ALL ON ALL TABLES IN SCHEMA public
FROM root;
-- GRANT VIEW
GRANT SELECT ON available_python_developers TO root;

-- GRANT ROLE
GRANT root TO director WITH ADMIN OPTION;
REVOKE root FROM director;

DROP USER root;
-- ERROR: role "root" cannot be dropped because some objects depend on it
REVOKE SELECT ON available_python_developers FROM root;
DROP USER root;

CREATE USER hr_manager WITH PASSWORD 'hr_manager';
GRANT SELECT ON my_contacts TO hr_manager;
GRANT SELECT, DELETE ON job_desired, job_listings TO hr_manager;
REVOKE SELECT ON my_contacts FROM hr_manager;
REVOKE SELECT, DELETE ON job_desired, job_listings FROM hr_manager;

DROP USER hr_manager;

CREATE USER analytic WITH PASSWORD 'analytic';
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO analytic;
REVOKE SELECT, INSERT ON ALL TABLES IN SCHEMA public FROM analytic;

DROP USER analytic;

CREATE USER pr_agent WITH PASSWORD 'pr_agent';
GRANT SELECT ON my_contacts, professions, locations, states, countries, cities, statuses, contact_interest, interests, contact_seeking, seekings TO pr_agent;
REVOKE SELECT ON my_contacts, professions, locations, states, countries, cities, statuses, contact_interest, interests, contact_seeking, seekings FROM pr_agent;

DROP USER pr_agent;


-- POLICY

ALTER TABLE my_contacts ENABLE ROW LEVEL SECURITY;
CREATE POLICY own_contact ON my_contacts
-- USING statements are used to check existing table rows
    -- SELECT
    FOR SELECT
    USING (True);

CREATE POLICY own_delete_contact ON my_contacts
-- USING statements are used to check existing table rows
    -- DELETE
    FOR DELETE
    USING (current_user = last_name);

CREATE POLICY own_update_contact ON my_contacts
-- INSERT, UPDATE
-- WITH CHECK statements are used to check new rows
    WITH CHECK(
        current_user = last_name
    );

SELECT * FROM my_contacts;
