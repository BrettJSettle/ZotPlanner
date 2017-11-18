#!/usr/bin/python
from __future__ import division, print_function

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

from websoc_scraper import open_db, classes_like

__all__ = ['WebAuth', 'WebAuthError', 'main']

def getLogin(usr='', pwd=''):
    if not usr:
        usr = raw_input("Ucinetid: ")
    if not pwd:
        pwd = getpass.getpass(prompt="password:")
    return usr, pwd


class WebAuth(object):
	LOGIN_URL = 'https://login.uci.edu/ucinetid/webauth'
	CHECK_URL = 'https://login.uci.edu/ucinetid/webauth_check'
	LOGOUT_URL = 'https://login.uci.edu/ucinetid/webauth_logout'
	DW_URL = "https://www.reg.uci.edu/dgw/IRISLink.cgi?seg=U"
	SA_URL = "https://www.reg.uci.edu/access/student/welcome/"
	REG_URL = "http://webreg2.reg.uci.edu:8889/cgi-bin/wramia"
	WEBREG_REDIRECT = "http://webreg2.reg.uci.edu:8889/cgi-bin/wramia?page=startUp&call="

	USER_AGENT = "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36"

	ERROR_CODES = {
		'WEBAUTH_DOWN': 'The WebAuth Server is currently down',
		'NO_AUTH_KEY': 'No ucinetid_auth was provided',
		'NOT_FOUND': 'The ucinetid_auth is not in the database',
		'NO_AFFILIATION': 'Access denied to see user information'}

	ATTRS = {
		'ucinetid': str, 'auth_host': str, 'time_created': int,
		'last_checked': int, 'max_idle_time': int, 'login_timeout': int,
		'campus_id': str, 'uci_affiliations': str, 'age_in_seconds': int,
		'seconds_since_checked': int, 'auth_fail': str, 'error_code': str}

	def __init__(self):
		self.session = Session()
		self.session.headers['User-Agent'] = self.USER_AGENT

	def degreeWorks(self):
                if not hasattr(self, 'ucinetid_auth') or self.ucinetid_auth == None:
                    raise WebAuthError("Not logged in")
		self.session.get(self.DW_URL)	
		data = {"SERVICE":"SCRIPTER",
			"REPORT":"WEB31",
			"SCRIPT":"SD2GETAUD&ContentType=xml",
			"USERID":self.usrid,
			"USERCLASS":"STU",
			"SCHOOL": "U",
                        "DEGREE": "BS",
                        "BROWSER":"NOT-NAV4",
			"ACTION":"REVAUDIT",
			"AUDITTYPE":"",
			"DEGREETERM":"ACTV",
			"INTNOTES":"",
			"INPROGRESS":"",
			"CUTOFFTERM":"ACTV",
			"REFRESHBRDG":"N",
			"AUDITID":"",
			"JSERRORCALL":"SetError",
			"NOTENUM":"",
			"NOTETEXT":"",
			"NOTEMODE":"",
			"PENDING":"",
			"INTERNAL":"",
			"RELOADSEP":"TRUE",
			"PRELOADEDPLAN":"",
			"ContentType":"xml",
			"STUID":self.usrid,
			"DEBUG":"OFF"}
		res = self.session.post(self.DW_URL, data)
		return res.text

	def get_auth(self, usr, pwd):
		self.usrid = usr
		res = self.session.get(self.WEBREG_REDIRECT)
		text = res.text
		url = self.LOGIN_URL
		data = {'ucinetid': usr, 'password': pwd, 'login_button': 'Login'}
		res = self.session.post(url, data=data) 
		self.ucinetid_auth = self.session.cookies['ucinetid_auth'] 
				
	@staticmethod
	def checkForMsg(text):
		text = BeautifulSoup(text, 'html.parser')
		err = text.find('div', {'class': 'WebRegErrorMsg'})
		if err and 'in use' in str(err):
			raise InUseException(str(err))
		if err and 'back button' not in str(err):
			raise WebRegMessageException(str(err))

	def logout(self):
		"""Clear ucinetid_auth entry in UCI WebAuth database."""
		if not self.ucinetid_auth and len(self.session.cookies['ucinetid_auth']) < 60:
			return "Not logged in"
		r = self.session.get('https://www.reg.uci.edu/perl/logout.pl')
		r = self.session.get('http://www.reg.uci.edu/access/student/logout/')
		self._clear()
		return r.text

	def _clear(self):
		"""Initialize attributes to None."""
		self.ucinetid_auth = None
                self.session.cookies.clear()

	def __str__(self):
		output = ['ucinetid_auth=%s' % self.ucinetid_auth]
		for attr in self.ATTRS.keys():
			value = getattr(self, attr)
			if value is not None:
				output.append("%s=%s" % (attr, value))
		return "\n".join(output)

class WebAuthError(Exception):
	pass
class WebRegMessageException(Exception):
	pass
class InUseException(Exception):
	pass
class NoClassReqException(Exception):
	pass

depts = ["AC ENG","AFAM","ANATOMY","ANESTH","ANTHRO","ARABIC","ART","ART HIS","ART STU","ARTS","ARTSHUM","ASIANAM","BATS","BIO SCI","BIOCHEM","BME","BSEMD","CAMPREC","CBEMS","CEM","CHC/LAT","CHEM","CHINESE","CLASSIC","CLT&THY","COGS","COM LIT","COMPSCI","CRITISM","CRM/LAW","CSE","DANCE","DERM","DEV BIO","DRAMA","E ASIAN","EARTHSS","ECO EVO","ECON","ED AFF","EDUC","EECS","EHS","ENGLISH","ENGR","ENGRCEE","ENGRMAE","ENGRMSE","ENVIRON","EPIDEM","ER MED","EURO ST","FAM MED","FLM&MDA","FRENCH","GEN&SEX","GERMAN","GLBL ME","GLBLCLT","GREEK","HEBREW","HINDI","HISTORY","HUMAN","HUMARTS","I&C SCI","IN4MATX","INT MED","INTL ST","ITALIAN","JAPANSE","KOREAN","LATIN","LAW","LINGUIS","LIT JRN","LPS","M&MG","MATH","MED","MED ED","MED HUM","MGMT","MGMT EP","MGMT FE","MGMT HC","MGMTMBA","MGMTPHD","MIC BIO","MOL BIO","MPAC","MUSIC","NET SYS","NEURBIO","NEUROL","NUR SCI","OB/GYN","OPHTHAL","PATH","PED GEN","PEDS","PERSIAN","PHARM","PHILOS","PHRMSCI","PHY SCI","PHYSICS","PHYSIO","PLASTIC","PM&R","POL SCI","PORTUG","PP&D","PSY BEH","PSYCH","PUB POL","PUBHLTH","RAD SCI","RADIO","REL STD","ROTC","RUSSIAN","SOC SCI","SOCECOL","SOCIOL","SPANISH","SPPS","STATS","SURGERY","TAGALOG","TOX","UCDC","UNI AFF","UNI STU","VIETMSE","VIS STD","WOMN ST","WRITING"]
import difflib
def closest_dept(d):
	if d in depts:
		return d
	else:
		closest = difflib.get_close_matches(d.upper(), depts, 1)
		if closest:	
			return closest[0]
	return d
				

def main():
	usr, pwd = getLogin()
	auth = WebAuth()
	auth.get_auth(usr, pwd)
        return auth
	
if __name__ == "__main__":
	main()

