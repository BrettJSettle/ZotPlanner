#! /usr/bin/python
import cgi
import sqlite3

def createTable(con):
    cur = con.cursor()
    sql = 'CREATE TABLE IF NOT EXISTS schedules (username STRING, schedule STRING)'
    cur.execute(sql)
    con.commit()

def schedule(username="", data=""):
    form = cgi.FieldStorage() 
    if not username:
        username = form.getvalue('username')
    if not username:
        raise Exception("ERROR: No ucinetid provided")
    con = sqlite3.connect("schedule.db")
    createTable(con)
    
    if not data:
        data = form.getvalue('data')
    if not data:
        cur = con.cursor()
        cur.execute('SELECT schedule from schedules where username = "%s"' % username)
        vals = cur.fetchall()
        if vals:
            print(vals[0][0])
        else:
            print("ERROR: Not found")
    else:
        cur = con.cursor()
        cur.execute("DELETE FROM schedules WHERE username = '%s'" % username)
        cur.execute("INSERT INTO schedules(username, schedule) VALUES('%s', '%s')" % (username, data))
        con.commit()
    con.close()
try:
    print("Content-type: text/html\r\n\r\n")
    schedule()
except Exception as e:
    print("ERROR: " + str(e))
