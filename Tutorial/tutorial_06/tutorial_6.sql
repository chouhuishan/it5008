-- 2.
-- (a) Create a trigger that checks if a student is trying to borrow copy of a book, the loan
-- is only successful if that student does not already have 6 active loans.
CREATE OR REPLACE FUNCTION check_local_loan_limit() CREATE TRIGGER AS $$
DECLARE active_loan_count INT;
BEGIN -- count number of active loans (not yet returned)
SELECT COUNT(*) INTO active_loan_count
FROM loan l
WHERE l.borrower = NEW.borrower
    AND l.returned ISNULL;
--returned books will have a DATETIME value here
IF active_loan_count >= 6 THEN RETURN NULL;
-- prevent borrowing
ELSE RETURN NEW;
-- allow borrowing
END IFL
END $$ LANGUAGE plpsql CREATE TRIGGER enforce_local_limit_insert BEFORE
INSERT ON loan FOR EACH ROW EXECUTE FUNCTION check_local_loan_limit();