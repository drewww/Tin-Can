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
	as a formatted string, e.g. "10 minutes ago", but only goes up to hours
	so an output like "74 hours, 3 minutes, 2 seconds ago" is possible.
	"""
	if not now:
		now = time.time()
	
	diff = int(now - d);
	hours = diff/3600
	minutes = (diff-hours*3600)/60
	seconds = diff-hours*3600-minutes*60
	
	o = ""
	if (hours>1):
	    o = str(hours)+" hours"
	elif (hours==1):
	    o = "1 hour"
	
	if (o!="" and minutes>0 and seconds>0):
	    o += ", "
	elif (o!="" and (minutes>0 or seconds>0)):
	    o += " and "
	
	if (minutes>1):
	    o += str(minutes)+" minutes"
	elif (minutes==1):
	    o += "1 minute"
	
	if (hours>0 and seconds>0):
	    o += ", and "
	elif (seconds>0):
	    o += " and "
	
	if (seconds>1):
	    o += str(seconds)+" seconds"
	elif (seconds==1):
	    o += "1 second"
	
	o += " ago"
	
	return o