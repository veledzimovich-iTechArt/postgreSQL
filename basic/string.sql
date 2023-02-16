-- basic

-- STRING

-- Same performance
-- CHAR(n) (add space padding)
-- VARCHAR(n) remove space padding
-- TEXT (preferable)

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

-- len
SELECT LENGTH(' sql-academy ⌘ 東');
SELECT CHAR_LENGTH(' sql-academy ⌘ 東');

-- position
SELECT POSITION('l' IN 'Hello world'), POSITION('l' IN 'Hello world');

-- case
SELECT LOWER('Hello world');
SELECT UPPER('Hello world');
SELECT INITCAP('at the end of the day');

-- concat
SELECT CONCAT('sql', '-', 'academy');
SELECT 'sql' ||  '-' || 'academy';
SELECT CONCAT('sql', NULL);

-- modify
SELECT LEFT('sql-academy', 3), RIGHT('sql-academy', 7);
SELECT LPAD('9', 2, '0'), RPAD('Hello', 10, '!');

SELECT TRIM('s' FROM 'socks');
SELECT TRIM(trailing 's' FROM 'socks');
SELECT LENGTH((SELECT TRIM('   Hello  ')));
SELECT LENGTH((SELECT LTRIM('   Hello  ')));
SELECT LENGTH((SELECT RTRIM('   Hello  ')));

SELECT REPEAT('101', 3);

SELECT SUBSTRING('sql-academy', 5, 4);
SELECT SUBSTRING('Who Ami', 1, POSITION(' ' IN 'Who Ami'));

SELECT FORMAT('Hello, %s', 'Geeks!!');
SELECT FORMAT(
    '%s, %s %s', 'Greatings', (SELECT LEFT('from me', 4)), 'Geeks!!'
);

SELECT REPLACE('Dear Tom Atkins', 'Tom', 'Mr. Tom');
SELECT REPLACE('Bat', 'B', 'C');

SELECT REVERSE('postgres');

-- regexp
SELECT SUBSTRING(
    '7 p.m. on May 2, 2024.' FROM '\d{4}'
);
SELECT SUBSTRING(
    '7 p.m. on May 2, 2024.' FROM '\w+.$'
);
SELECT SUBSTRING(
    '7 p.m. on May 2, 2024.' FROM 'May|June'
);
-- don’t treat the terms inside the parentheses as a capture group
SELECT SUBSTRING(
    '7 p.m. on May 2, 2024.' FROM '\d{1,2} (a.m.|p.m.)'
);
SELECT SUBSTRING(
    '7 p.m. on May 2, 2024.' FROM '\d{1,2} (?:a.m.|p.m.)'
);
-- Returns each match as text in an array.
-- If there are no matches, it returns NULL
SELECT REGEXP_MATCH('7 p.m. on May 2, 2024.', '.+');

SELECT REGEXP_MATCH('7 p.m. on May 2, 2024.', '\d+');
SELECT REGEXP_MATCHES('7 p.m. on May 2, 2024.', '\d+', 'g');
SELECT REGEXP_MATCHES('7 p.m. on May 2, 2024.', '\s\d+', 'g');
SELECT REGEXP_MATCHES('7 p.m. on May 2, 2024.', '\s(\d+)', 'g');

SELECT last_name FROM users
-- case-sensitive match
WHERE first_name ~ ('who|ami');

SELECT last_name FROM users
-- case-insensitive match
WHERE first_name ~* ('who|ami') AND last_name !~* 'ami';

SELECT REGEXP_REPLACE('05/12/2024', '\d{4}', '2023');

SELECT REGEXP_SPLIT_TO_TABLE('1,2,3,4', ',');

SELECT REGEXP_SPLIT_TO_ARRAY('Who Ami', ' ');

-- The array that regexp_split_to_array() produces is one-dimensional; that is, the result contains one list of names. Here we pass 1 as a second argument 1 to array_length(), indicating we want the length of the first (and only) dimension of the array.
SELECT ARRAY_LENGTH(REGEXP_SPLIT_TO_ARRAY('Atkins Whoami', ' '), 1);
