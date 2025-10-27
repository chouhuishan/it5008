--2(a): Insert the following new book. Describe the behavior
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
--INSERTION SUCCESSFUL
--2(b) : Insert the same book but with a different ISBN13 field. For instance ISBN13, with field value of '978-0201385908'. Describe the outcome of the operation.
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
        '978-0201385908'
    );
--ERROR : duplicate key value violates unique constraint "book_isbn10_key"
-- IBSN10 must be unique
-- 2(c) : Insert the same book but with a different field. For instance ISBN10, with field value of '0201385902' . Describe the outcome of the operation
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
        '0201385902',
        '978-0321197849'
    );
--ERROR: duplicate key value violates unique constraint "book_pkey"
-- PRIMARY KEY : IBSN13 --> Must be unique
-- 2(d) : Insert the following new student. Describe the behavior.
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
--INSERTION SUCCESSFUL
-- 2(e) : Insert the following new student. Describe the behavior.
SET search_path TO books_exchange;
INSERT INTO student
VALUES (
        'TIKKI TAVI',
        '2024-08-15',
        'School of Computing',
        'CS'
    );
--ERROR : invalid input syntax for type date: "School of Computing"
-- email is missing; email is primary key, cannot be empty
-- 2(f) : Change the name of the department from 'CS' to 'Computer Science'. Describe the behaviour.
SET search_path TO books_exchange;
UPDATE student
SET department = 'Computer Science'
WHERE department = 'CS' -- SET SUCCESSFUL
    -- 2(g) : Delete all the students from the 'chemistry' department.  Describe the behaviour.
SET search_path TO books_exchange;
DELETE FROM student
WHERE department = 'chemistry' -- DELETE SUCCESSFUL; BUT NOTE NOTHING IS DELETED, as SQL is case sensitive, chemistry is with lower case, and in the table it is upper case
    -- 2(h) : Delete all the students from the 'Chemistry' department.  Describe the behaviour.
SET search_path TO books_exchange;
DELETE FROM student
WHERE department = 'Chemistry' -- ERROR : update or delete on table "student" violates foreign key constraint "copy_owner_fkey" on table "copy"
    -- NOTHING deleted, due to part of control to access of the data.
    -- 3(b) : nsert the following copy of 'An Introduction to Database Systems' owned by Tikki.
SET search_path TO books_exchange;
INSERT INTO copy
VALUES (
        'tikki@gmail.com',
        '978-0321197849',
        1,
        'TRUE'
    ) -- INSERT SUCCESSFUL