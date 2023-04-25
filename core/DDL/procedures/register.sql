CREATE OR REPLACE PROCEDURE register(accountNumber NUMERIC(16, 0), password VARCHAR(60),
firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type STATUS, interest_rate INT)
AS $$
    DECLARE hashed_password VARCHAR(60);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            SET hashed_password encode(DIGEST(password, 'sha256'), 'hex')
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, interest_rate)
            VALUES(accountNumber, password, firstname. lastname, nationalID, birth_of_date, interest_rate);
    END;
$$ LANGUAGE plpgsql 


        
