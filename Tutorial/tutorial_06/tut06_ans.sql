-- Q1 Simple Test
CALL borrow_book_proc('awong007@msn.com', '978-1449389673',
  CURRENT_DATE);


-- Q1a Stored Function
CREATE OR REPLACE FUNCTION borrow_book_func (
  borrower_email VARCHAR (256), isbn13 CHAR (14), borrow_date DATE
) RETURNS TEXT AS $$
DECLARE
  available_copy RECORD ;
BEGIN
  -- Check for a copy of the book that is not currently borrowed
  --   (i.e., no active loan)
  SELECT * INTO available_copy
  FROM copy c
  WHERE c.book = isbn13
    AND NOT EXISTS (
      SELECT 1 FROM loan l
      WHERE l.book = c.book
        AND l.copy = c.copy
        AND l.owner = c.owner
        AND l.returned IS NULL
    )
  LIMIT 1;
  
  IF NOT FOUND -- No available copy found, return a message
  THEN
    RETURN 'No available copies of the book with ISBN13 : ' || isbn13;
  ELSE -- An available copy found
    -- Insert a new record into the loan table to record the borrowing
    INSERT INTO loan (borrower, owner, book, copy, borrowed)
    VALUES (borrower_email, available_copy.owner,
      available_copy.book, available_copy.copy, borrow_date);
    -- Return a success message
    RETURN 'Book with ISBN13 : ' || isbn13 ||
      ' has been successfully borrowed by ' || borrower_email;
  END IF;
END;
$$ LANGUAGE plpgsql;


-- Q1a Trigger Function
CREATE OR REPLACE FUNCTION check_local_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  active_loan_count INT;
BEGIN
  -- Count the number of active loans (not yet returned)
  SELECT COUNT(*) INTO active_loan_count
  FROM loan l
  WHERE l.borrower = NEW.borrower
    AND l.returned ISNULL;
  
  IF active_loan_count >= 6
  THEN
    RETURN NULL; -- prevent borrowing
  ELSE
    RETURN NEW;  -- allow borrowing
  END IF;
END;
$$ LANGUAGE plpgsql;


-- Q1a Invocation
SELECT borrow_book_func ('awong007@msn.com', '978-0470170526',
  CURRENT_DATE);
SELECT borrow_book_func ('awong007@msn.com', '978-0470170526',
  CURRENT_DATE);
SELECT borrow_book_func ('awong007@msn.com', '978-0470170526',
  CURRENT_DATE);


-- Q1a Trigger
CREATE TRIGGER enforce_local_loan_limit_insert
BEFORE INSERT ON loan
FOR EACH ROW EXECUTE FUNCTION check_local_loan_limit();


-- Q1a DROP TRIGGER
DROP TRIGGER enforce_local_loan_limit_insert ON loan;
DROP FUNCTION check_local_loan_limit();


-- Q1b Stored Procedure
CREATE OR REPLACE PROCEDURE borrow_book_proc (
  borrower_email VARCHAR (256), isbn13 CHAR (14), borrow_date DATE
) AS $$
DECLARE
  available_copy RECORD;
BEGIN
  -- Check for a copy of the book that is not currently borrowed
  --   (i.e., no active loan)
  SELECT * INTO available_copy
  FROM copy c
  WHERE c.book = isbn13
    AND NOT EXISTS (
      SELECT 1 FROM loan l
      WHERE l.book = c.book
        AND l.copy = c.copy
        AND l.owner = c.owner
        AND l.returned ISNULL
    )
  LIMIT 1;

  IF NOT FOUND -- No available copy found, raise notice
  THEN
    RAISE NOTICE 'No available copies of the book with ISBN13 : %',
      isbn13;
    RETURN;
  ELSE -- An available copy found
    -- Insert a new record into the loan table to record the borrowing
    INSERT INTO loan (borrower, owner, book, copy, borrowed)
    VALUES (borrower_email, available_copy.owner,
      available_copy.book, available_copy.copy, borrow_date);
    -- Raise a success message
    RAISE NOTICE 'Book with ISBN13 : % has been successfully 
      borrowed by %', isbn13, borrower_email;
  END IF;
