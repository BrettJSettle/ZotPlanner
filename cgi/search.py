#! /usr/bin/python
from bs4 import BeautifulSoup
import requests
import urllib
import bs4


def get_search():
    html = requests.get("http://websoc.reg.uci.edu").text
    inner = BeautifulSoup(html, 'html.parser').find(
        'form',
        action='https://www.reg.uci.edu/perl/WebSoc/')
    table = inner.find('table')
    
    sub_input = bs4.Tag(name='input', attrs={'class': 'btn', 'id': 'search', 'type': 'button', 'value': 'Show Listings'})
    sub_clear = bs4.Tag(name='input', attrs={'class': 'btn', 'id': 'clearSearch', 'type': 'button', 'value': 'Clear'})

    sub_tr = bs4.Tag(name="tr")
    sub_tr.insert(0, sub_input)
    sub_tr.insert(1, sub_clear)

    form = bs4.Tag(name="form", attrs={'id': 'websoc-form'})
    form.insert(0, table)
    form.insert(1, sub_tr)

    result = bs4.Tag(name='div', attrs={'id': 'search-message', 'style': 'display: inline;'})
    form.insert(2, result)

    return unicode('%s' % form, errors='ignore')

def getPrereqs(url):
    try:
        reqs = BeautifulSoup(requests.get(url).text, "html.parser")
        reqs = reqs.find('a', {'name': url.split('#')[-1]})
        reqs = reqs.parent.parent
        reqs = reqs.find('td', {'class': 'prereq'})
        return reqs.text
    except Exception as e:
        return str(e)

def get_listing(form_data, asStr=True):
    html = requests.post(
        "https://www.reg.uci.edu/perl/WebSoc/",
        data=form_data,
        headers={'Content-Type': 'application/x-www-form-urlencoded'}).content
    listing = BeautifulSoup(html, 'html.parser').find('div', 'course-list')
    listings = listing.find_all('tr')#, {'valign': 'top'})
    if len(listings) == 0:
        return "ERROR: No Classes Found for %s" % (', '.join(['%s: %s' % (k, v) for k,v in form_data.items()]))
    res = ''
    if not asStr:
        return listings
    for i in range(len(listings)):
        if 'valign' not in listings[i].attrs:
            if 'bgcolor' in listings[i].attrs and listings[i].attrs['bgcolor'] in ('navy', '#E7E7E7', '#FFFFCC'):
                res += str(listings[i])
            continue
        if 'bgcolor' in listings[i].attrs and listings[i].attrs['bgcolor'] == '#fff0ff':
            if i > 0:
                res += '</table>'
            #toggle = bs4.element.Tag(name="input", attrs={'type': 'button', 'value': '^', 'style': 'float:left;', 'class': 'toggle'})
            toggle = bs4.element.Tag(name="input", attrs={'type': 'image', 'src': 'media/up-128.png', 'style': 'width:20px;', 'class': 'toggle'})
            listings[i].find('td').insert(10, toggle)
            #remove = bs4.element.Tag(name='input', attrs={'type': 'button', 'value': '-', 'style': 'float:left;', 'class': 'remove'})
            remove = bs4.element.Tag(name='input', attrs={'type': 'image', 'src': 'media/remove.ico', 'style': 'float:left; width:20px', 'class': 'remove'})
            listings[i].find('td').insert(10, remove)
            '''prereq = listings[i].find('a', text="Prerequisites")
            if prereq:
                link = prereq.get("href")
                reqs = getPrereqs(link)
                prereq.attrs['title'] = reqs'''
            res += str(listings[i])
            if i < len(listings) - 1:
                res += '<table>'
        else:
            res += str(listings[i])
    return res

def test(v):
    return get_listing({'Dept': 'COMPSCI', 'YearTerm': '2017-03'}, v)

import cgi
form = cgi.FieldStorage()
mode = form.getvalue('mode')
print('Content-type: text/html\r\n\r\n')
if mode == 'load':
    try:
        print(get_search())
    except Exception as e:
        print(e)
elif mode == 'search':
    #items = {k: form.getvalue(k) for k in ('Breadth', 'Dept', 'YearTerm', 'CourseNum')}
    items = {k.name: form.getvalue(k.name) for k in form.list if k.name != 'mode'}
    print(get_listing(items))
