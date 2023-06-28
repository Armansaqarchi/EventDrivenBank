CREATE TABLE IF NOT EXISTS latest_balances(
    accountNumber NUMERIC(16, 0) REFERENCES account(accountNumber),
    amount NUMERIC(18, 0)
);

