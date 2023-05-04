--takes account information, and creates the accoun
--after the creation is done, a trigger called 'make_username' is called to resolve the username 
CREATE OR REPLACE PROCEDURE Register(accountNumber NUMERIC(16, 0), password VARCHAR(60),
firstname VARCHAR(60), lastname VARCHAR(60), nationalID NUMERIC(10, 0), birth_of_date DATE, type USER_STATUS, interest_rate INT, OUT out_value BOOLEAN)
AS $$
    DECLARE hashed_password VARCHAR(60);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            hashed_password := DIGEST(password, 'sha256');
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, type, interest_rate)
            VALUES(accountNumber, hashed_password, firstname, lastname, nationalID, birth_of_date, type, interest_rate);
            out_value := TRUE
            RETURN;
        END IF;
    END;
$$ LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------------


--this function adds the logged in username to the login log table
CREATE FUNCTION login_log(username VARCHAR(50))
    RETURNS BOOLEAN
AS $$
    BEGIN
    INSERT INTO login_log VALUES (username, CURRENT_TIMESTAMP);
    EXCEPTION 
    WHEN others THEN
        RETURN FALSE;
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


--------------------------------------------------------------------------------------------------------------


--takes username and password, hashes the password and then if anything matched these two, loggin is done.
CREATE OR REPLACE PROCEDURE Login(IN username VARCHAR(50), IN password VARCHAR(50), OUT result BOOLEAN)
LANGUAGE plpgsql
AS $$
DECLARE 
    hashed_password TEXT;
BEGIN
    hashed_password := digest(password, 'sha256');
    IF EXISTS(SELECT * FROM account WHERE username = username AND password = hashed_password) THEN
        -- Call your function here to do something if the login is successful
        result := TRUE;
        RETURN;
    ELSE
        result := FALSE;
        RAISE NOTICE 'username or password is incorrect';
    END IF;
END;
$$;


------------------------------------------------------------------------------------------------------------------


CREATE PROCEDURE user_exists(IN username VARCHAR, OUT user_exists BOOLEAN)
LANGUAGE plpgsql
AS $$
    BEGIN
        --checks if the user exists
        EXECUTE 'SELECT EXISTS (SELECT * FROM account WHERE username = username)' INTO user_exists using username;
        RETURN;
    END;
$$;

------------------------------------------------------------------------------------------------------------------

-- creates the event based on the type passed as argument
CREATE OR REPLACE PROCEDURE make_transaction(IN amount NUMERIC(18, 0),IN type STATUS,IN to_who VARCHAR(50), OUT out_value BOOLEAN)
LANGUAGE plpgsql
AS $$
    
    DECLARE transaction_time TIMESTAMP;
    username VARCHAR(50);
    from_who VARCHAR(50);
    recipient VARCHAR(50);
    user_exist BOOLEAN;
    
    BEGIN
        EXECUTE 'SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1' INTO username;
        transaction_time := CURRENT_TIMESTAMP;

        IF to_who <> NULL THEN
            --check username exists
            EXECUTE user_exists(to_who, user_exist);
            if NOT EXISTS user_exist THEN
                out_value := FALSE;
                RETURN;
            END IF;
        END IF;

        IF type = 'deposit' OR type = 'interest_payment' THEN
            --do deposit things
            from_who := NULL;
            recipient := username;
        ELSEIF type = 'withdraw' THEN
            --do withdraw things
            from_who := username;
            recipient := NULL;
        ELSEIF type = 'transfer' THEN
            -- do transfer things
            from_who := username;
            recipient := to_who;
        END IF;

        EXECUTE create_transaction(type, from_who, recipient, amount);
        out_value := TRUE;
        RETURN;
    END;
$$;

------------------------------------------------------------------------------------------------------------------

-- returns the account balance based on last account logged in
CREATE OR REPLACE PROCEDURE check_balance(OUT balance int)
LANGUAGE plpgsql
AS $$
    DECLARE username VARCHAR(50);
    DECLARE accountNumber VARCHAR(50);
    BEGIN
        --getting last login-log username
        EXECUTE 'SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1' INTO username;
        EXECUTE 'SELECT accountNumber FROM account WHERE username = username' INTO accountNumber;
        EXECUTE 'SELECT amount FROM latest_balances WHERE accountNumber = accountNumber' INTO balance;
    END;
