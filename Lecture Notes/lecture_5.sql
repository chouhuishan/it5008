-- make a copy of the subquery in the temporary table
CREATE TEMPORARY TABLE singapore_customer AS
SELECT *
FROM app_store.customers c
WHERE c.country = 'Singapore';
-- Note that temporary table only exist during duration of the database session
-- No change in copy; copies do not change when base table change
SELECT c.last_name,
    d.name
FROM app_store.customers c,
    app_store.downloads d
WHERE c.country = 'Singapore'
    AND c.customerid = d.customerid;
-- VIEW change when base table change
CREATE VIEW singapore_customer AS
SELECT *
FROM app_store.customers c
WHERE c.country = 'Singapore';
-- Common table expression (CTE) is a copy of the subquery in a temp table that only exists for the query
WITH singapore_customer AS (
    SELECT *
    FROM app_store.customers c
    WHERE c.country = 'Singapore'
)
SELECT cs.last_name,
    d.name
FROM singapore_customer cs,
    app_store.downloads d
WHERE cs.customerid = d.customerid;
-- FROM clause : Subquery 
SELECT cs.last_name,
    d.name
FROM (
        SELECT *
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    ) AS cs,
    app_store.downloads d
WHERE cs.customerid = d.customerid;
-- SELECT clause : Subquery --> return 1 column and 1 row (SCALAR SUBQUERY)
SELECT (
        SELECT COUNT(*)
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    );
-- Use subquery in WHERE clause to compute the tuples for IN clause
SELECT d.name
FROM app_store.downloads d
WHERE d.customerid IN (
        SELECT c.customerid
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    );
-- this query is the same as below
SELECT d.name
FROM app_store.downloads d
WHERE d.customerid IN (
        SELECT c.customerid
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    );
-- this query is the same as above
-- NEVER use comparison to a subquery without specifying the quantifier ALL or ANY
SELECT d.name
FROM app_store.downloads d
WHERE d.customerid = ANY (
        SELECT c.customerid
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    );
-- ALL : Adds expressive power similar to OUTER JOIN, EXCEPT
-- Query finds the most expensive games
SELECT g1.name,
    g1.version,
    g1.price
FROM app_store.games g1
WHERE g1.price >= ALL (
        SELECT g2.price
        FROM app_store.games g2
    );
-- What happends if the above code 'ALL' is changed to 'ANY'??
-- All games are printed
SELECT g1.name,
    g1.version,
    g1.price
FROM app_store.games g1
WHERE g1.price >= ANY (
        SELECT g2.price
        FROM app_store.games g2
    );
-- ERROR: aggregate functions are not allowed in WHERE
SELECT g.name,
    g.version,
    g.price
FROM app_store.games g
WHERE g.price = MAX(g.price);
-- ERROR: syntax error at or near "SELECT" at character 88 ?????
SELECT g1.name,
    g1.version,
    g1.price
FROM app_store.games g1
WHERE g1.price = MAX(
        SELECT g2.price
        FROM app_store.games g2
    );
-- How to correct the above 2 errors?
SELECT g1.name,
    g1.version,
    g1.price
FROM app_store.games g1
WHERE g1.price = ALL(
        SELECT MAX(g2.price)
        FROM app_store.games g2
    );
-- EXISTS: Evaluates to True if the subquery has some result
-- Evaluates to False if the subquery does not yield any result
-- Correlated subquery : the subquery is correlated to the query 
--                      (column d.customerid of the customer table of the outer query appears in the WHERE clause of the inner query)
SELECT d.name
FROM app_store.downloads d
WHERE EXISTS (
        SELECT c.customerid
        FROM app_store.customers c
        WHERE d.customerid = c.customerid
            AND c.country = 'Singapore'
    );
-- NOTE: All subqueries can be correlated
-- The query below finds the names, versions, and prices the games that are the most expensive among the games of the same name
SELECT g1.name,
    g1.version,
    g1.price
FROM app_store.games g1
WHERE g1.price >= ALL (
        SELECT g2.price
        FROM app_store.games g2
        WHERE g1.name = g2.name
    );
--SCOPING: Use column from an outer table in an inner query
-- NOTE: You cannot do the other way round
-- TODO : recheck this code 
SELECT c.customerid,
    d.name
FROM app_store.downloads d,
    app_store.customers c
WHERE d.customerid IN (
        SELECT c.customerid
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
    );
-- SCALAR: customerid is the primary key --> guarenteed to be scalar
SELECT (
        SELECT c.last_name
        FROM app_store.customers c
        WHERE c.country = 'Singapore'
            AND d.customerid = c.customerid
    ),
    d.name
FROM app_store.downloads d;
-- NESTED QUERIES :  Powerful when combined with negation
-- All 3 queries below find the 22 customers who never downloaded the game
-- VERSION 1
SELECT c.customerid
FROM app_store.customers c
WHERE c.customerid NOT IN (
        SELECT d.customerid
        FROM app_store.downloads d
    );
-- VERSION 2 
SELECT c.customerid
FROM app_store.customers c
WHERE c.customerid <> ALL (
        SELECT d.customerid
        FROM app_store.downloads d
    ) -- VERSION 3
SELECT c.customerid
FROM app_store.customers c
WHERE NOT EXISTS (
        SELECT d.customerid
        FROM app_store.downloads d
        WHERE c.customerid = d.customerid
    );
-- NESTED QUERIES : Neccessary when using aggregate functions on two different groupings
-- The query on the left finds countries with the largest number of customers
-- MUST GET FAMILIAR WITH THIS; COMMONLY USED IN ANALYTICS
SELECT c1.country
FROM app_store.customers c1
GROUP BY c1.country
HAVING COUNT(*) >= ALL (
        SELECT COUNT(*)
        FROM app_store.customers c2
        GROUP BY c2.country
    );
-- get familiar with phrasing of the questions; typical analytics questions