CREATE OR REPLACE FUNCTION public.make_new_balance()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
        BEGIN
            INSERT INTO latest_balances(accountNumber, amount) VALUES (NEW.accountNumber, 0);
            RETURN NEW;
        END;
$BODY$;




CREATE OR REPLACE TRIGGER balance AFTER INSERT ON account
FOR EACH ROW
    EXECUTE FUNCTION make_new_balance()