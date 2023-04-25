CREATE TABLE IF NOT EXISTS latest_balances(
    accountNumber INTEGER REFERENCES account(accountNumber),
    amount BIGINT
);


CREATE TRIGGER balance AFTER INSERT ON account FOR EACH ROW
    EXECUTE FUNCTION make_balance();

CREATE OR REPLACE FUNCTION make_balance ()
    RETURNS TRIGGER AS $$
        BEGIN
            INSERT INTO latest_balances(accountNumber, amount) VALUES (NEW.accountNumber, NEW.amount)
            RETURN NEW;
        END;
$$ LANGUAGE plpgsql;