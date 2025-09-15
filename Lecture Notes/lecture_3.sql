-- L3 : AGGREGATE QUERIES
-- Count number of customers
SELECT COUNT(*)
FROM app_store.customers c;
-- Count number of customersid
SELECT COUNT(c.customerid)
FROM app_store.customers c;
-- Count number of customersid; ALL is the default and is often omitted
SELECT COUNT(ALL c.customerid)
FROM app_store.customers c;
-- Count number of unique countries in the column country of the table of customers
SELECT COUNT(DISTINCT c.country)
FROM app_store.customers c;
-- Find out MAX, MIN, AVG, SD prices of the games (ONLY works on numerical data)
-- TRUNC() : Display 2 dp 
-- TRUNC VS ROUND : TRUNC(5.678, 2) = 5.60, ROUND(5.678, 2) = 5.68
SELECT MAX(g.price),
    MIN(g.price),
    TRUNC(AVG(g.price), 2) AS avg,
    TRUNC(STDDEV(g.price), 2) AS std
FROM app_store.games g;
-- WHERE : Remove unwanted rows
-- Finds MAX, MIN and AVG price for 'Aerified'
SELECT MAX(g.price),
    MIN(g.price),
    TRUNC(AVG(g.price), 2)
FROM app_store.games g
WHERE name = 'Aerified';
-- GROUP BY : Creates logical groups that have the same specified fields
-- Filter out number of customers from each country
SELECT c.country,
    COUNT(*)
FROM app_store.customers c
GROUP BY c.country;
-- ERROR : column 'c.country' need to appear in GROUP BY clause
SELECT c.country,
    COUNT(*)
FROM app_store.customers c;
-- WHERE : Groups are formed logically after the rows are filtered out by the WHERE clause
-- Filter out customers in different countries with dob after constraints stated
SELECT c.country,
    COUNT(*)
FROM app_store.customers c
WHERE c.dob >= '2006-01-01'
GROUP BY c.country;
-- FROM : Groups are formed logically after the tables have been joined in the FROM clause
-- Find out the total price spent by each customer 
SELECT c.customerid,
    c.first_name,
    c.last_name,
    SUM(g.price)
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE c.customerid = d.customerid
    AND d.name = g.name
    and d.version = g.version
GROUP BY c.customerid,
    c.first_name,
    c.last_name;
-- NOTE : This is bad practice - Query works because first_name and last_name are unique
SELECT c.customerid,
    c.first_name,
    c.last_name,
    SUM(g.price)
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE c.customerid = d.customerid
    AND d.name = g.name
    and d.version = g.version
GROUP BY c.customerid;
-- ERROR: If there are two customers with the same first and last name, which customerid is selected?
-- c.customerid needs to appear in GROUP BY clause
SELECT c.customerid,
    c.first_name,
    c.last_name,
    SUM(g.price)
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE c.customerid = d.customerid
    AND d.name = g.name
    and d.version = g.version
GROUP BY c.first_name,
    c.last_name;
-- Print number of downloads by country and year of birth
SELECT c.country,
    EXTRACT(
        YEAR
        FROM c.since
    ) AS regyear,
    COUNT(*) AS total
FROM app_store.customers c,
    app_store.downloads d
WHERE c.customerid = d.customerid
GROUP BY c.country,
    regyear
ORDER BY regyear ASC,
    c.country ASC;
-- Same as above
SELECT c.country,
    EXTRACT(
        YEAR
        FROM c.since
    ) AS regyear,
    COUNT(*) AS total
FROM app_store.customers c,
    app_store.downloads d
WHERE c.customerid = d.customerid
GROUP BY regyear,
    c.country
ORDER BY regyear ASC,
    c.country ASC;
