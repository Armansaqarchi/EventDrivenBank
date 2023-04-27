--takes account information, and creates the accoun
--after the creation is done, a trigger called 'make_username' is called to resolve the username 
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



--this function adds the logged in username to the login log table
CREATE FUNCTION login_log(username VARCHAR(50))
AS $$
    BEGIN
    INSERT INTO TABLE login_log VALUES (username, CURRENT_TIMESTAMP)
    END;





--takes username and password, hashes the password and then if anything matched these two, loggin is done.
CREATE OR REPLACE PROCEDURE Login(username VARCHAR(50), password VARCHAR(50))
AS $$
    --declare a vatiable used to store hashed password
    DECLARE hashed_password VARCHAR(50);
    BEGIN
        hashed_password := DIGEST(password, 'sha256');
        IF EXISTS(SELECT * FROM account WHERE username = username AND password = hashed_password) THEN
            EXECUTE --function
            RETURN "successfully logged in"

    END;
$$ LANGUAGE plpgsql





--creates a procedure responsible to make deposit events
CREATE OF REPLACE PROCEDURE deposit(amount NUMERIC(18, 0), type STATUS)
AS $$
    
    DECLARE transaction_time TIMESTAMP;
    DECLARE username VARCHAR(50);
    BEGIN
        username = SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1;
        transaction_time := CURRENT_TIMESTAMP;
        IF type = 'deposit' THEN
            -- do deposit things
        ELSE IF type = 'withdraw' THEN
            --do withdraw things
        ELSE IF type = 'transfer' THEN
            -- do transfer things
        ELSE IF type = 'interest_payment' THEN
            -- do interst payment things
    END;
$$ LANGUAGE plpgsql
