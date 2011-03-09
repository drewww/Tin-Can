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

# stores the configuration information for easy global access.
config = None

def timesince(d, now=None):
    """
    Takes two time objects and returns time between d and now
    as a formatted string, e.g. "10m ago", but only goes up to hours
    so an output like "74h and 3m ago" is possible.
    """
    if not now:
        now = time.time()
    
    # I somehow ended up here with a None d, so just adding a check for it
    # to help identify when these issues happen. Not sure what triggered it,
    # though. There is probably something up-stream that needs fixing (my 
    # stuff, not yours) to stop handing in an empty time to timesince.
    if not d:
        return "bad time"
    
    diff = int(now - d);
    hours = diff/3600
    minutes = (diff-hours*3600)/60
    
    o = ""
    if (hours>1):
        o = str(hours)+"h"
    elif (hours==1):
        o = "1h"
        
    if (minutes>1):
        o += str(minutes)+"m"
    elif (minutes==1):
        o += "1m"

    if (o!=""):
        o += " ago"
    else:
        o = "just now"
    
    return o