-- ERROR: WHERE does not allow aggregate functions like GROUPBY
SELECT c.country
FROM app_store.customers c
WHERE COUNT(*) >= 100
GROUP BY c.country;
-- Cannot have WHERE W GROUP BY - SOLUTION : GROUP BY & HAVING
-- Find the number of countries with more than 1000 customers
SELECT c.country
FROM app_store.customers c
GROUP BY c.country
HAVING COUNT(*) >= 100;
-- INNER JOIN : Combine rows from two or more tables based on a related column between them. 
-- It returns only the rows where there is a match in the specified join condition in both tables.
SELECT *
FROM app_store.customers c
    INNER JOIN app_store.downloads d ON d.customerid = c.customerid
    INNER JOIN app_store.games g ON d.name = g.name
    AND d.version = g.version;
-- Returns the same table as above, but without the use of the construct INNER JOIN
SELECT *
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE d.customerid = c.customerid
    AND d.name = g.name
    AND d.version = g.version;
-- Returns the same table as above, but with the use of the construct JOIN
SELECT *
FROM app_store.customers c
    JOIN app_store.downloads d ON d.customerid = c.customerid
    JOIN app_store.games g ON d.name = g.name
    AND d.version = g.version;
-- Returns the same table as above, using CROSS JOIN
SELECT *
FROM app_store.customers c,
    app_store.downloads d,
    app_store.games g
WHERE d.customerid = c.customerid
    AND d.name = g.name
    AND d.version = g.version;
-- JOIN: Condition of order matters
-- ERROR : For correct one, see above with the notes - Returns the same table as above, but with the use of the construct JOIN
SELECT *
FROM app_store.customers c
    JOIN app_store.downloads d ON d.name = g.name
    AND d.version = g.version;
JOIN app_store.games g ON d.customerid = c.customerid -- NATURAL JOIN : Join rows with the same values across columns with the same name
SELECT *
FROM app_store.customers c
    NATURAL JOIN app_store.downloads d
    NATURAL JOIN app_store.games g;
--
SELECT *
FROM app_store.customers c,
    app_store.downloads d
WHERE c.customerid <> d.customerid;
-- Customers who did not download the games are padded with NULL
SELECT c.customerid,
    c.email,
    d.customerid,
    d.name,
    d.version
FROM app_store.customers c
    LEFT OUTER JOIN app_store.downloads d ON c.customerid = d.customerid;
-- Games that are not downloaded are combined with NULL values to replace the missing values for the columns of the downloads table
SELECT *
FROM app_store.downloads d
    RIGHT OUTER JOIN app_store.games g ON g.name = d.name
    AND g.version = d.version;
-- CONDITIONS : AND
SELECT *
FROM app_store.downloads d
    RIGHT OUTER JOIN app_store.games g ON g.name = d.name
    AND g.version = d.version;
-- CONDITIONS: WHERE
SELECT *
FROM app_store.downloads d
    RIGHT OUTER JOIN app_store.games g ON g.name = d.name
WHERE g.version = d.version;
-- Find customers who never downloaded a game
SELECT c.customerid
FROM app_store.customers c
    LEFT OUTER JOIN app_store.downloads d ON c.customerid = d.customerid
WHERE d.customerid IS NULL;
SELECT c.customerid
FROM app_store.customers c
    LEFT OUTER JOIN app_store.downloads d ON c.customerid = d.customerid
WHERE d.customerid IS NULL
    AND c.country = 'Singapore';
-- UNION : Find the customerid of all the customers who downloaded version 1.0 and 2.0 of Aerified
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '1.0'
UNION
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '2.0';
-- UNION :  Find the name and versions of all the games after GST is applied (considered to be applied if it is more than 30 cents)
SELECT g.name || ' ' || g.version AS game,
    ROUND(g.price * 1.09) AS price
FROM app_store.games g
WHERE g.price * 0.09 >= 0.3
UNION
SELECT g.name || ' ' || g.version AS game,
    g.price
FROM app_store.games g
WHERE g.price * 0.09 < 0.3;
-- INTERSECT : Find the customerid of all the customers who  downloaded both version 1.0 and 2.0 of Aerified
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '1.0'
INTERSECT
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '2.0';
-- EXCEPT: Find customers who downloaded version 1.0 but not version 2.0
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '1.0'
EXCEPT
SELECT d.customerid
FROM app_store.downloads d
WHERE d.name = 'Aerified'
    AND d.version = '2.0';