CREATE TABLE IF NOT EXISTS login_log (
    username VARCHAR(60),
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)