$$;

------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION do_transaction(type VARCHAR(50), from_who VARCHAR(50), to_who VARCHAR(50), event_amount int) RETURNS BOOLEAN
AS $$
    declare balance BIGINT;

    BEGIN
        IF type = 'deposit' THEN
            --update deposit
            UPDATE latest_balances SET amount = event_amount + amount WHERE accountNumber = to_who;
            IF ROW_COUNT = 0 THEN
                RETURN FALSE;
            RETURN TRUE;
            END IF;

        -----------------------------------
        ELSEIF type = 'withdraw' THEN
            --update deposit
            EXECUTE 'SELECT amount from latest_balances WHERE accountNumber = from_who' INTO balance USING from_who;
            IF event_amount > balance THEN
                IF type = 'client' THEN
                    RETURN FALSE;
                
                -- according to instructions, transactions will be executed for employees anywhere
                UPDATE latest_balances SET amount = amount - event_amount WHERE accountNumber = from_who;
                END IF;
            END IF;
        ------------------------------------
        ELSEIF type = 'interest_payment' THEN
            --update deposit
            IF type = 'employee' THEN
                RETURN FALSE;
            END IF;
            UPDATE latest_balances SET amount = amount*0.05 WHERE accountNumber = to_who;
        ------------------------------------
        ELSEIF type = 'transfer' THEN
            --update deposit
            EXECUTE 'SELECT balance FROM latest_balances WHERE accountNumber = from' INTO balance USING from_who;
            IF balance > event_amount THEN
                UPDATE latest_balances SET amount = amount + event_amount WHERE accountNumber = to_who;
                UPDATE latest_balances SET amoutn = amount - event_amount WHERE accountNumber = from_who;
                RETURN TRUE;
            RETURN FALSE;
            END IF;
        END IF;
        ------------------------------------
    END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------------------------------------------------------



CREATE TYPE transaction_type as (
    type VARCHAR(20),
    from_who VARCHAR(17),
    to_who VARCHAR(17),
    amount VARCHAR(17)
);

-- updates all the events occured after the last snapshot
-- takes the events first, in descending order
-- executes every one of them
-- this architecture may cause performance optimization,
-- but it would be better to store these events in somewhere in ram
-- like most of the dedicated libraries do (e.g kafka)
CREATE OR REPLACE PROCEDURE update_balance(OUT out_value VARCHAR(50))
LANGUAGE plpgsql
AS $$
    DECLARE least_timestamp VARCHAR(50);
    events REFCURSOR;
    record transaction_type;


    BEGIN
        EXECUTE 'SELECT snapshot_timestamp FROM snapshot_log ORDER BY snapshot_timestamp DESC LIMIT 1' INTO least_timestamp;
        -- reference to the first tuple in events
        OPEN events FOR SELECT * FROM transaction WHERE transaction_time > least_timestamp ORDER BY transaction_time ASC;
        LOOP
            FETCH events INTO record;
            -- leaves the loop if no row is available
            EXIT WHEN NOT FOUND;

            EXECUTE do_transaction(record.type, record.from, record.to, record.amount);
            
        END LOOP;

        -- free space in ram
        CLOSE events;
        out_value := 'successfully updated events';
        RETURN;
    END;
$$;

-------------------------------------------------------------------------------------------------------------

--creates a new table whose name is snapshot_id which id depends on the numbers updates balance been called
CREATE OR REPLACE PROCEDURE create_snapshot(IN id VARCHAR(50),OUT out_value BOOLEAN)
LANGUAGE plpgsql
AS $$
    BEGIN
        EXECUTE 'CREATE TABLE snapshot_' || id ||'(account_number VARCHAR(16), amount int)';
        EXECUTE 'INSERT INTO snapshot_' || id || '(account_number VARCHAR(16), amount int) VALUES SELECT * FROM latest_balances';
        EXCEPTION
            WHEN others THEN
                RAISE NOTICE 'there is something wrong with creating snapshot_id table';
        out_value := TRUE;
        RETURN;
    END;
$$;
