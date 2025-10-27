/**
 * IT5008 Tutorial 04
 * Script adapted by Henry Heng
 */

-- NOTE: You may choose to construct an ERD for BookExchange
--       to help with crafting your queries for this tutorial.
--       Be sure to make amendments to include the "department" table first
--       before proceeding though, otherwise some of these solutions may not make sense!

/** For Question 1 */

-- Question 1a
SELECT * FROM loan l;     -- Step 1: start with gathering everything from "loan" table
                          -- We can now derive the information of the "borrower" and "owner"
                          -- by pulling reference from the "student" table.
                          -- Do this once for each of both "borrower" and "owner".
SELECT *
FROM loan l, student s1, student s2
WHERE l.owner = s1.email
AND l.borrower = s2.email;  -- Step 2: tie in reference to "student" table
                            -- NOTE: WHERE l.borrower = s1.email
                            --       AND l.owner = s2.email
                            -- is also correct.
                            -- From here, we see that the "department" columns
                            -- from joining student s1 and student s2 are shown.
                            -- Now, just add an extra constraint to see which ones are the same.
SELECT *
FROM loan l, student s1, student s2
WHERE l.owner = s1.email
AND l.borrower = s2.email
AND s1.department = s2.department;  -- Step 3: Check for similarity between students' departments
                                    -- Now, we just need to know how many records (rows) there are -
                                    -- no need to display all this information.
                                    -- We use the COUNT() function to just count the rows.
SELECT COUNT(*)
FROM loan l, student s1, student s2
WHERE l.owner = s1.email
AND l.borrower = s2.email
AND s1.department = s2.department;  -- Step 4: Count the number of records/rows/results using COUNT().

-- Question 1b
SELECT COUNT(*), d1.faculty
FROM loan l, student s1, student s2,
  department d1, department d2
WHERE l.owner = s1.email
  AND s1.department = d1.department
  AND s2.department = d2.department
  AND d1.faculty = d2.faculty;      -- Step 1: Include reference to faculty from "department" table
                                    -- This will result in an error:
                                    -- ERROR:  column "d1.faculty" must appear in the GROUP BY clause or be used in an aggregate function
                                    -- To fix this, we add a GROUP BY clause.
SELECT COUNT(*), d1.faculty
FROM loan l, student s1, student s2,
  department d1, department d2
WHERE l.owner = s1.email
  AND s1.department = d1.department
  AND s2.department = d2.department
  AND d1.faculty = d2.faculty
GROUP BY d1.faculty;                -- Step 2: Add GROUP BY clause

-- Question 1c
-- HINT: Duration of loan = <returned> - <borrowed> + 1
SELECT (CASE
  WHEN l.returned ISNULL THEN CURRENT_DATE
  ELSE l.returned
END) - l.borrowed + 1
FROM loan l;    -- Step 1: Obtain the duration of the loan for each "loan" record.
                -- Here, each record will have a "borrowed" date, 
                -- but may not have a "returned" date (i.e., loan still ongoing).
                -- In such case, use the CURRENT_DATE constant instead.
                -- We now need to obtain the average and standard deviation of all the
                -- values in the produced column.
