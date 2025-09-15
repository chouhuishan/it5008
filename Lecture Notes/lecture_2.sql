-- L2: SiMPLE QUERIES
-- Give table with columns of first_name, and last_name
SELECT first_name,
    last_name
FROM app_store.customers
WHERE country = 'Singapore';
-- Get all the columns as per Schema --
SELECT first_name,
    last_name,
    email,
    dob,
    since,
    customerid,
    country
FROM app_store.customers;
-- SHORTCUT: Same as above-- 
Select *
FROM app_store.customers;
-- Gives the columns of the name of the games, and the respective versions
SELECT name,
    version
FROM app_store.downloads;
-- Same as above, but the name and version in alphabetical and ascending order 
SELECT name,
    version
FROM app_store.downloads
ORDER BY name,
    version;
-- Varies slightly different, as the names will be in alphabetical order, but version will not be arranged chronologically
SELECT name,
    version
FROM app_store.downloads
ORDER BY name;
-- Price will be arranged in ascending order
SELECT name,
    version
FROM app_store.games
ORDER BY price ASC;
-- DISTINCT is used to print distinct (unique) rows
SELECT DISTINCT name,
    version
FROM app_store.downloads;
-- Sort distinct names in ascending order
SELECT DISTINCT name
FROM app_store.games
ORDER BY name ASC;
-- SELECT FAIL : ORDER BY expression (price) need to appear in SELECT list
SELECT DISTINCT name,
    version
FROM app_store.games
ORDER BY price ASC;
-- WHERE :  Filter rows on Boolean conditions (AND/OR/NOT/IN/BETWEEN..AND/Comparison operators; > < >= <=)
SELECT first_name,
    last_name
FROM app_store.customers
WHERE country IN ('Singapore', 'Indonesia')
    AND (
        dob BETWEEN '2000-01-01' AND '2000-12-01'
        OR since >= '2016-12-01'
    )
    AND last_name LIKE 'B%';
-- Filter out customers from SG/INDO, borned between aboved dates, with last names who start with B
-- Shows the column of all the prices of each game (even showing duplicates), in ascending order
SELECT price
FROM app_store.games
ORDER BY price ASC;
-- Filter out unique prices (remove duplicates), in ascending order
SELECT DISTINCT price
FROM app_store.games
ORDER BY price ASC;
-- Unique prices * 1.09 renamed as gst, in ascending order
SELECT DISTINCT price * 1.09 AS gst
FROM app_store.games
ORDER BY gst ASC;
-- Operator || is a concatenation operator; concat name and version together into one column renamed as game
SELECT name || ' ' || version AS game,
    ROUND(price * 1.09, 2) AS price
FROM app_store.games
WHERE price * 0.09 >= 0.3;
-- Price is not renamed as gst, (price * 1.09) is not carried out
SELECT name || ' ' || version AS game,
    price
FROM app_store.games
WHERE price * 0.09 >= 0.3;
-- CASE-WHEN-THEN-ELSE == if-else
-- Concat name and version together W/O column name
-- Filter price that meets the constraint below, and round to 2.dp after adding gst
SELECT name || ' ' || version,
    CASE
        WHEN price * 0.09 >= 0.3 THEN ROUND(price * 1.09, 2)
        ELSE price
    END AS price
FROM app_store.games;
-- Filter name of games that are version 1.0 or 1.1
SELECT name
FROM app_store.games
WHERE (
        version = '1.0'
        OR version = '1.1'
    );
-- Same as above
SELECT name
FROM app_store.games
WHERE version IN ('1.0', '1.1');
-- <> operator : NOT EQUAL TO -> results are same as above
SELECT name
FROM app_store.games
WHERE NOT (
        version <> '1.0'
        AND version <> '1.1'
    );
--
SELECT *
FROM app_store.customers,
    app_store.downloads,
    app_store.games;
-- CROSS JOIN : Combines all the columns and possible combination of the rows of the three tables
SELECT *
FROM app_store.customers
    CROSS JOIN app_store.downloads
    CROSS JOIN app_store.games;
-- Meaningful joins : Print customers who downloaded a game
SELECT *
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE d.customerid = c.customerid
    AND d.name = g.name
    AND d.version = g.version;
-- Print all customers who downloaded any version of Fixflex
SELECT c.email,
    g.version
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE d.customerid = c.customerid
    AND d.name = g.name
    AND d.version = g.version
    AND c.country = 'Indonesia'
    AND g.name = 'Fixflex';