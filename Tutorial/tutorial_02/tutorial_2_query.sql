--1(a) Print the dierent departments.
SELECT department
FROM books_exchange.student;
--1(b) : Print the dierent departments in which students are enrolled
SELECT DISTINCT department
FROM books_exchange.student
ORDER BY department;
--1(c) : For each copy that has been borrowed and returned, print the ISBN13 of the book and the duration of the loan. Order the results in ascending order of the ISBN13 and descending order of duration. Remember to use only one single table.
SELECT book,
    (returned - borrowed + 1) AS duration
FROM books_exchange.loan
WHERE returned is NOT NULL
ORDER BY book ASC,
    duration DESC;
--1(c): Alternative
SELECT book,
    (COALESCE(returned, CURRENT_DATE) - borrowed + 1) AS duration -- Lack of comma leads to error "book," --> function book(integer) does not exist
FROM books_exchange.loan
ORDER BY book ASC,
    duration DESC;
--COALESCE returns the first non-NULL value --> returns CURRENT_DATE is null
--1(c) : Alternative
--2(a) : For each loan of a book published by Wiley that has not been returned, print the title of the book, the name and faculty of the owner and the name and faculty of the borrower.
SELECT b.title,
    s1.name AS ownerName,
    d1.faculty AS OwnerFaculty,
    s2.name AS borrowerName,
    d2.faculty AS borrowerFaculty
FROM books_exchange.loan AS l,
    books_exchange.book AS b,
    books_exchange.copy AS c,
    book_exchange.student AS s1,
    book_exchange.student AS s2,
    department d1,
    department d2
WHERE l.book = b.isbn13 -- column under loan(book) is the ibsn13 == to ibsn13 under book(ibsn13)
    AND c.book = l.book -- column under copy(book) is the ibsn13
    AND c.copy = l.copy -- column under copy(copy) is number of copy == column under loan(copy) is number of copy
    AND l.owner = s1.email -- column under loan(owner) is owner of the book == column under student(email) 
    AND l.borrower = s2.email -- column under loan(borrower) is person who borrowed the book == column under student(email) 
    AND s1.department = d1.department
    AND s2.department = d2.department
    AND b.publisher = "Wiley"
    AND l.returned IS NULL