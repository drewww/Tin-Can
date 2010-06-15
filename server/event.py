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

from model import *

EVENT_TYPES = ["NEW_MEETING", "JOINED", "LEFT", "NEW_TASK", "UPDATE_TASK",
                "NEW_TOPIC", "UPDATE_TOPIC", "PING"]

# Stores the required paramters for each event type. We'll use this
# to enforce complete intialization of events, and also to remind ourselves
# what's required for each event.
EVENT_PARAMS = {"NEW_MEETING":["room"],
                "JOINED":[],            # these events have no extra params.
                "LEFT":[]
                }

class Event:
    
    
    def __init__(self, eventType, userUUID, meetingUUID=None, params={}):
        
        # these are the only required fields for an event.
        # all other paramters (like the text of a new topic, or new owner
        # of a task) are stored directly into the object (eg event.text=)
        # 
        # Which arguments are valid is specified for a given event type
        # is (nominally) on the wiki.
        if(eventType not in EVENT_TYPES):
            logging.error("""Attempted to create event with
                            unknown type %s"""%eventType)
        
        self.eventType = eventType
        
        
        # For a discussion of what this is for, check self.addResult
        self.results = {}
        
        # log the time the event was created on the server.
        self.timestamp = time.time()
        
        # give the event a uuid. Not 100% sure what we're going to use this
        # for yet, but I've got a feeling we'll want it for ACKs from the
        # client. 
        self.uuid = str(uuid.uuid4())
        
        # Eventually we'll be rigorous about checking these, but for now
        # if we get key errors, just eat them and set them to None. Too hard
        # to test without this for now.
        self.user = state.get_obj(userUUID, User)
        if(self.user==None):
            logging.error("""Tried to create an event with
                            invalid userUUID %s"""%userUUID)
            return None

        # TODO Think about changing this. Makes returning the UUID
        # of the new object easier if we just say that new meetings REQUIRE
        # UUIDs too, and it's the job of the person creating a new meeting
        # event to create the UUID at that point and pass it down the chain.
        if(self.eventType!="NEW_MEETING"):
            # any event other than NEW MEETING needs to have a meeting param
            self.meeting = state.get_obj(meetingUUID, Meeting)
            if(self.meeting==None):
                # TODO We need to raise an exception here, not return none.
                # Returning None doesn't seem to do anything except end
                # the constructor. 
                logging.error("""Tried to create an event with invalid 
                                meetingUUID %s"""%meetingUUID)
                return None
        
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
        if(not hasAllRequiredParams):
            logging.error("Tried to create event of type %s without param %s. Expects: %s"%(self.eventType, missingParam, expectedParams))
            return None
        else:
            self.params = params
        
        
    
    def addResult(self, key, value):
        """Stores a result object. 
        
        This is used when the event generates some new object on the server
        that needs to be included in the object. For instance, a NEW_TASK
        event doesn't (when created) contain the actual Task object in it.
        For the sake of clarity, we'll put all these objects into a dict
        separate from the params dict so it's clear why they're there and
        what they're for."""
        self.results[key] = value
        
        # TODO add a check to make sure we're not overwriting a result?
    
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
        
        # load in the params. Put them in a separate namespace to avoid
        # collisions.
        d["params"] = self.params
        
        # ibid.
        d["results"] = self.results
            
        # as above, this is just a temporary work around. Later, we'll enforce
        # these objects' existence
        try:
            d["meetingUUID"] = self.meeting.uuid
            d["userUUID"] = self.user.uuid
        except:
            d["meetingUUID"] = None
            d["userUUID"] = None
            
        return json.dumps(d, cls=YarnModelJSONEncoder)
        
    def dispatch(self):
        """Triggers an event dispatch process.
        
        Depending on the event, calls the appropriate methods to change
        internal state and do other EVENT-related stuff. Also sends
        the event to the appropriate clients."""
        
        # Steps:
        #   - Write to disk (TODO)
        #   - Dispatch / change internal state (TODO)
        #   - Send on to appropriate clients. (TODO)
        
        
        
        # WRITE EVENT TO DISK
        # (not going to do this for a bit)
        
        # MODIFY INTERNAL STATE
        # python has no switch/case statement (ugh) so we're going
        # to dispatch by a dictionary with function pointers.
        #
        # Depending on the event type,
        # we're going to something different with it.
        
        try:
            handler = DISPATCH[self.eventType]
        except KeyError:
            logging.error("Tried to dispatch event type %s but no handler\
                was found."%self.eventType)
            return None
        
        # invoke the handler on this event.
        event = handler(self)
        
        # SEND EVENT TO APPROPRIATE CLIENTS
        if(self.eventType == "NEW_MEETING"):
            state.send_event_to_users(state.get_logged_in_users(), event)
        else:
            state.send_event_to_meeting(event)
        
        # RETURN THE RESULT
        # Handlers can return something - usually the new instance of an obj
        # that the event creates. This gets passed all the way back up the
        # dispatch chain, so the person who dispatched the event can see
        # the uuid/properties of the new object if they need it.
        
        logging.info("Done dispatching event: " + str(self.getJSON()))
        return event


# DISPATCH METHODS
# These methods will not be called by anyone other than the event dispatch
# method. They determine what happens to internal state based on the event.

def _handleNewMeeting(event):
    newMeeting = Meeting(event.params["room"].uuid)
    
    # once we have the meeting, push it back into the event object.
    # pushing it into params because the outer meeting value is
    # just for specifying which meeting an event is taking place in, 
    # and this event type happens outside of a meeting context.
    event.addResult("meeting", newMeeting)
    
    # now register that meeting with the room.
    event.params["room"].set_meeting(newMeeting)
    
    
    
    return event

def _handleJoined(event):
    event.meeting.participantJoined(event.user)
    
    # this is a little wonky, but the way the event system works, it doesn't
    # include the full user object (ie event.user) in every event because
    # most of the time all we need to know is what their UUID is. But in this
    # case it's a new user, so we need to give clients all the info they need
    # to create a new local user object. 
    event.addResult("user", event.user)
    return event
    
def _handleLeft(event):
    event.meeting.participantLeft(event.user)
    
    # We DON'T need to include the user in the result object (as above)
    # because clients will already know about this user, so the UUID in the
    # event itself is enough.
    return event

# Maps EVENT_TYPES to the functions that handle those events. Used in 
# Event.dispatch. 
DISPATCH = {"NEW_MEETING":_handleNewMeeting,
            "JOINED":_handleJoined,
            "LEFT":_handleLeft
            }



if __name__ == '__main__':
    main()

