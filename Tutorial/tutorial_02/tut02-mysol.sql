/**
 * IT5008 Tutorial 02
 * Script adapted by Henry Heng
 */

-- Important note (from PDF):
-- This tutorial is designed to be solved using **simple queries only**.
-- This means your answers should not contain nested or aggregate queries (e.g., COUNT, SUM).

/** For Question 1 */

-- Question 1a: Print all departments
-- Question 1b: Print the different departments in which students are enrolled
-- NOTE: Which question in the PDF is asking for unique departments?
/**
  * Among the 4 tables in the NUNStA database,
  * the "student" table contains the "department" information (as a column).
  * If you don't know where to start from here,
  * start with a simple SELECT query (refer Step 1).
  * 
  * Then, single out the "department" column by replacing the star `*`
  * with the associated column (refer Step 2).
  * 
  * Right here, you would have obtained the department for each student,
  * but having each of them appear more than once is much more information than necessary.
  * To single out the unique departments, you can use the DISTINCT keyword (refer Step 3).
  */
SELECT * FROM "student";                      -- Step 1
SELECT "department" FROM "student";           -- Step 2 (end Q1a)
SELECT DISTINCT "department" FROM "student";  -- Step 3 (end Q1b)

-- Question 1c
/**
  * Start with a simple SELECT query on the "loan" table. (refer Step 1)
  * 
  * You require an ISBN13 column and another column signifying the duration of the loan.
  * We do not have a column that explicitly states the duration of the loan,
  * but we will get to that in a bit -
  * that can be obtained using the "borrowed" and "returned" column values.
  * For now, single out the "book" column
  * (which contains the referenced ISBN13 value from the "book" table),
  * as well as the associated "borrowed" and "returned" columns (refer Step 2).
  * 
  * Now that we have the ISBN13 value of each loaned book,
  * we now need to obtain the duration of the loan.
  * We can calculate this by subtracting the "borrowed" date from the "returned" date.
  * Notice here that the resultant column gets named `?column?` automatically.
  * Label the new column as "duration" - 
  * I would recommend you do this to avoid confusion (refer Step 3a).
  * This may cause errors if "returned" is NULL (by table definition, this is permitted).
  * To fix this, we can add a WHERE clause 
  * to only associate those without NULL "returned" values (refer Step 3b).
  *
  * We do not need to explicitly state the "borrowed" or "returned" columns 
  * in the final output.. why is that?
  * HINT: What can unwanted actors do with too much information on their hands?
  * 
  * Now, we want to order the results by ISBN13 value in ascending order,
  * followed by the duration of the loan in descending order.
  * (Optional: If you find associating the "book" column as the ISBN13 value confusing,
  *            simply rename the column as "isbn13", for instance.)
  * We carry this out by adding the ORDER BY clause.
  * Start with ordering the results by ISBN13 value in ascending order (refer Step 4), 
  * followed by the "duration" in descending order (refer Step 5).
  * Note that if you do not explicitly specify "ASC" or "DESC",
  * the default would be "ASC" (i.e., ascending order).
  */
SELECT * FROM "loan";                                   -- Step 1
SELECT "book", "borrowed", "returned" FROM "loan";      -- Step 2

SELECT "book", ("returned" - "borrowed") AS "duration" 
FROM "loan";                                            -- Step 3a

SELECT "book", ("returned" - "borrowed") AS "duration" 
FROM "loan"
WHERE "returned" IS NOT NULL;                           -- Step 3b

SELECT "book", ("returned" - "borrowed") AS "duration" 
FROM "loan"
WHERE "returned" IS NOT NULL
ORDER BY "book" ASC;                                    -- Step 4

SELECT "book", 
  ("returned" - "borrowed") AS "duration" 
FROM "loan"
WHERE "returned" IS NOT NULL
ORDER BY "book" ASC, "duration" DESC;                   -- Step 5

-- Alternatives for Question 1c
-- These would allow for if the "returned" value is NULL.
SELECT "book", 
  (COALESCE("returned", CURRENT_DATE) - "borrowed") AS "duration"
FROM "loan"
ORDER BY "book" ASC, "duration" DESC;

SELECT "book",
  ((CASE
    WHEN "returned" ISNULL THEN CURRENT_DATE
    ELSE "returned"
  END) - "borrowed" + 1) AS "duration"
