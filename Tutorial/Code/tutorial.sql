--Insert the following new book. Describe the behavior
SET search_path TO books_exchange;
INSERT INTO book
VALUES (
        'An Introduction to Database Systems',
        'paperback',
        640,
        'English',
        'C. J. Date',
        'Pearson',
        '2003-01-01',
        '0321197844',
        '978-0321197849'
    );
--Insert the following new student. Describe the behavior.
SET search_path TO books_exchange;
INSERT INTO student
VALUES (
        'TIKKI TAVI',
        'tikki@gmail.com',
        '2024-08-15',
        'School of Computing',
        'CS',
        NULL
    );
-- get number of students
SELECT COUNT(*) AS number_studentds
FROM books_exchange.student --Change the name of the department from 'CS' to 'Computer Science'. Describe the behaviour.
UPDATE books_exchange.student
SET department = 'Computer Science'
WHERE department = 'CS';
DELETE FROM book
WHERE ISBN13 = '978-0201385908';
--Insert the following copy of 'An Introduction to Database Systems' owned by Tikki.
SET search_path TO books_exchange;
INSERT INTO copy
VALUES (
        'tikki@gmail.com',
        '978-0321197849' 1,
        TRUE
    );