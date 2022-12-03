import psycopg2
import threading

from psycopg2 import Error

con1 = psycopg2.connect(
    dbname="library_db",
    user="postgres",
    password="prostotak4589",
    host="localhost",
    port=5432
)
con2 = psycopg2.connect(
    dbname="library_db",
    user="postgres",
    password="prostotak4589",
    host="localhost",
    port=5432
)

con1.set_session(isolation_level='SERIALIZABLE')
con2.set_session(isolation_level='SERIALIZABLE')


def run(query, values):
    with con1:
        with con1.cursor() as cur:
            try:
                cur.execute(query, values)
                print(values)
            except Exception as e:
                print(e)
                con1.rollback()
                run2(query, values)


def run2(query, values):
    with con2:
        with con2.cursor() as cur:
            try:
                cur.execute(query, values)
                print(values)
            except (Error, Exception) as e:
                print(e)
                con2.rollback()
                run(query, values)


all_query = 'UPDATE book SET price = %s WHERE name = %s'
val1 = (100, 'Отель')
val2 = (200, 'Отель')

th1 = threading.Thread(target=run, args=(all_query, val1, ))
th2 = threading.Thread(target=run2, args=(all_query, val2, ))

th1.start()
th2.start()
th1.join()
th2.join()
