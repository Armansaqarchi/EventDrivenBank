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


DDL_PATH = path.join(BASE_DIR, "core/DDL")
