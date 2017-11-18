#! /usr/bin/python
import cgi
import requests
import json

def schedule(username="", data=""):
    form = cgi.FieldStorage() 
    if not username:
        username = form.getvalue('username')
    if not username:
        raise Exception("ERROR: No username provided")
    if not data:
        data = form.getvalue('data')
    if not data:
        resp = requests.get('https://antplanner.appspot.com/schedule/load', params={'username': username})
        try:
            resp = resp.json()
            if resp['success'] == True:
                js = resp['data']
                print(js)
            else:
                raise Exception('No data found for username ' + username)
        except Exception as e:
            print('ERROR: Unable to load schedule')
    else:
        resp = requests.post('https://antplanner.appspot.com/schedules/add', data={'username': username, 'data': data})
        try:
            resp = resp.json()
            if (not resp['success']):
                raise Exception('Unable to save schedule for ' + username)
        except Exception as e:
            print('ERROR: Unable to save schedule')
try:
    print("Content-type: text/html\r\n\r\n")
    schedule()
except Exception as e:
    print("ERROR: " + str(e))
