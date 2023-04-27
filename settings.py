from os import path
from pathlib import Path


# database configuration


# project directory
BASE_DIR = Path(__file__).resolve().parent


db = {
    "DB_ADAPTER" : "psychopg2",
    "HOST" : "127.0.0.1",
    "DATABASE" : "event_driven",
    "PORT" : "5432",
    "USER" : "mahan",
    "PASSWORD" : "test123123"
}



LOGGING = {
    "level" : "logging.INFO"
}


DDL_PATH = path.join(BASE_DIR, "core/DDL")

MAIN_MENU = ('Withdraw', 'Transfer', 'Exit')

LOGIN_MENU = ('Login', 'Register', "Quit")

EPMLOYEE_MAIN_MENU =('Deposit', 'Interest_payment', 'Exit')
