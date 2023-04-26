CREATE TABLE IF NOT EXISTS latest_balances(
    accountNumber INTEGER REFERENCES account(accountNumber),
    amount NUMERIC(18, 0)
);