FROM "loan"
ORDER BY "book" ASC, "duration" DESC;

/** For Question 2 */

-- Question 2a
/**
  * We need the title of the book, the name and faculty of the owner,
  * and the name and faculty of the borrower.
  * Selecting the book "title" is simple enough,
  * but coming to the name and faculty of the owner.. 
  * (notice I did not say **only** from which tables)
  * we will need information from the "copy" and "student" table.
  * The "copy" table only contains the owner's email address;
  * to get the owner's name and faculty, 
  * you will want to join the "student" table on the email address (refer Step 1a).
  */
SELECT "name", "faculty" 
FROM "student", "copy"
WHERE "student"."email" = "copy"."owner"; -- Step 1a

/**
  * At this point, having short aliases for each of the tables would help
  * to make the query more readable (not as verbose).
  * I recommend "b" for "book", "s" for "student",
  * "c" for "copy", and "l" for "loan" (refer Step 1b).
  */
SELECT s."name", s."faculty" 
FROM "student" s, "copy" c
WHERE s."email" = c."owner"; -- Step 1b

/**
  * A similar query can be constructed 
  * if we want to obtain the borrower's name and faculty.
  * The only additional difference here is that we can specify 
  * which ones belong to rows with a NULL return date (refer Step 1c).
  */
SELECT s."name", s."faculty"
FROM "student" s, "loan" l
WHERE s."email" = l."borrower"
  AND l."returned" ISNULL; -- Step 1c

/**
  * Now, we will need to have these two queries (Step 1b and 1c) combined,
  * but notice that both queries are selecting from the same "student" table.
  * To differentiate them, let's modify the table aliases to s1 for the owner
  * and s2 for the borrower.
  * To better differentiate them further, 
  * the columns can be renamed accordingly (refer Step 1d).
  */
SELECT s1."name" as "ownerName", 
  s1."faculty" as "ownerFaculty", 
  s2."name" as "borrowerName", 
  s2."faculty" as "borrowerFaculty"
FROM "student" s1, "student" s2, "copy" c, "loan" l -- the order of these do not matter
WHERE s1."email" = c."owner" 
  AND s2."email" = l."borrower"
  AND l."returned" ISNULL;  -- Step 1d

/**
  * Before we continue, notice that in the "loan" table, there is a FK reference 
  * to "copy"("owner", "book", "copy").
  * This means that we can expect for each row in the "loan" table,
  * there is a corresponding ("owner", "book", "copy") combo in the "copy" table.
  * From here, we can remove reference to the "copy" table like as follows (refer Step 1e):
  */
SELECT s1."name" as "ownerName", 
  s1."faculty" as "ownerFaculty", 
  s2."name" as "borrowerName", 
  s2."faculty" as "borrowerFaculty"
FROM "student" s1, "student" s2, "loan" l   -- remove "copy" c
WHERE s1."email" = l."owner"                -- change c."owner" to l."owner"
  AND s2."email" = l."borrower"
  AND l."returned" ISNULL;  -- Step 1e

/**
  * Now, let's add the book title information (only those from Wiley)
  * into the select statement we have (refer Step 2).
  * NOTE: With just the dummy data, it should show 10 rows only.
  */
SELECT b."title",
  s1."name" as "ownerName", 
  s1."faculty" as "ownerFaculty", 
  s2."name" as "borrowerName", 
  s2."faculty" as "borrowerFaculty"
FROM "book" b, "student" s1, "student" s2, "loan" l
WHERE s1."email" = l."owner"
  AND s2."email" = l."borrower"
  AND l."returned" ISNULL
  AND l."book" = b."isbn13"     -- link l."book" to b."isbn13", add publisher constraint
  AND b."publisher" = 'Wiley';  -- Step 2

-- Alternative for Question 2a
SELECT b."title",
  s1."name" as "ownerName",
  s1."faculty" as "ownerFaculty",
  s2."name" as "borrowerName",
  s2."faculty" as "borrowerFaculty"
FROM "loan" l
  INNER JOIN "book" b ON l."book" = b."isbn13"
  INNER JOIN "student" s1 ON l."owner" = s1."email"
  INNER JOIN "student" s2 ON l."borrower" = s2."email"
WHERE b."publisher" = 'Wiley'
  AND l."returned" ISNULL;

