#!/usr/bin/env python

import cgi
from subprocess import *

# Enable these for debugging
#import cgitb
#cgitb.enable()

def header():
    print "Content-Type: text/html\n"

def printHead(title):
    print '''<head>
    <title>%s</title>
</head>''' % title

def main():
    header()
    print '<html>'
    printHead('Title')
    print '<body>'
    print '<h2>%s</h2>' % 'Title'
    print '</body></html>'

if __name__ == "__main__":
    main()
