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
import time
import uuid
import simplejson as json


EVENT_TYPES = ["JOINED", "LEFT", "NEW_TASK", "UPDATE_TASK", "NEW_TOPIC", "UPDATE_TOPIC", "PING"]

# Stores the required paramters for each event type. We'll use this
# to enforce complete intialization of events, and also to remind ourselves
# what's required for each event.
EVENT_PARAMS = {"JOINED":["user"],
                "LEFT":["user"]
                }

class Event:
    
    
    def __init__(self, eventType, meetingUUID, userUUID, params):
        
        # these are the only required fields for an event.
        # all other paramters (like the text of a new topic, or new owner
        # of a task) are stored directly into the object (eg event.text=)
        # 
        # Which arguments are valid is specified for a given event type
        # is (nominally) on the wiki.
        if(eventType not in EVENT_TYPES):
            logging.error("Attempted to create event with unknown type %s"%eventType)
        
        self.eventType = eventType
        
        # log the time the event was created on the server.
        self.timestamp = time.time()
        
        # give the event a uuid. Not 100% sure what we're going to use this
        # for yet, but I've got a feeling we'll want it for ACKs from the
        # client. 
        self.uuid = str(uuid.uuid4())
        
        # Eventually we'll be rigorous about checking these, but for now
        # if we get key errors, just eat them and set them to None. Too hard
        # to test without this for now.
        try:
            self.meeting = state.db[meetingUUID]
            self.user = state.db[userUUID]
        except:
            self.meeting = None
            self.users = None
            
        # now, cycle through the params. These are the bonus event options
        # that aren't shared by all events. The list of expected params is in
        # event.EVENT_PARAMS. We're going to store them as a dict locally,
        # but first we'll validate that we have at least the minimum expected
        # for our event type.
        expectedParams = EVENT_PARAMS[self.eventType]
        hasAllRequiredParams = True
        for param in expectedParams:
            if(param not in params.keys()):
                hasAllRequiredParams = False
                missingParam = param
        
        # if we're missing a param, fail with a descriptive error message.
        # otherwise, store the params and finish the constructor happily.
        if(not hasAllParams):
            logging.error("Tried to create event of type %s without param %s. Expects: %s"%(self.eventType, missingParam, expectedParams))
            return None
        else:
            self.params = params
        
        
        
    # TODO need to do some fancy stuff here to override the blah.foo operator so
    # we can keep track of what stuff has been set so we can write JSON
    # out properly including all the arguments that have been set on us. 
    
    def getJSON(self):
        d = {}
        
        # I think I could some fancy self-referential loop-through-own-keys
        # thing here, but I kinda like the explicitness of doing it by hand
        # to remind what will actually be in this dictionary.
        d["eventType"] = self.eventType
        d["timestamp"] = self.timestamp
        d["uuid"] = self.uuid
        
        # load in the params. Should they be in a separate namespace? 
        # Going to go with same namespace for now. 
        for key in self.params.keys():
            d[key] = self.params[key]
            
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

