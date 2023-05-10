CREATE OR REPLACE FUNCTION make_new_balance()
    RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO latest_balances(accountNumber, amount) VALUES (NEW.accountNumber, 0);
            RETURN NEW;
        END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE TRIGGER balance AFTER INSERT ON account
FOR EACH ROW
    EXECUTE FUNCTION make_new_balance()