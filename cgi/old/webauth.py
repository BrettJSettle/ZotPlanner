#! /usr/bin/python
import cgi, re
from lxml import etree as ET
from degreeworks import WebAuth, WebRegMessageException
depts = ["AC ENG","AFAM","ANATOMY","ANESTH","ANTHRO","ARABIC","ART","ART HIS","ART STU","ARTS","ARTSHUM","ASIANAM","BATS","BIO SCI","BIOCHEM","BME","BSEMD","CAMPREC","CBEMS","CEM","CHC/LAT","CHEM","CHINESE","CLASSIC","CLT&THY","COGS","COM LIT","COMPSCI","CRITISM","CRM/LAW","CSE","DANCE","DERM","DEV BIO","DRAMA","E ASIAN","EARTHSS","ECO EVO","ECON","ED AFF","EDUC","EECS","EHS","ENGLISH","ENGR","ENGRCEE","ENGRMAE","ENGRMSE","ENVIRON","EPIDEM","ER MED","EURO ST","FAM MED","FLM&MDA","FRENCH","GEN&SEX","GERMAN","GLBL ME","GLBLCLT","GREEK","HEBREW","HINDI","HISTORY","HUMAN","HUMARTS","I&C SCI","IN4MATX","INT MED","INTL ST","ITALIAN","JAPANSE","KOREAN","LATIN","LAW","LINGUIS","LIT JRN","LPS","M&MG","MATH","MED","MED ED","MED HUM","MGMT","MGMT EP","MGMT FE","MGMT HC","MGMTMBA","MGMTPHD","MIC BIO","MOL BIO","MPAC","MUSIC","NET SYS","NEURBIO","NEUROL","NUR SCI","OB/GYN","OPHTHAL","PATH","PED GEN","PEDS","PERSIAN","PHARM","PHILOS","PHRMSCI","PHY SCI","PHYSICS","PHYSIO","PLASTIC","PM&R","POL SCI","PORTUG","PP&D","PSY BEH","PSYCH","PUB POL","PUBHLTH","RAD SCI","RADIO","REL STD","ROTC","RUSSIAN","SOC SCI","SOCECOL","SOCIOL","SPANISH","SPPS","STATS","SURGERY","TAGALOG","TOX","UCDC","UNI AFF","UNI STU","VIETMSE","VIS STD","WOMN ST","WRITING"]
import difflib

def closest_disc(d):
    if d in depts:
	return d
    else:
	closest = difflib.get_close_matches(d.upper(), depts, 1)
	if closest:
	    return closest[0]
    return d

print('Content-type: text/html\r\n\r\n')

def normalizeCourseLinks(dom):
    discs = set(re.findall('disc="([^"]*)"', dom))
    for disc in discs:
	close =  closest_disc(disc)
        dom = dom.replace('disc="%s"' % disc, 'disc="%s"' % close)

    dom = re.sub(r'num="(\d{3})@"', r'num="\1"', dom)
    dom = re.sub(r'num="(?P<num>\d{2})@"', r'num="\g<num>0-\g<num>9"', dom)
    return dom

def make_html(ucinetid=None, password=None):
    form = cgi.FieldStorage() 
    if not ucinetid:
        ucinetid = form.getvalue('ucinetid')
    if not ucinetid:
        raise Exception("No ucinetid provided")
    if not password:
        password = form.getvalue('password')
    if not password:
        raise Exception("No password provided.")
    mode = form.getvalue('mode')
    auth = WebAuth()
    auth.get_auth(ucinetid, password)

    if mode == 'Degreeworks': 
        try:
            dw = auth.degreeWorks()
	    dom = ET.fromstring(str(dw))
	    xsl = ET.parse('Stylesheets/DGW_Report.xsl')
	    xslt = ET.XSLT(xsl)
	    newdom = xslt(dom)
	    newdom = normalizeCourseLinks(str(newdom))
            print(newdom)
            auth.logout()
        except WebRegMessageException as e:
            print("ERROR: Failed to retrieve DegreeWorks: %s" % e)
    elif mode == "Login":
        if len(auth.ucinetid_auth) > 60:
            print(auth.ucinetid_auth)
        else:
            raise Exception("Login Failure")
    else:
        print("ERROR: Mode not recognized. Must be Logout, Degreeworks or Re-Authenticate")

import traceback, sys

try:
    make_html()
except WebRegMessageException as e:
    print(e)
except Exception as ex:
    print("ERROR: " + str(ex))
