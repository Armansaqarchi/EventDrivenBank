import psycopg2



connection = psycopg2.connect(
    host = "127.0.0.1",
    port = "5432",
    database = "event_driven",
    user = "mahan",
    password = "test123123"
)

cursor = connection.cursor()


cursor.execute("CREATE TABLE test(id int)")