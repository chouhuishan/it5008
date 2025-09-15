-- Aggregate Queries
-- 1(a) : How many loans involve an owner and a borrower from the same department?
SELECT COUNT(*)
FROM books_exchange.loan l,
    books_exchange.student s1,
    books_exchange.student s2
WHERE l.owner = s1.email
    AND l.borrower = s2.email
    AND s1.department = s2.department;
-- 1(b) : For each faculty, print the number of loans that involve an owner and a borrower from this faculty?
SELECT d1.faculty,
    COUNT(*)
FROM books_exchange.loan l,
    books_exchange.student S1,
    books_exchange.student s2,
    department d1,
    department d2
WHERE l.owner = s1.email
    AND l.borrower = s2.email
    AND s1.department = d1.department
    AND s2.department = d2.department
    AND d1.department = d2.department
GROUP BY d1.faculty;
-- 1(c) : What are the average and the standard deviation [3] of the duration of a loan in days?
SELECT CEIL(AVG(returned - borrowed) + 1),
    CEIL(STDDEV(returned - borrowed) + 1)
FROM books_exchange.loan;
SELECT CEIL(AVG(COALESCE(returned, CURRENT_DATE))),
    CEIL(STDDEV(COALESCE(returned, CURRENT_DATE)))
FROM books_exchange.loan;
--CASE WHEN returned is NULL 
--THEN CURRENT_DATE 
--ELSE returned 
--END
--COLESCE(returned, CURRENT_DATE) : returns first NON-NULL expression from a list of expression
;
-- 2(a) : Print the titles of the diﬀerent books that have never been borrowed. Use a nested query.
SELECT title
FROM books_exchange.book
WHERE isbn13 NOT IN (
        SELECT books_exchange.book
        FROM books_exchange.loan
    );
-- 2(b) : Print the name of the diﬀerent students who own a copy of a book that they have never lent to anybody.
-- we want the students to be distinct, not the names
SELECT name
FROM books_exchange.student s
WHERE s.email IN (
        SELECT c.owner
        FROM books_exchange.copy c
        WHERE NOT EXIST (
                SELECT *
                FROM books_exchange.loan l
                WHERE l.owner = c.owner
                    AND l.book = c.book
                    AND l.copy = c.copy
            )
    );
-- NOT EXIST is better than NOT in (for this question)
-- this leads to an inner join, to let us check within a single query
;
-- 2(c) : For each department, print the names of the students who lent the most.
SELECT s.department,
    s.name
FROM books_exchange.student s,
    books_exchange.loan l
WHERE l.owner = s.email
GROUP BY s.department,
    s.email
HAVING COUNT(*) >= ALL (
        SELECT COUNT(*)
        FROM books_exchange.student s1,
            books_exchange.loan l1
        WHERE l1.owner = s1.email
        GROUP BY s1.email
    );
-- 2(d) : Print the emails and the names of the diﬀerent students who borrowed all the books authored by Adam Smith
SELECT s.email,
    s.name
FROM books_exchange.student s
WHERE NOT EXIST (
        SELECT *
        FROM books_exchange.book b
        WHERE authors = 'Adam Smith'
            AND NOT EXIST (
                SELECT *
                FROM books_exchange.loan l
                WHERE l.book =
            )
    )