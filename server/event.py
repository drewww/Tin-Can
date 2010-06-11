#!/usr/bin/env python
# encoding: utf-8
"""
event.py

Defines the event class and contains methods for writing methods to disk
and generating server state based on events read from the disk on startup.

Created by Drew Harry on 2010-06-11.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import logging
import state

import simplejson as json

EVENT_TYPES = ["NEW_MEETING", "JOINED", "LEFT", "NEW_TASK", "UPDATE_TASK", "NEW_TOPIC", "UPDATE_TOPIC", "PING"]

class Event:
    
    
    def __init__(self, eventType, meetingUUID, userUUID):
        
        # these are the only required fields for an event.
        # all other paramters (like the text of a new topic, or new owner
        # of a task) are stored directly into the object (eg event.text=)
        # 
        # Which arguments are valid is specified for a given event type
        # is (nominally) on the wiki.
        if(eventType not in EVENT_TYPES):
            logging.error("Attempted to create event with unknown type %s"%eventType)
        
        self.eventType = eventType
        
        # Eventually we'll be rigorous about checking these, but for now
        # if we get key errors, just eat them and set them to None. Too hard
        # to test without this for now.
        try:
            self.meeting = state.db[meetingUUID]
            self.user = state.db[userUUID]
        except:
            self.meeting = None
            self.users = None
        
        
    # TODO need to do some fancy stuff here to override the blah.foo operator so
    # we can keep track of what stuff has been set so we can write JSON
    # out properly including all the arguments that have been set on us. 
    
    def getJSON(self):
        d = {}
        d["eventType"] = self.eventType
        
        # as above, this is just a temporary work around. Later, we'll enforce
        # these objects' existence
        try:
            d["meeting"] = self.meeting.uuid
            d["user"] = self.user.uuid
        except:
            d["meeting"] = None
            d["user"] = None
            
        return json.dumps(d)

if __name__ == '__main__':
    main()