-- Question 2b
/**
  * Let's start with simply selecting all distinct emails 
  * from the "students" table (refer Step 1). 
  */
SELECT DISTINCT s."email" FROM "student" s;

/**
  * We need the emails of students who borrowed or lent books 
  * before they joined the university.
  * We can achieve this by checking the "loan" table, specifically
  * s."year" against l."borrowed" (refer Step 2).
  */
SELECT DISTINCT s."email"
FROM "student" s, "loan" l
WHERE (s."email" = l."borrower" OR s."email" = l."owner") -- student is either borrower or lender
  AND s."year" > l."borrowed";  -- Step 2

-- Alternative(s) to Question 2b
SELECT DISTINCT s."email"
FROM "student" s
  INNER JOIN "loan" l ON s."email" = l."borrower" OR s."email" = l."owner"
WHERE s."year" > l."borrowed";

SELECT DISTINCT s."email"
FROM "student" s, "loan" l
WHERE (s."email" = l."borrower" AND l."borrowed" < s.year)
  OR (s."email" = l."owner" AND l."borrowed" < s.year);
-- (x OR y) AND z === (x AND z) OR (x AND y) # (Distributive Law)

-- Question 2c
/**
  * One solution is a simple modification from one of those for Question 2b.
  */
SELECT DISTINCT s."email"
FROM "student" s, "loan" l
WHERE (s."email" = l."borrower" OR s."email" = l."owner")
  AND s."year" = l."borrowed";  -- Change > to =, we want those who borrowed or lent 
                                -- on the day they entered the university.

SELECT DISTINCT s."email"
FROM "student" s
	INNER JOIN "loan" l ON s."email" = l."borrower" OR s."email" = l."owner"
WHERE s."year" = l."borrowed";

/**
  * However, you may later notice that these solutions are not as extensible
  * to the next question(s).
  * Here's an alternative using the UNION operator.
  * Note that here, DISTINCT is not required unlike the previous queries
  * since UNION (as well as INTERSECT and EXCEPT) removes duplicates.
  */
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."borrower" AND l."borrowed" = s."year"
UNION
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."owner" AND l."borrowed" = s."year";

-- Question 2d
/**
  * Question 2c required a query to select those who either borrowed or lent books
  * on the day they entered the university.
  * To produce a query to select those who did both, we can use the INTERSECT operator.
  */
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."borrower" AND l."borrowed" = s."year"
INTERSECT
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."owner" AND l."borrowed" = s."year";

/**
  * This can also be done without using INTERSECT,
  * but it requires two "loan" tables.
  */
SELECT DISTINCT s."email"
FROM "loan" l1, "loan" l2, "student" s
WHERE s."email" = l1."borrower" AND l1."borrowed" = s."year"
  AND s."email" = l2."owner" AND l2."borrowed" = s."year";

SELECT DISTINCT s."email"
FROM "student" s
  INNER JOIN "loan" l1 ON s."email" = l1."borrower"
  INNER JOIN "loan" l2 ON s."email" = l2."owner"
WHERE l1."borrowed" = s."year"
  AND l2."borrowed" = s."year";

-- Question 2e
/**
  * You have to use the EXCEPT operator to carry out this operation - 
  * finding those who borrowed books but did not lend any
  * on the day they entered the university.
  * To carry out the same operation without the EXCEPT operator,
  * a nested or aggregate query is required.
  */
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."borrower" AND l."borrowed" = s."year"
EXCEPT
SELECT s."email"
FROM "loan" l, "student" s
WHERE s."email" = l."owner" AND l."borrowed" = s."year";

-- Question 2f
/**
  * The dummy data prepared for you will not render any results
  * for this query.
  * However, you may test it out by inserting a few more records
  * into the "book" table.
  */
SELECT b."isbn13" FROM "book" b
EXCEPT
SELECT l."book" FROM "loan" l;

-- Alternative to Question 2f
/**
  * Note that using OUTER JOIN can introduce NULL values.
  * In such case, you can use the ISNULL function to handle them.
  * LEFT OUTER JOIN: fetches data if present in the left table.
  * Here, the left table is "book" b and the right table is "loan" l.
  */
SELECT b."isbn13" FROM "book" b
  LEFT OUTER JOIN "loan" l ON b."isbn13" = l."book"
  WHERE l."book" ISNULL;