END;
$$ LANGUAGE plpgsql;


-- Q1b Invocation
CALL borrow_book_proc ('awong007@msn.com', '978-0470089156',
  CURRENT_DATE);
CALL borrow_book_proc ('awong007@msn.com', '978-0470089156',
  CURRENT_DATE);
CALL borrow_book_proc ('awong007@msn.com', '978-0470089156',
  CURRENT_DATE);
CALL borrow_book_proc ('awong007@msn.com', '978-0470089156',
  CURRENT_DATE);



-- Q1b Trigger Function
CREATE OR REPLACE FUNCTION check_global_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  violating_student RECORD;
BEGIN
  -- Check if there is any student with more than 6 active loans
  SELECT l.borrower INTO violating_student
  FROM loan l
  WHERE l.returned ISNULL
  GROUP BY l.borrower
  HAVING COUNT(*) > 6;

  IF violating_student IS NOT NULL
  THEN -- There is a violation, raise exception
    RAISE EXCEPTION '% has borrowed more than 6 books',
      violating_student;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;



-- Q1b Trigger
CREATE TRIGGER enforce_global_loan_limit
AFTER INSERT OR UPDATE ON loan
FOR EACH ROW EXECUTE FUNCTION check_global_loan_limit();


-- Q2 Simple Test
CALL borrow_book_proc('awong007@msn.com', '978-1449389673',
  CURRENT_DATE);


-- Q1b DROP TRIGGER
DROP TRIGGER enforce_global_loan_limit ON loan;
DROP FUNCTION check_global_loan_limit();


-- Q2a Trigger Function
CREATE OR REPLACE FUNCTION check_local_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  active_loan_count INT;
BEGIN
  -- Count the number of active loans (not yet returned)
  SELECT COUNT(*) INTO active_loan_count
  FROM loan l
  WHERE l.borrower = NEW.borrower
    AND l.returned ISNULL;
  
  IF active_loan_count >= 6
  THEN
    RETURN NULL; -- prevent borrowing
  ELSE
    RETURN NEW;  -- allow borrowing
  END IF;
END;
$$ LANGUAGE plpgsql;


-- Q1 DROP SCHEMA
-- change `public` to the name of your schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


-- Q2a Trigger
CREATE TRIGGER enforce_local_loan_limit_insert
BEFORE INSERT ON loan
FOR EACH ROW EXECUTE FUNCTION check_local_loan_limit();


-- Q2a DROP TRIGGER
DROP TRIGGER enforce_local_loan_limit_insert ON loan;
DROP FUNCTION check_local_loan_limit();


-- Q2b Trigger Function
CREATE OR REPLACE FUNCTION check_global_loan_limit()
RETURNS TRIGGER AS $$
DECLARE
  violating_student RECORD;
BEGIN
  -- Check if there is any student with more than 6 active loans
  SELECT l.borrower INTO violating_student
  FROM loan l
  WHERE l.returned ISNULL
  GROUP BY l.borrower
  HAVING COUNT(*) > 6;

  IF violating_student IS NOT NULL
  THEN -- There is a violation, raise exception
    RAISE EXCEPTION '% has borrowed more than 6 books',
      violating_student;
  ELSE
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;



-- Q2b Trigger
CREATE TRIGGER enforce_global_loan_limit
AFTER INSERT OR UPDATE ON loan
FOR EACH ROW EXECUTE FUNCTION check_global_loan_limit();


-- Q2b DROP TRIGGER
DROP TRIGGER enforce_global_loan_limit ON loan;
DROP FUNCTION check_global_loan_limit();


-- Q2 DROP SCHEMA
-- change `public` to the name of your schema
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;


