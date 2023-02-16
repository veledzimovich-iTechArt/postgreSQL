-- basic

-- DATE

-- DATE YYYY-MM-DD (recomended ISO 8601)
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    user_id SERIAL NOT NULL PRIMARY KEY,
    last_name VARCHAR(30) NOT NULL,
    first_name VARCHAR(20) NOT NULL,
    email VARCHAR(50) NOT NULL,
    birthday DATE
);

INSERT INTO users(last_name, first_name, email, birthday)
VALUES
    ('Ami', 'Who', 'whoami@gmail.com', '1992-01-01'),
    ('Who', 'Ami', 'amiwho@gmail.com', '1991-01-01'),
    ('Richard', E'O\'Keefe', 'keefe@gmail.com', '1960-05-01');


SELECT to_char(birthday, 'DD.MM.YYYY HH24:MI:SS') from users;
SELECT to_char(birthday, 'YYYY-MM-DD HH12:MI a.m. TZ') from users;

-- TIME HH:MM:SS
-- the time alone with a time zone is useless.
-- TIME WITH TIME ZONE ()
-- TIMETZ
-- TIMESTAMP YYYYMMDDHHMMSS
-- TIMESTAMP WITH TIME ZONE timezone
-- timestamptz (default server time)
-- INTERVAL period of time
-- The interval data type is useful for easy-to-understand calculations on date and time data.
--  time_with_tz |   timestamp_with_tz    |   interval
-- --------------+------------------------+---------------
--  00:00:00+02  | 2022-12-13 01:00:00+03 | 1 year 2 mons

-- All four data types can track the system clock and the nuances of the calendar. For example, date and timestamp with time zone recognize that June has 30 days. If you try to use June 31, PostgreSQL will display an error: date/time field value out of range.

SELECT date_part('epoch', '1970-01-01 00:00:01 UTC'::timestamptz) AS epoch;
SELECT extract(year from '1970-01-01 00:00:01 UTC'::timestamptz) AS year;
-- Epoch time also faces the so-called Year 2038 problem, when epoch values will grow too large for some computer systems to store.

SHOW timezone;
SELECT current_setting('timezone');
SELECT make_timestamptz(
    2022, 2, 22, 18, 4, 30.3, current_setting('timezone')
);
SELECT CAST('2022-01-01' AS timestamp);

-- is_dst notes whether the time zone is currently observing daylight saving time
SELECT * FROM pg_timezone_abbrevs ORDER BY abbrev LIMIT 10;
SELECT * FROM pg_timezone_names ORDER BY name LIMIT 10;

-- Filter to find one
SELECT * FROM pg_timezone_names
WHERE name LIKE 'Europe%'
ORDER BY name
LIMIT 10;
-- set the time zone for the current session
SET TIME ZONE 'Europe/Warsaw';

SELECT NOW();

-- TIME()
-- ADDTIME()
-- TIMEDIFF()
-- TIMESTAMPDIFF()
-- YEAR()
-- DAY()
-- MONTH()
-- NOW()
-- DATENAME()


