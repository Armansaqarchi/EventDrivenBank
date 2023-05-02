--takes account information, and creates the accoun
--after the creation is done, a trigger called 'make_username' is called to resolve the username 
CREATE OR REPLACE PROCEDURE Register(accountNumber NUMERIC(16, 0), password VARCHAR(60),
firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type USER_STATUS, interest_rate INT)
AS $$
    DECLARE hashed_password VARCHAR(60);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            hashed_password := DIGEST(password, 'sha256');
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, type, interest_rate)
            VALUES(accountNumber, hashed_password, firstname, lastname, nationalID, birth_of_date, type, interest_rate);
            RETURN 'user successfully created, username : ' || username;
        END IF;
    END;
$$ LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------


--this function adds the logged in username to the login log table
CREATE FUNCTION login_log(username VARCHAR(50))
AS $$
    BEGIN
    INSERT INTO TABLE login_log VALUES (username, CURRENT_TIMESTAMP)
    END;


--------------------------------------------------------------------------------------------------------------


--takes username and password, hashes the password and then if anything matched these two, loggin is done.
CREATE OR REPLACE PROCEDURE Login(username VARCHAR(50), password VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE hashed_password TEXT;
BEGIN
    hashed_password := digest(password, 'sha256');
    IF EXISTS(SELECT * FROM account WHERE username = username AND password = hashed_password) THEN
        -- Call your function here to do something if the login is successful
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;


------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE user_exists(username VARCHAR)
AS $$
    BEGIN
        --checks if the user exists
        RETURN SELECT EXISTS (SELECT * FROM account WHERE username = username);
    END;
$$ LANGUAGE plpgsql

------------------------------------------------------------------------------------------------------------------

-- creates the event based on the type passed as argument
CREATE OF REPLACE PROCEDURE make_transaction(amount NUMERIC(18, 0), type STATUS, to VARCHAR(50))
AS $$
    
    DECLARE transaction_time TIMESTAMP;
    DECLARE username VARCHAR(50);
    DECLARE from VARCHAR(50);
    DECLARE to VARCHAR(50);
    BEGIN
        username = SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1;
        transaction_time := CURRENT_TIMESTAMP;

        IF to <> NULL THEN
            --check username exists
            IF NOT EXISTS EXECUTE user_exists(to) THEN
                RETURN FALSE;
        END IF;

        IF type = 'deposit' OR type = 'interest_payment' THEN
            --do deposit things
            from := NULL;
            to := username;
        ELSE IF type = 'withdraw' THEN
            --do withdraw things
            from := username;
            to := NULL;
        ELSE IF type = 'transfer' THEN
            -- do transfer things
            from := username;
            to := to;
        END IF;

        EXECUTE create_transaction(type, from, to, amount)
        RETURN TRUE;
    END;
$$ LANGUAGE plpgsql

------------------------------------------------------------------------------------------------------------------

-- returns the account balance based on last account logged in
CREATE OR REPLACE PROCEDURE check_balance()
AS $$
    DECLARE username VARCHAR(50);
    DECLARE accountNumber VARCHAR(50);
    BEGIN
        --getting last login-log username
        username := SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1;
        accountNumber = SELECT accountNumber FROM account WHERE username = username
        RETURN SELECT amount FROM latest_balances WHERE accountNumber = accountNumber 
    END;
$$ LANGUAGE plpgsql

------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION do_transaction(event ROW) RETURNS BOOLEAN
AS $$
    DECLARE
    record ROW;

    BEGIN

        IF event.type = 'deposit' THEN
            --update deposit
            UPDATE latest_balances SET amount = amount + event.amount WHERE accountNumber = event.to

        -----------------------------------
        ELSE IF event.type = 'withdraw' THEN
            --update deposit
            IF event.amount > SELECT amount FROM latest_balances WHERE accountNumber = event.to THEN
                record := SELECT * FROM account WHERE accountNumber = event.to;
                IF record.type = 'client' THEN
                    RETURN 'failed to complete transaction, account balance insufficient';
                
                -- according to instructions, transactions will be executed for employees anywhere
                UPDATE latest_balances SET amount = amount - event.amount WHERE accountNumber = record.accountNumber;
                END IF;
            END IF;
        ------------------------------------
        ELSE IF event.type = 'interest_payment' THEN
            --update deposit
            record := SELECT * FROM account WHERE accountNumber = event.to;
            IF record.type = 'employee' THEN
                RETURN;
            END IF;
            UPDATE latest_balances SET amount = amount*record.interest_rate;
        ------------------------------------
        ELSE IF event.type = 'transfer' THEN
            --update deposit
            record = SELECT * FROM latest_balances WHERE accountNumber = event.accountNumber;
            IF record.amount < event.amount THEN
                UPDATE latest_balances SET amount = amount + event.amount WHERE accountNumber = event.to;
                UPDATE latest_balances SET amoutn = amount - event.amount WHERE accountNumber = event.from;
                RETURN TRUE;
            RETURN FALSE;
            END IF;
        END IF;
        ------------------------------------
    END;


$$ LANGUAGE plpgsql

-----------------------------------------------------------------------------------------------------------------


-- updates all the events occured after the last snapshot
-- takes the events first, in descending order
-- executes every one of them
-- this architecture may cause performance optimization,
-- but it would be better to store these events in somewhere in ram
-- like most of the dedicated libraries do (e.g kafka)
CREATE OR REPLACE PROCEDURE update_balance()
AS $$
    DECLARE least_timestamp VARCHAR(50);
    events REFCURSOR;
    record ROW;

    BEGIN
        least_timestamp := SELECT snapshot_timestamp FROM snapshot_log ORDER BY snapshot_timestamp DESC LIMIT 1;
        -- reference to the first tuple in events
        OPEN events FOR SELECT * FROM transaction WHERE transaction_time > least_timestamp ORDER BY transaction_time ASC
        LOOP
            FETCH events INTO record;
            -- leaves the loop if no row is available
            EXIT WHEN NOT FOUND;

            EXECUTE do_transaction(record)



            END IF;
        END LOOP;

        -- free space in ram
        CLOSE events;
        RETURN TRUE
    END;
$$ LANGUAGE plpgsql

-------------------------------------------------------------------------------------------------------------

--creates a new table whose name is snapshot_id which id depends on the numbers updates balance been called
CREATE OR REPLACE PROCEDURE create_snapshot(id VARCHAR(50))
AS $$
    BEGIN
        EXECUTE 'CREATE TABLE snapshot_' || id ||'(account_number VARCHAR(16), amount int)';
        EXECUTE 'INSERT INTO snapshot_' || id || '(account_number VARCHAR(16), amount int) VALUES SELECT * FROM latest_balances'
        EXCEPTION
            WHEN others THEN
                RAISE NOTICE 'there is something wrong with creating snapshot_id table : %s' SQLERRM;
        RETURNS TRUE
    END;

$$ LANGUAGE plpgsql
