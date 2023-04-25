CREATE TABLE IF NOT EXISTS latest_balances(
    accountNumber INTEGER FOREIGN KEY REFRENCES account(accountNumber),
    amount BIGINT
)