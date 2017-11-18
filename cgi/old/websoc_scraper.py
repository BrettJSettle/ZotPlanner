from bs4 import BeautifulSoup
import bs4
import requests
import sqlite3
from urllib import urlencode


tables = {'courses': 'Discipline TEXT, Number TEXT, Title TEXT', 
        'offerings': 'YearTerm TEXT, course_id INTEGER, Code INTEGER, ' +
        'Type TEXT, Section TEXT, Units TEXT, Instructor TEXT, Time TEXT, ' + 
        'Place TEXT, Capacity INTEGER, Enrolled INTEGER, Waitlisted INTEGER, ' + 
        'Requests TEXT, Restrictions TEXT, Books TEXT, Site TEXT, Status TEXT'}

def get_tables(db):
    return [a[0] for a in db.execute("select name from sqlite_master where type = 'table'").fetchall()]

def create_table(db, name, attrs):
    if name in get_tables(db):
        return
    else:
        db.execute('CREATE TABLE %s(id INTEGER PRIMARY KEY, %s)' % (name, attrs))

def parse_html(html):
    soup = BeautifulSoup(html, 'html.parser')
    cl = soup.find('div', {'class':'course-list'})
    offerings = []
    courseInfo = []
    for course in cl.find_all('tr', valign='top'):
        if course.get('bgcolor') == '#fff0ff':
            if len(offerings) > 0:
                yield courseInfo, offerings
                offerings = []
            discNum = course.find('td').text
            discNum = [i.strip() for i in discNum.split('\xa0') if i.strip()]
            #keys = ['Discipline', 'Number', 'Title']
            courseInfo = [discNum[0],  discNum[1], discNum[2]]
        else:
            info = course.find_all('td')
            text = [t.text.replace('\xa0', '').strip() for t in info]
            if len(text) == 13:
                text.insert(12, '')
                text.append('')
            if len(text) == 14:
                text.insert(10, '')
            if len(text) != 15:
                print(text, len(text))

            #keys = ['Code', 'Type', 'Section', 'Units', 'Instructor', 'Time', 'Place', 'Capacity', 'Enrolled', 'Waitlisted', 'Requests', 'Restrictions', 'Books', 'Site', 'Status']
            offerings.append(text)
    if courseInfo:
        yield courseInfo, offerings

def query_websoc(**values):
    url = 'http://websoc.reg.uci.edu/perl/WebSoc'
    data = urlencode(values)
    data = data.encode('utf-8')
    req = requests.get(url, params=data)
    the_page = req.text
    return [(course, offerings) for course, offerings in parse_html(the_page)]

def get_options(name):
    url = 'http://websoc.reg.uci.edu/perl/WebSoc'
    req = requests.get(url)
    the_page = req.text
    bs = BeautifulSoup(the_page, 'html.parser')
    s = bs.find('select', {'name': name})
    l = []
    for opt in s.find_all('option'):
        l.append(opt.get('value'))
    return l


def open_db(fname='websoc.db'):
    db = sqlite3.connect(fname)
    create_table(db, 'courses', tables['courses'])
    create_table(db, 'offerings', tables['offerings'])
    return db

QUARTERS = {'Summer Session 2': '76', 'Summer Qtr': '51', '10-wk Summer': '39', 'Summer Session 1': '25', 'Spring Quarter': '14', 'Winter Quarter': '03', 'Fall Quarter': '92'}

def normalizeYearTerm(year, term):
    return '%d-%s' % (year, QUARTERS[term])

def scrape_courses(db, Discipline, YearTerm):
    cur = db.cursor()
    n = 0
    for course, offerings in query_websoc(Dept=Discipline, YearTerm=YearTerm):
        print(course)
        nums = cur.execute('SELECT id FROM courses WHERE Discipline = "%s" AND Number = "%s"' % (course[0], course[1])).fetchall()
        if len(nums) == 0:
            cur.execute('INSERT INTO courses(Discipline, Number, Title) VALUES ("%s","%s","%s")' % (course[0], course[1], course[2]))
            num = cur.lastrowid
        elif len(nums) == 1:
            num = nums[0][0]

        offerings = [[YearTerm, num] + offering for offering in offerings]
        #print([o for o in offerings if len(o) != 17])
        cur.executemany('DELETE FROM offerings WHERE YearTerm = ? AND Code = ?', [(off[0], off[2]) for off in offerings])
        cur.executemany('INSERT INTO offerings(YearTerm, course_id, Code, Type, Section, Units, Instructor, ' + 
            'Time, Place, Capacity, Enrolled, Waitlisted, Requests, Restrictions, Books, Site, Status) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)', offerings)
        
        db.commit()
        n += 1
        

def scrape_yearterm(db, YearTerm):
    for disc in get_options('Dept'):
        scrape_courses(db, Discipline=disc, YearTerm=YearTerm)

def update_db(db):
    cur = db.cursor()
    yt_opts = get_options('YearTerm')
    yts = cur.execute('SELECT DISTINCT YearTerm FROM offerings''').fetchall()
    yts = [yt[0] for yt in yts]
    yts = set(yt_opts) - set(yts)
    for yt in yts:
        print('Scraping %s' % yt)
        scrape_yearterm(db, yt)

def make_db(db):
    
    DEPTS = get_options("Dept")
    yts = get_options('YearTerm')
    for school in DEPTS:
        for yearterm in yts:
            if school != ' ALL':
                scrape_courses(db, Discipline=school, YearTerm=yearterm)
        
    return db

def get_class(dept, num):
    db = open_db()
    

def console(db):
    from PyQt4 import QtGui
    app = QtGui.QApplication([])
    from pyqtgraph.console import ConsoleWidget
    cw = ConsoleWidget()
    cw.localNamespace.update(globals())
    cw.localNamespace.update(locals())
    cw.show()
    app.exec_()

def classes_like(db, num):
    num = num.replace('@', '_')
    cur = db.cursor()
    vals = cur.execute('''SELECT DISTINCT Number FROM courses WHERE Number like "%s"''' % num).fetchall()
    return [v[0] for v in vals]

if __name__ == '__main__':
    db = open_db()
    print(classes_like(db, "@1@@W"))
    #make_db(db)
    #console(db)
    db.close()
    
