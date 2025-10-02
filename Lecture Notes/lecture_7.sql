FROM customers c 
WHERE EXTRACT(year from AGE(dob)) < 21
SELECT DISTINCT c.customerid
    WHERE EXTRACT(year from AGE(dob)) < 21