SELECT AVG((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1),
  STDDEV_POP((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1)
FROM loan l;    -- Step 2: Use AVG() and STDDEV_POP()
                -- Both takes an input column and returns the average of the values.
                -- There's a variant of standard deviation function - STDDEV_SAMP().
                --
                -- This is more of a statistics sort of reasoning, but mathematically
                -- the sample standard deviation (STDDEV_SAMP) is meant to be used on a
                -- subset of data. You may notice that in its calculation, the division
                -- part is shown to divide one less than the number of data points 
                -- (i.e., n-1). What we have is not a subset of data, but the complete 
                -- dataset overall, so it would be more accurate to go with the 
                -- population standard deviation (STDDEV_POP) that takes this into 
                -- account - the division is by the total number of data points (i.e., n), 
                -- nothing less than that.
SELECT CEIL(AVG((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1)),
  CEIL(STDDEV_POP((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1))
FROM loan l;    -- Step 3: Use CEIL()
                -- Drawing in logic from standard form of values - 
                -- zone in on the most significant figures (i.e., what part of the long
                -- decimal tells the important story).
                -- CEIL() is enough here for our cause, but if you'd like something more
                -- accurate than merely rounding it to the next whole number/integer,
                -- using something like ::NUMERIC(10,2) for 2 d.p. accuracy can be used.
SELECT AVG((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1)::NUMERIC(10,2),
  STDDEV_POP((CASE
    WHEN l.returned ISNULL THEN CURRENT_DATE
    ELSE l.returned
  END) - l.borrowed + 1)::NUMERIC(10,2)
FROM loan l;    -- Step 3 (alternative using ::NUMERIC(10,2))

-- Alternative(s) for Question 1c
SELECT CEIL(AVG(temp.duration)), CEIL(STDDEV_POP(temp.duration))
FROM (
  SELECT ((CASE
      WHEN l.returned ISNULL THEN CURRENT_DATE
      ELSE l.returned
    END) - l.borrowed + 1) AS duration
  FROM loan l
) AS temp;    -- Another way without needing to define the duration calculation twice

SELECT AVG(COALESCE(l.returned, CURRENT_DATE) - l.borrowed + 1)::NUMERIC(10,2),
	STDDEV_POP(COALESCE(l.returned, CURRENT_DATE) - l.borrowed + 1)::NUMERIC(10,2)
FROM loan l;  -- Solution using COALESCE()


/** For Question 2 */

-- Question 2a
SELECT l.book
FROM loan l;    -- Step 1: Obtain the list of books that have been borrowed before
                -- i.e., List of books found in the "loan" table 
                -- (just using the "isbn13" value is enough, especially for Step 2)
                -- We're not looking for distinct titles/type of book borrowed,
                -- multiple students can have a book with the same title, but only
                -- some may have lent it out instead of all of them.
                -- Hence, using DISTINCT() is a mistake here!
SELECT b.title
FROM book b
WHERE b.isbn13 NOT IN (
  SELECT l.book
  FROM loan l); -- Step 2: From all the books from the "book" table,
                -- exclude the ones that have been loaned before.

-- Alternative(s) for Question 2a
SELECT b.title
FROM book b
WHERE b.isbn13 <> ALL (
  SELECT l.book
  FROM loan l); -- x NOT IN s === forall y IN s : x <> y
                -- != also works, but <> is more language neutral amongst SQL flavors.

-- Question 2b
SELECT *
FROM loan l;    -- Step 1: Start with selecting all the book copies that have been
                -- lent before, i.e., select all records in "loan" table.
                -- From here, we can select records from the "copy" table that do not
                -- appear at all in the "loan" table.
SELECT c.owner
FROM copy c
WHERE NOT EXISTS (
  SELECT *
  FROM loan l
  WHERE l.owner = c.owner   -- same copy
  AND l.book = c.book       -- same copy
  AND l.copy = c.copy       -- same owner
);              -- Step 2: Select emails from records in the "copy" table
                -- that are not found inside the "loan" table.
                -- Add the WHERE clause to check the PK of each record in the "copy" table
                -- against those that appear in the "loan" table.
                -- Recall - PK in "copy" table is (owner, book, copy)
SELECT s.name
FROM student s
WHERE s.email IN (
  SELECT c.owner
  FROM copy c
  WHERE NOT EXISTS (
    SELECT *
    FROM loan l
    WHERE l.owner = c.owner
    AND l.book = c.book
    AND l.copy = c.copy
  )
);    -- Step 3: Check to see if those emails from earlier are inside the "student" table
      -- Compare selected email (c.owner) alongside s.email, and the relevant records will appear.
      -- Selecting the name is enough for this question.

-- Alternative(s) for Question 2b
SELECT s.name
FROM student s
WHERE s.email = ANY (
  SELECT c.owner
  FROM copy c
  WHERE NOT EXISTS (
    SELECT * 
    FROM loan l
    WHERE l.owner = c.owner
    AND l.book = c.book
    AND l.copy = c.copy
  ))  -- Basically the opposite of translating NOT IN from the previous question

SELECT s.name
FROM student s
WHERE s.email IN (
  SELECT c.owner
  FROM copy c
  WHERE (c.owner, c.book, c.copy) NOT IN ( -- this line may not work for other SQL flavors
    SELECT l.owner, l.book, l.copy
    FROM loan l));  -- Using tuple construction
                    -- NOTE: May not work in some SQL flavors
                    -- I have tested this in MySQL and it works there

-- Incorrect solution for Question 2(b)
SELECT s.name
FROM student s, copy c
WHERE s.email = c.owner
AND NOT EXISTS (
  SELECT *
  FROM loan l
  WHERE l.owner = c.owner
  AND l.book = c.book
  AND l.copy = c.copy); -- SELECT s.name FROM student s, copy c
                        -- returns a cross product between the "student" and "copy" tables.
                        -- Because of this, we can expect a possibility that students'
                        -- names can appear more than once.
                        -- Even with what comes after through the NOT EXISTS clause as a
                        -- sort of filter, this does not fix this problem.

-- Question 2c
SELECT COUNT(*)
FROM student s, loan l
WHERE l.owner = s.email;  -- Step 1: Obtain total number of loan records in "loan" table
                          -- Let's introduce the total number of loans made per loan owner.
SELECT s.name, COUNT(*)
FROM student s, loan l
WHERE l.owner = s.email
GROUP BY s.email;   -- Step 2a: Include s.name - this requires GROUP BY s.email clause
                    -- s.email is used since it's the primary key 
                    -- (also multiple students having the same name at once is possible)
SELECT s.department, s.name, COUNT(*)
FROM student s, loan l
WHERE l.owner = s.email
GROUP BY s.email;   -- Step 2b: Include s.department
                    -- By this point, we have the department information of each "owner".
                    -- Right now, we only need 1 entry per department denoting only the
                    -- student from each department who lent the most.
                    --
                    -- It is important to note that using the LIMIT clause here
                    -- e.g., LIMIT 4, will not work.
                    -- For LIMIT n for some integer n, this will make it so the first n
                    -- results are displayed. There is no checking for unique departments.
SELECT s1.department, s1.name, COUNT(*) -- retain only COUNT(*); s1.department and s1.email are just to help illustrate the point
FROM student s1, loan l1,
WHERE l1.owner = s1.email
AND s1.department = 'CS'  -- using 'CS' as an example - we need this to be dynamic a bit
GROUP BY s1.email;        -- Step 3a: Subquery - Loan count of each student per department
                          -- (This can be achieved branching out from Step 2b itself)
                          -- At this point, we now need to only display 1 student per 
                          -- department - this student would have lent the most in their 
                          -- department.
                          -- One way to go about this is comparing the value of COUNT(*) 
                          -- of each student against all the other students in the 
                          -- same department.
                          -- What this is here will be a subquery to compare against what
                          -- is produced in Step 2b.
                          -- If you're not sure what's going on here, it's like a process
                          -- of obtaining the cream of the crop from a class of students.
SELECT s.department, s.name, COUNT(*)
FROM student s, loan l
WHERE l.owner = s.email
GROUP BY s.email
HAVING COUNT(*) >= ALL (            -- Compare results of outer COUNT(*) with that produced by subquery
  SELECT COUNT(*)                   -- Remember to remove s1.department and s1.name, otherwise this would not work (too many columns)
  FROM student s1, loan l1
  WHERE l1.owner = s1.email
  AND s1.department = s.department  -- THIS IS THE TRICK!
  GROUP BY s1.email
);    -- Step 3b: Compare results of Step 2b with subquery from Step 3a
      -- What this does is from each row/record produced in Step 2b,
      -- the value in the COUNT(*) column is compared against all of them inside the subquery.
      -- The subquery results will change dynamically thanks to the s1.department = s.department part.
      -- That compared row/record is maintained if its COUNT(*) value is larger than or equal to 
      -- every record from the subquery. Otherwise, it is no longer displayed.
      -- If you followed along and you have the same dummy dataset without adding more or removing any,
      -- you should see 15 rows/records as a result, one row/record per unique department.

-- Question 2d
-- Apparently there will be no result with the given dummy data.
-- Add this query to see some result.
INSERT INTO loan VALUES ('nihanran1989@msn.com', 'choyweixiang2011@gmail.com', '978-0553585971', 1, '2024-03-10', NULL);

-- So, a way to do this is to twist the directive by the question a little using "Universal Quantification".
-- The equivalent statement would be:
--  "Print the emails and the names of the different students such that 
--  for all books authored by 'Adam Smith', the student borrowed that book."
--
-- This last bit can be written as an implication statement:
--  "If the book was authored by 'Adam Smith', that book is borrowed by a student."
-- Let's split this up the LHS and RHS into the antecedent and consequent respectively - say `p` and `q` respectively.
-- Logically, this would also be the same as `NOT p OR q`. Stay with me here.
-- If we invert that (i.e., `NOT (NOT p OR q)`), it's `p AND NOT q`.
-- In our context, this means:
--  "The book is authored by 'Adam Smith', and the student did not borrow that book."
-- To satisfy our question, we are going to invert it again,
-- (i.e., `NOT (NOT (NOT p OR q))`).
-- This will form the structure of our query for this question.
-- Basically, we will now select students who are
--    NOT those students who did not

SELECT *
FROM book b
WHERE authors = 'Adam Smith'; -- Step 1: Select all the books authored by 'Adam Smith'
                              -- We have created our antecedent p here,
                              -- now let's expand this so that it matches our first inverted
                              -- statement: p AND NOT q.
SELECT * 
FROM book b
WHERE authors = 'Adam Smith'
AND NOT EXISTS (              -- NOT EXIST clause: TRUE if no rows or results come of it
  SELECT *
  FROM loan l
  WHERE l.book = b.isbn13     -- connection here: a loan involving borrowing that book
);  -- Step 2: Select all the books authored by 'Adam Smith' that are not lent by anyone

SELECT s.email, s.name
FROM student s
WHERE NOT EXISTS (
  SELECT *
  FROM book b
  WHERE authors = 'Adam Smith'
  AND NOT EXISTS (
    SELECT *
    FROM loan l
    WHERE l.book = b.isbn13
    AND l.borrower = s.email    -- IMPORTANT
  )
);    -- Step 3: Select students that are not selected with Step 2's query

