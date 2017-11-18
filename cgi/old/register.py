#! /usr/bin/python
import cgi
from webreg import WebRegSession


def make_html():
    form = cgi.FieldStorage() 
    ucinetid = form.getvalue('ucinetid')
    if not ucinetid:
        raise Exception("No ucinetid provided")
    
    password = form.getvalue('password')
    if not password:
        raise Exception("No password provided")    
    
    auth = WebRegSession()
    
    if form.getvalue('submit') == 'Study List':
        auth.webreg(ucinetid, password, studyList=True)
    else:
        data = {k: form.getvalue(k) for k in ['mode', 'courseCodes', 'gradeOption', 'varUnits', 'authCode'] if k in form.keys()}
        data["courseCodes"] = data["courseCodes"].strip().split(' ')
        auth.webreg(ucinetid, password, webreg_data=data)


try:
    print('Content-type: text/html\r\n\r\n')
    make_html()
except Exception as e:
    print(str(e))
