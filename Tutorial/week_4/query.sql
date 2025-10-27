--1(a) : Print the different departments -- 
SELECT department
FROM books_exchange.student;
-- 1(b) : Print the different departments in which students are enrolled --
SELECT DISTINCT department
FROM books_exchange.student;
ORDER BY department --1(c) : For each copy that has been borrowed and returned, print the ISBN13 of the book and the duration of the loan. Order the results in ascending order of the ISBN13 and descending order of duration. Remember to use only one single table.
SELECT book,
    borrowed,
    returned
FROM books_exchange.loan
SELECT book,
    (returned - borrowed + 1) AS duration -- return and borrow into one column as duration
FROM books_exchange.loan
WHERE returned IS NOT NULL
SELECT book (
        (
            CASE
                WHEN returned IS NULL THEN CURRENT_DATE -- ENTRY: ERROR --> missing FROM-clause entry for table "current"
                ELSE returned
            END
        ) - borrowed + 1
    ) AS duration
FROM books_exchange.loan
ORDER BY book ASC,
    duration DESC
SELECT book,
    (returned - borrowed + 1) AS duration
FROM books_exchange.loan
WHERE returned IS NOT NULL
ORDER BY book ASC,
    duration DESC --2(a) : For each loan of a book published by Wiley that has not been returned, 
    --print the title of the book, the name and faculty of the owner and the 
    --name and faculty of the borrower
SELECT name,
    faculty
FROM books_exchange.student s,
    books_exchange.copy c
WHERE s.email = c.owner;
SELECT s.name,
    s.faculty
FROM books_exchange.student s,
    books_exchange.loan l
WHERE s.email = l.owner
    AND l.returned IS NULL;
-- combination of the above two codes
SELECT b.title,
    s1.name AS OwnerName,
    s1.faculty AS OwnerFaculty,
    s2.name AS borrowerName,
    s2.faculty AS borrowerFaculty
FROM books_exchange.student s1,
    books_exchange.student s2,
    books_exchange.copy c,
    books_exchange.loan l
WHERE s1.email = c.owner
    AND s2.email = l.owner
    AND l.returned IS NULL
    AND b.publisher = 'Wiley' ---- 2(b) : Let us check the integrity of the data. Print the different emails of the 
    --students who borrowed or lent a copy of a book before they joined the University. 
    -- There should not be any.
SELECT DISTINCT s.email
FROM books_exchange.student s,
    books_exchange.loan l
WHERE (
        s.email = l.borrower
        OR s.email = l.owner
    )
    AND s.year > l.borrowed
SELECT DISTINCT s.email
FROM books_exchange.student s
    INNER JOIN books_exchange.loan l ON s.email = l.borrower
    OR s.email = l.owner
WHERE s.year > l.borrowed
SELECT DISTINCT s.email
FROM books_exchange.student s,
    loan l
WHERE (
        s.email = l.borrower
        AND s.year > l.borrowed
    )
    OR (
        s.email = l.owner
        AND s.year > l.borrowed
    )
SELECT s.email
FROM books_exchange.loan l,
    books_exchange.student s
WHERE s.email = l.borrower
    AND l.borrowed = s.year
INTERSECT
SELECT s.email
FROM books_exchange.loan l,
    books_exchange.student s
WHERE s.email = l.owner
    AND l.borrowed = s.year
SELECT b.ISBN13
FROM books_exchange.b
EXCEPT
SELECT l.book
FROM books_exchange.loan l