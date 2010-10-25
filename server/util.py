#!/usr/bin/env python
# encoding: utf-8
"""
util.py

Defines some utility functions:
 * timesince

Created by Joshua Ma on 2010-10-25.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import time

def timesince(d, now=None):
    """
    Takes two time objects and returns time between d and now
    as a formatted string, e.g. "10m ago", but only goes up to hours
    so an output like "74h and 3m ago" is possible.
    """
    if not now:
        now = time.time()
    
    diff = int(now - d);
    hours = diff/3600
    minutes = (diff-hours*3600)/60
    
    o = ""
    if (hours>1):
        o = str(hours)+"h"
    elif (hours==1):
        o = "1h"
        
    if (o!="" and minutes>0):
        o += " and "
        
    if (minutes>1):
        o += str(minutes)+"m"
    elif (minutes==1):
        o += "1m"

    if (o!=""):
        o += " ago"
    else:
        o = "just now"
    
    return o