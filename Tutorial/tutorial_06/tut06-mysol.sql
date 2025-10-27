/**
 * IT5008 Tutorial 06
 * Script adapted by Henry Heng
 */

/** For Question 1 */

-- Question 1a (Stored Function)
CREATE OR REPLACE FUNCTION borrow_book_func(
  -- Given...
  borrower_email VARCHAR(256),  -- email of a borrower
  isbn13 CHAR(14),              -- ISBN13 of a book
  borrow_date DATE              -- borrow date
) RETURNS TEXT AS $$      -- return a message indicating success or failure of insertion
DECLARE
  available_copy RECORD;  -- to contain rows of books not actively being loaned (refer Step 1)
BEGIN
  -- Step 1: Check for a copy of the book that is not currently borrowed (i.e., no active loan)
  SELECT * INTO available_copy
  FROM copy c
  WHERE c.book = isbn13
    AND NOT EXISTS (
      -- 1 is just a placeholder, 
      --  since the database only needs to know if the row exists
      -- if rows exist (i.e., the following subquery produces results)
      --  then EXISTS(...) will return TRUE -> NOT EXISTS(...) will return FALSE
      SELECT 1 FROM loan l    
      WHERE l.book = c.book
        AND l.copy = c.copy
        AND l.owner = c.owner
        AND l.returned ISNULL
    )
  LIMIT 1;

  -- Step 2
  IF NOT FOUND  -- if no available_copy of book to borrow, return message
  THEN
    RETURN 'No available copies of the book with ISBN 13 : ' || isbn13;
  ELSE
    -- otherwise, insert a new loan record of the book copy by the borrower
    INSERT INTO loan (borrower, owner, book, copy, borrowed)
    VALUES (borrower_email, available_copy.owner, 
      available_copy.book, available_copy.copy, borrow_date);
    
    -- then return success message
    RETURN 'Book with ISBN13 : ' || isbn13 || ' has been successfully borrowed by ' || borrower_email;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- to invoke for Q1a (Stored Function)
SELECT borrow_book_func('awong007@msn.com', '978-0470170526', CURRENT_DATE);
SELECT borrow_book_func('awong007@msn.com', '978-0470170526', CURRENT_DATE);
SELECT borrow_book_func('awong007@msn.com', '978-0470170526', CURRENT_DATE);

-- Question 1a (Procedure)
CREATE OR REPLACE PROCEDURE borrow_book_proc(
  -- Given...
  borrower_email VARCHAR(256),  -- email of a borrower
  isbn13 CHAR(14),              -- ISBN13 of a book
  borrow_date DATE              -- borrow date
) AS $$
DECLARE
  available_copy RECORD;  -- to contain rows of books not actively being loaned (refer Step 1)
BEGIN
  -- Step 1: Check for a copy of the book that is not currently borrowed (i.e., no active loan)
  SELECT * INTO available_copy
  FROM copy c
  WHERE c.book = isbn13
    AND NOT EXISTS (
      -- 1 is just a placeholder, 
      --  since the database only needs to know if the row exists
      -- if rows exist (i.e., the following subquery produces results)
      --  then EXISTS(...) will return TRUE -> NOT EXISTS(...) will return FALSE
      SELECT 1 FROM loan l    
      WHERE l.book = c.book
        AND l.copy = c.copy
        AND l.owner = c.owner
        AND l.returned ISNULL
    )
  LIMIT 1;

  -- Step 2
  IF NOT FOUND  -- if no available_copy of book to borrow, return message
  THEN
    -- RETURN 'No available copies of the book with ISBN 13 : ' || isbn13;
    RAISE NOTICE 'No available copies of the book with ISBN13 : %', isbn13;
    RETURN;
  ELSE
    -- otherwise, insert a new loan record of the book copy by the borrower
    INSERT INTO loan (borrower, owner, book, copy, borrowed)
    VALUES (borrower_email, available_copy.owner, 
      available_copy.book, available_copy.copy, borrow_date);
    
    -- then return success message
    -- RETURN 'Book with ISBN13 : ' || isbn13 || ' has been successfully borrowed by ' || borrower_email;
    RAISE NOTICE 'Book with ISBN13 : % has been successfully borrowed by %', isbn13, borrower_email;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- to invoke for Q1a (procedure)
CALL borrow_book_proc('awong007@msn.com', '978-0470089156', CURRENT_DATE);
CALL borrow_book_proc('awong007@msn.com', '978-0470089156', CURRENT_DATE);
CALL borrow_book_proc('awong007@msn.com', '978-0470089156', CURRENT_DATE);
CALL borrow_book_proc('awong007@msn.com', '978-0470089156', CURRENT_DATE);

-- to drop all functions (and basically everything; need to reconstruct BookExchange db again)
-- change `public` to the name of your schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;

/** For Question 2 */

-- Question 2a ("local" strategy since it checks for local consistency)
--              i.e., current student being inserted/updated does not violate condition
CREATE OR REPLACE FUNCTION check_local_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  active_loan_count INT;  -- to contain number of active loans (not yet returned)
BEGIN
  -- Count the number of active loans (not yet returned)
  SELECT COUNT(*) INTO active_loan_count
  FROM loan l
  WHERE l.borrower = NEW.borrower
    AND l.returned ISNULL;
  
  -- to enforce: loan is only successful if that student does not already have 6 active loans
  IF active_loan_count >= 6
  THEN
    RETURN NULL;  -- prevent borrowing
  ELSE
    RETURN NEW;   -- allow borrowing
  END IF;
END;
$$ LANGUAGE plpgsql;

-- enforce this trigger for inserts into the loan table
CREATE TRIGGER enforce_local_loan_limit_insert
BEFORE INSERT ON loan
FOR EACH ROW EXECUTE FUNCTION check_local_loan_limit();

-- to drop trigger to test other triggers
DROP TRIGGER enforce_local_loan_limit_insert ON loan;
DROP FUNCTION check_local_loan_limit();

-- Question 2b ("global" strategy since it checks for global consistency)
--              i.e., no student violates condition
CREATE OR REPLACE FUNCTION check_global_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  violating_student RECORD;   -- to contain an offending student
BEGIN
  -- Check if there exists any student with >6 active loans
  SELECT l.borrower INTO violating_student
  FROM loan l
  WHERE l.returned ISNULL
  GROUP BY l.borrower
  HAVING COUNT(*) > 6;

  IF violating_student IS NOT NULL
  THEN  -- violation -> raise exception
    RAISE EXCEPTION '% has borrowed more than 6 books', violating_student
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- enforce this trigger for inserts into the loan table
CREATE TRIGGER enforce_global_loan_limit
AFTER INSERT OR UPDATE ON loan
FOR EACH ROW EXECUTE FUNCTION check_global_loan_limit();

-- test trigger
CALL borrow_book_proc('awong007@msn.com', '978-1449389673', CURRENT_DATE);

-- to drop trigger to test other triggers
DROP TRIGGER enforce_global_loan_limit ON loan;
DROP FUNCTION check_global_loan_limit();

