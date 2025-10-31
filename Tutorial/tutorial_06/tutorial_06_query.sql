-- TUTORIAL 06: Programming: Stored Procedures and Triggers
-- 1. Stored Functions and Procedures.
-- (a) Write a function/procedure borrow_book_func that, given the the email of a borrower
-- ( VARCHAR(256) ), the ISBN13 of a book ( CHAR(14) ), and the borrow date ( DATE ),
-- checks whether there is an available copy of the book, and, if that is the case, inserts
-- a new loan record of the copy by the borrower. Return a message indicating success
-- or failure of insertion.
-- Additionally, execute the following scenario using your function.
;
-- Adeline Wong, with email awong007@msn.com, tries to borrow 3 copies of
-- "Applied Calculus" by Deborah Hughes-Hallett, et al. with ISBN13 value
-- of 978-0470170526.
CREATE OR REPLACE FUNCTION borrow_book_func(
        borrower_email VARCHAR(256),
        ISBN13 CHAR(14),
        borrow_date DATE
    ) RETURNS TEXT AS $$ -- $$ marks the beginning and end of the function's code block, allowing the code within to contain single quotes or other special characters without needing to escape them.
DECLARE available_copy RECORD;
BEGIN
SELECT * INTO available_copy -- SELECT * INTO statement in SQL is used to copy all columns and rows from an existing table into a new table
FROM copy c
WHERE c.book = ISBN13
    AND NOT EXISTS (
        SELECT 1
        FROM loan l
        WHERE l.book = c.book
            AND l.copy = c.copy
            AND l.owner = c.owner
            AND l.returned ISNULL
    )
LIMIT 1;
-- SELECT 1: This part of the query instructs the database 
-- to return the literal value 1 for each row found. 
-- It does not select any actual columns from the table, 
-- which can be more efficient than SELECT * if only existence is being checked.
-- FROM table_name: This specifies the table from which to check for records.
-- LIMIT 1: This clause restricts the result set to a single row. 
-- As soon as the database finds one record in table_name, it stops searching and returns the literal 1.
IF NOT FOUND THEN RETURN 'No available copies of the book with ISBN 13 : ' || ISBN13;
ELSE
INSERT INTO loan (borrower, owner, book, copy, borrowed)
VALUES (
        borrower_email,
        available_copy,
        available_copy.book,
        available_copy.copy,
        borrow_date
    );
RETURN 'Book with ISBN13 : ' || ISBN13 || 'has been successfully borrowed by ' || borrower_email;
END IF;
-- END IF statement is used to mark the conclusion of an IF statement block. 
END;
$$ LANGUAGE plpgsql -- (a) Invocation
SELECT borrow_book_func (
        'awong007@msn.com',
        '978-0470170526',
        CURRENT_DATE
    );
SELECT borrow_book_func (
        'awong007@msn.com',
        '978-0470170526',
        CURRENT_DATE
    );
SELECT borrow_book_func (
        'awong007@msn.com',
        '978-0470170526',
        CURRENT_DATE
    );
-- 2. Triggers.
-- In our current database, Adeline Wong, with email awong007@msn.com, already borrowed
-- 6 books and has not returned any of the books.
-- We would like to introduce an additional constraint: A student may only borrow up to 6
-- books at a time. In other words, if a student has 6 books that have not been returned yet,
-- the student cannot borrow another book.
-- Let us explore two different strategies to enforce this constraint.
-- (a) Create a trigger that checks if a student is trying to borrow copy of a book, 
-- the loan is only successful if that student does not already have 6 active loans.
CREATE OR REPLACE FUNCTION check_local_loan_limit RETURNS TRIGGER AS $$ -- Definition of Trigger : Procedure or function executed when a database event occurs on a table
DECLARE active_loan_count INT;
BEGIN
SELECT COUNT(*) INTO active_loan_count
FROM loan l
WHERE l.borrower = NEW.borrower
    AND l.returned ISNULL;
IF active_loan_count >= 6 THEN RETURN NULL;
ELSE RETURN NULL;
END IF;
END;
$$ LANGUAGE plpgsql;
-- Triggers help to maintain data integrity, propogate updates and repair database.
-- Generalisation of ON/UPDATE/DELETE.
;
-- Insert trigger
CREATE TRIGGER enforce_global_loan_limit BEFORE
INSERT ON loan FOR EACH ROW EXECUTE FUNCTION check_global_loan_limit();
;
-- (b) Create a trigger to check that no student has more than 6 active loans.
CREATE OR REPLACE FUNCTION check_global_loan_limit() RETURN TRIGGER AS $$
DECLARE violating_student RECORD;
BEGIN
SELECT l.borrower INTO violating_student
FROM loan l
WHERE l.returned ISNULL
GROUP BY l.borrower
HAVING COUNT(*) > 6;
IF violating_student IS NOT NULL THEN RAISES EXCEPTION '% has been borrowed more than 6 books',
violating_student;
ELSE RETURN NEW;
END IF;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER enforce_global_loan_limit
AFTER
INSERT
    OR
UPDATE ON loan FOR EACH ROW EXECUTE FUNCTION check_global_loan_limit();