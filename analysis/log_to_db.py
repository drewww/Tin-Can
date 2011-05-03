#!/usr/bin/env python
# encoding: utf-8
"""
log_to_db.py

Converts a JSON-streaming log file format (as generated by yarn.py during
an event) into a database, for easier cross-cutting analysis. 

Built to work with MySQL.

Created by Drew Harry on 2011-05-03.
Copyright (c) 2011 MIT Media Lab. All rights reserved.
"""

import MySQLdb

# this will keep a reference to the database connection.
db = None


def convert_log(path):
    f = open(path, 'r')
    
    
    


if __name__ == '__main__':
    print "Opening database connection."
    db = MySQLdb.connect(host = "localhost", user="root", db="tincan")
    
    
    convert_log("emerson-logs/first_class.log")
    
    print "Closing database connection."
    db.close()
    
