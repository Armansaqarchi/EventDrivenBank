--takes account information, and creates the accoun
--after the creation is done, a trigger called 'make_username' is called to resolve the username 

CREATE OR REPLACE PROCEDURE public.register(
	IN accountnumber numeric,
	IN password character varying,
	IN firstname character varying,
	IN lastname character varying,
	IN nationalid numeric,
	IN birth_of_date date,
	IN type user_status,
	IN interest_rate double precision,
	OUT out_value character varying)
LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE hashed_password VARCHAR(500);
    BEGIN
        IF EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birth_of_date) > 13 THEN
            hashed_password = digest(password, 'sha256');
            INSERT INTO account(accountNumber, password, firstname, lastname, nationalID, birth_of_date, type, interest_rate)
            VALUES(accountNumber, hashed_password, firstname, lastname, nationalID, birth_of_date, type, interest_rate);
            out_value := 'True, successfully registered';
            RETURN;
        END IF;
        out_value := 'False, you are not permitted to register as your age is under than 13';
    END;
$BODY$;


-------------------------------------------------------------------------------------------------------------


--this function adds the logged in username to the login log table
CREATE OR REPLACE FUNCTION public.login_log(
	username character varying)
    RETURNS boolean
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
    BEGIN
    INSERT INTO login_log VALUES (username, CURRENT_TIMESTAMP);
	RETURN TRUE;
--     EXCEPTION 
--     WHEN others THEN
-- 		RAISE NOTICE 'error : %', SQLERRM;
--         RETURN FALSE;
END;
$BODY$;


--------------------------------------------------------------------------------------------------------------


--takes username and password, hashes the password and then if anything matched these two, loggin is done.
CREATE OR REPLACE PROCEDURE public.login(
	IN login_username character varying,
	IN login_password character varying,
	OUT result character varying)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE 
    hashed_password TEXT;
	declare login_log_res boolean;
BEGIN
    hashed_password = digest(login_password, 'sha256');
    IF EXISTS(SELECT * FROM account WHERE account.username = login_username AND password = hashed_password) THEN
        -- Call your function here to do something if the login is successful
        result := 'True, login successful!';
        SELECT login_log(login_username) INTO login_log_res;
		IF login_log_res = TRUE THEN
			RETURN;
		ELSE 
			result := 'something went wrong during authentication';
			RETURN;
		END IF;
    ELSE
        result := 'False, username or password may be incorrect';
    END IF;
END;
$BODY$;


------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE PROCEDURE public.user_exists(
	IN accountnumber character varying,
	OUT user_exists boolean)
LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
        --checks if the user exists
        EXECUTE 'SELECT EXISTS (SELECT * FROM account WHERE accountNumber = accountNumber)' INTO user_exists using accountNumber;
        RETURN;
    END;
$BODY$;

------------------------------------------------------------------------------------------------------------------

-- creates the event based on the type passed as argument
CREATE OR REPLACE PROCEDURE public.make_transaction(
	IN amount numeric,
	IN type status,
	IN to_who numeric,
	OUT out_value character varying)
LANGUAGE 'plpgsql'
AS $BODY$
    
    DECLARE transaction_time TIMESTAMP;
    account_username VARCHAR(50);
	username_number numeric(16, 0);
    from_who NUMERIC(16,0);
    recipient VARCHAR(50);
    user_exist BOOLEAN;
    
    BEGIN
        EXECUTE 'SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1' INTO account_username;
        transaction_time := CURRENT_TIMESTAMP;

		IF account_username IS NOT NULL THEN

			select accountNumber INTO username_number from account where username = account_username;
			raise notice '%s4324', username_number;
		END IF;
		
		

        IF to_who <> NULL THEN
            --check username exists
            EXECUTE user_exists(to_who, user_exist);
            if NOT EXISTS user_exist THEN
                out_value := 'user does not exist';
                RETURN;
            END IF;
        END IF;

        IF type = 'deposit' OR type = 'interest' THEN
            --do deposit things
            from_who := NULL;
            recipient := username_number;
        ELSEIF type = 'withdraw' THEN
            --do withdraw things
            from_who := username_number;
            recipient := NULL;
        ELSEIF type = 'transfer' THEN
            -- do transfer things
            from_who := username_number;
            recipient := to_who;
        END IF;

        CALL create_transaction(type::status, from_who::numeric, recipient::numeric, amount::numeric);
        out_value := 'transaction successfully completed';
        RETURN;
-- 		EXCEPTION
-- 		WHEN OTHERS THEN
-- 			out_value := 'something went wrong during process'
-- 			RETURN;
    END;
$BODY$;

------------------------------------------------------------------------------------------------------------------

-- returns the account balance based on last account logged in
CREATE OR REPLACE PROCEDURE public.check_balance(
	OUT balance integer)
LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE username VARCHAR(50);
    DECLARE accountNumber numeric(16, 0);
    BEGIN
        --getting last login-log username
        EXECUTE 'SELECT username FROM login_log ORDER BY login_time DESC LIMIT 1' INTO username;
        EXECUTE format('SELECT accountNumber FROM account WHERE username = %L', username) INTO accountNumber;
        EXECUTE format('SELECT amount FROM latest_balances WHERE accountNumber = %L', accountNumber) INTO balance;
		raise notice '%s', username;
		raise notice '%s', balance;
		raise notice '%s', accountNumber;
    END;
$BODY$;

------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION public.do_transaction(
	type character varying,
	from_account numeric,
	to_account numeric,
	event_amount numeric)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
    declare balance BIGINT;

    BEGIN
        IF type = 'deposit' THEN
            --update deposit
            UPDATE latest_balances SET amount = event_amount + amount WHERE accountNumber = to_account;
        -----------------------------------
        ELSEIF type = 'withdraw' THEN
            --update deposit
            EXECUTE format('SELECT amount from latest_balances WHERE accountNumber = %s', from_account) INTO balance;
            IF event_amount > balance THEN
                IF type = 'CLIENT' THEN
                    RETURN;
                
                -- according to instructions, transactions will be executed for employees anywhere
                UPDATE latest_balances SET amount = amount - event_amount WHERE accountNumber = from_account;
                END IF;
            END IF;
        ------------------------------------
        ELSEIF type = 'interest_payment' THEN
            --update deposit
            IF type = 'EMPLOYEE' THEN
                RETURN;
            END IF;
            UPDATE latest_balances SET amount = amount*1.05 WHERE accountNumber = to_account;
        ------------------------------------
        ELSEIF type = 'transfer' THEN
            --update deposit
            EXECUTE format('SELECT amount FROM latest_balances WHERE accountNumber = %s', from_account) INTO balance;
            IF balance > event_amount THEN
                UPDATE latest_balances SET amount = amount + event_amount WHERE accountNumber = to_account;
                UPDATE latest_balances SET amount = amount - event_amount WHERE accountNumber = from_account;
                RETURN;
            RETURN;
            END IF;
		ELSE
			RETURN;
        END IF;
	RAISE NOTICE 'found!';
		RETURN;
        ------------------------------------
    END;
$BODY$;

-----------------------------------------------------------------------------------------------------------------



CREATE TYPE public.transaction_type AS
(
	type character varying(20),
	from_account character varying(50),
	to_account character varying(50),
	amount numeric(16,0),
	transaction_time timestamp without time zone
);

-- updates all the events occured after the last snapshot
-- takes the events first, in descending order
-- executes every one of them
-- this architecture may cause performance optimization,
-- but it would be better to store these events in somewhere in ram
-- like most of the dedicated libraries do (e.g kafka)
CREATE OR REPLACE PROCEDURE public.update_balance(
	OUT out_value boolean)
LANGUAGE 'plpgsql'
AS $BODY$
    DECLARE least_timestamp timestamp;
    events REFCURSOR;
    record transaction_type;
	snapshot_created boolean;

    BEGIN
        EXECUTE 'SELECT snapshot_timestamp FROM snapshot_log ORDER BY snapshot_timestamp DESC LIMIT 1' INTO least_timestamp;
        -- reference to the first tuple in events
		IF least_timestamp IS NULL THEN
			least_timestamp := '2000-05-12 07:49:26.689';
		END IF;
        FOR record in SELECT type, from_account, to_account, amount, transaction_time FROM transactions WHERE transaction_time > least_timestamp ORDER BY transaction_time ASC
        LOOP
            EXECUTE do_transaction(record.type::VARCHAR, record.from_account::NUMERIC, record.to_account::NUMERIC, record.amount::NUMERIC);
            
        END LOOP;

        -- free space in ram
        out_value := TRUE;
		snapshot_created = FALSE;
		CALL create_snapshot(snapshot_created::boolean);
		IF snapshot_created = TRUE THEN
			RETURN;
		ELSE 
		ROLLBACK;
		
        END IF;
-- 		EXCEPTION 
-- 		WHEN OTHERS THEN
-- 			out_value := FALSE;
-- 			RETURN;

    END;
$BODY$;

-------------------------------------------------------------------------------------------------------------

--creates a new table whose name is snapshot_id which id depends on the numbers updates balance been called
CREATE OR REPLACE PROCEDURE public.create_snapshot(
	OUT out_value boolean)
LANGUAGE 'plpgsql'
AS $BODY$
	DECLARE 
	temp_id numeric(16, 0);
	table_name varchar(15);
    BEGIN
		select nextval('snapshot_id') into temp_id;
		table_name := 'snapshot_' || temp_id;
        EXECUTE format('CREATE TABLE %I (account_number varchar, amount int)', table_name);
        EXECUTE format('INSERT INTO %I(account_number, amount) SELECT * FROM latest_balances', table_name);
		INSERT INTO snapshot_log VALUES (temp_id, CURRENT_TIMESTAMP);
		out_value := TRUE;
		RETURN;
        EXCEPTION
            WHEN others THEN
                RAISE NOTICE 'there is something wrong with creating snapshot_id table';
				out_value := FALSE;
        RETURN;
    END;
$BODY$;
