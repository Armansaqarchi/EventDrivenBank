-- a procedure which simply takes parameters and create a transaction
CREATE OR REPLACE PROCEDURE public.create_transaction(
	IN type status,
	IN from_who numeric,
	IN to_who numeric,
	IN amount numeric)
LANGUAGE 'plpgsql'
AS $BODY$
    BEGIN
        INSERT INTO transactions(type, from_account, to_account, amount) VALUES (type, from_who, to_who, amount);
    END;
$BODY$;