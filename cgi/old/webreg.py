
import sys
import os
import re
from bs4 import BeautifulSoup

if sys.version_info[0] == 2:
    from urllib import urlencode
    from urlparse import urlunsplit
else:
    raw_input = input
    from urllib.parse import urlencode, urlunsplit

from requests import Session
import getpass


class WebRegSession:
    LOGIN_URL = 'https://login.uci.edu/ucinetid/webauth'
    CHECK_URL = 'https://login.uci.edu/ucinetid/webauth_check'
    LOGOUT_URL = 'https://login.uci.edu/ucinetid/webauth_logout'
    DW_URL = "https://www.reg.uci.edu/dgw/IRISLink.cgi?seg=U"
    SA_URL = "https://www.reg.uci.edu/access/student/welcome/"
    REG_URL = "http://webreg2.reg.uci.edu:8889/cgi-bin/wramia"
    WEBREG_REDIRECT = "http://webreg2.reg.uci.edu:8889/cgi-bin/wramia?page=startUp&call="

    USER_AGENT = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36"


    def __init__(self):
        self.session = Session()
        self.session.headers['User-Agent'] = self.USER_AGENT

    @staticmethod
    def checkForMsg(text):
        text = BeautifulSoup(text, 'html.parser')
        err = text.find('div', {'class': 'WebRegErrorMsg'})
        if err and 'in use' in str(err):
            raise InUseException(str(err))
        if err and 'back button' not in str(err):
            raise WebRegMessageException(str(err))

    def webreg(self, ucinetid, password, studyList=False, webreg_data={}):
        self.ucinetid = ucinetid
        # get call number
        res = self.session.get(self.WEBREG_REDIRECT)
        text = res.text
        url = re.search('url=(.*)"', text).groups()[0]
        self.call  = re.search('call=(\d{4})', url).groups()[0]
        
        # login and get auth Token
        data = {'ucinetid': self.ucinetid, 'password': password, 'login_button': 'Login'}
        res = self.session.post(url, data=data)
        self.ucinetid_auth = self.session.cookies['ucinetid_auth']
        
        url = re.search("url=(.*)\"", res.text)
        url = url.groups()[0]
        res = self.session.get(url)
        WebRegSession.checkForMsg(res.text)
        try:
            page = "enrollQtrMenu"
            if webreg_data:
                page = "enrollmentMenu"
                data = {'page': 'enrollQtrMenu', 'mode': 'enrollmentMenu', 'submit': 'Enrollment Menu', 'call': self.call}
                res = self.session.post(self.REG_URL, data=data)
                WebRegSession.checkForMsg(res.text)
                out = ""
                if "courseCodes" in webreg_data:
                    for code in webreg_data["courseCodes"]:
                        data = {k: webreg_data[k] if k in webreg_data else ""  for k in ("mode", "gradeOption", "varUnits", "authCode")}
                        data.update({'page': "enrollmentMenu", "courseCode": code, "call": self.call})
                        res = self.session.post(self.REG_URL, data)
                        soup = BeautifulSoup(res.text, "html.parser")
                        text = soup.find('table', {'class': 'studyList'})
                        if not text:
                            text = soup.find('div', {'class': 'WebRegErrorMsg'})
                        out += '<h1>' + str(code) + '</h1>' + str(text) + "<br>"
                    print(out)

            elif studyList == True:
                data = {'page': 'enrollQtrMenu', 'mode': 'listSchedule', 'submit': 'Study List', 'call': self.call}
                res = self.session.post(self.REG_URL, data=data)
                WebRegSession.checkForMsg(res.text)
                text = BeautifulSoup(res.text, 'html.parser')
                studyList = text.find('table', {'class': 'studyList'})
                if studyList:
                    print(studyList)
                else:
                    return "ERROR: Failed to retrieve studylist."
        except Exception as e:
            print("Webreg request failed. %s" % e)
        data = {"page": page, 'mode': "exit", "submit": "Logout", "call": self.call}
        res = self.session.post(self.REG_URL, data=data)
        soup = BeautifulSoup(res.text, 'html.parser')
        item = soup.find('div', {'class': 'WebRegInfoMsg'})
        if item:
            print(str(item))
        else:
            print(res.text)

        

class WebAuthError(Exception):
    pass
class WebRegMessageException(Exception):
    pass
class InUseException(Exception):
    pass

from getpass import getpass

if __name__ == "__main__":
    w = WebRegSession()
    u = input("ucinetid: ")
    p = getpass()
    w.webreg(u, p, studyList=True)
