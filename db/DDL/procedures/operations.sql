CREATE OR REPLACE PROCEDURE Register(accountNumber NUMERIC(16, 0), password VARCHAR(60),
firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type STATUS, interest_rate INT)
AS $$
    DECLARE hashed_password VARCHAR(60);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            hashed_password := DIGEST(password, 'sha256');
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, interest_rate)
            VALUES(accountNumber, hashed_password, firstname, lastname, nationalID, birth_of_date, interest_rate);
            RETURN 'user successfully created, username : ' || username;
        END IF;
    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE PROCEDURE Login(username VARCHAR(50), password VARCHAR(50))
AS $$
    DECLARE hashed_password VARCHAR(50);
    BEGIN
        hashed_password := DIGEST(password, 'sha256');
        IF EXISTS(SELECT * FROM account WHERE username = username AND password = hashed_password);

    END;
$$ LANGUAGE plpgsql