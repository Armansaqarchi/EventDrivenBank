CREATE TABLE IF NOT EXISTS latest_balances(
    accountNumber INTEGER REFERENCES account(accountNumber),
    amount BIGINT
);

