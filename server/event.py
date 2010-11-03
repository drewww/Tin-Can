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
import traceback
import sys
import simplejson as json

import model
from event_types import *

filename = "events.log"
filename2 = "events-readable.log"
f1 = open(filename,"a")
f2 = open(filename2, "a")

class Event:    
    def __init__(self, eventType, actorUUID=None, meetingUUID=None, params={}, results=None):
        
        # these are the only required fields for an event.
        # all other paramters (like the text of a new topic, or new owner
        # of a task) are stored directly into the object (eg event.text=)
        # 
        # Which arguments are valid is specified for a given event type
        # is (nominally) on the wiki.
        if(eventType not in EventType.types):
            logging.error("""Attempted to create event with
                            unknown type %s"""%eventType)
        
        # look up the appropriate event type object from the event type list
        self.eventType = EventType.types[eventType]
        
        
        # For a discussion of what this is for, check self.addResult
        if results!=None:
            self.results = results
        else:
            self.results={}
        
        # log the time the event was created on the server.
        self.timestamp = time.time()
        
        # give the event a uuid. Not 100% sure what we're going to use this
        # for yet, but I've got a feeling we'll want it for ACKs from the
        # client. 
        self.uuid = str(uuid.uuid4())
        
        # now, cycle through the params. These are the bonus event options
        # that aren't shared by all events. The list of expected params is in
        # event.EVENT_PARAMS. We're going to store them as a dict locally,
        # but first we'll validate that we have at least the minimum expected
        # for our event type.
        expectedParams = self.eventType.params
        hasAllRequiredParams = True
        for param in expectedParams:
            if(param not in params.keys()):
                hasAllRequiredParams = False
                missingParam = param

        # if we're missing a param, fail with a descriptive error message.
        # otherwise, store the params and finish the constructor happily.
        if(not hasAllRequiredParams):
            logging.error("Tried to create event of type %s without param\
                %s. Expects: %s"%(self.eventType, missingParam,
                expectedParams))
            return None
        else:
            self.params = params
        
        # If this is a NEW_DEVICE event, we're not going to have any actor
        # information yet, so ditch out of the constructor now instead of 
        # failing on that stuff later. 
        
        # TODO what, exactly, is this checking for? is there a nice way
        # to fold it into the logic below?
        if(self.eventType.type=="NEW_DEVICE"):
            self.meeting = None
            return
            
        # Eventually we'll be rigorous about checking these, but for now
        # if we get key errors, just eat them and set them to None. Too hard
        # to test without this for now.
        if(self.eventType.requiresActor):
            self.actor = state.get_obj(actorUUID, model.Actor)
            if(self.actor==None):
                logging.error("""Tried to create an event with
                                invalid actorUUID %s"""%actorUUID)
                return None
        else:
            logging.debug("Since this event doesn't require it, we can allow \
self.actor to be None.")
            self.actor = None

        # UPDATE: no more global events
        # TODO Think about changing this. Makes returning the UUID
        # of the new object easier if we just say that new meetings REQUIRE
        # UUIDs too, and it's the job of the person creating a new meeting
        # event to create the UUID at that point and pass it down the chain.
        # TODO Figure out how to merge these event details into the main
        # event specification data structure, too.
        #if(not self.eventType.isGlobal):
        #    # any event other than NEW MEETING needs to have a meeting param
        #    self.meeting = state.get_obj(meetingUUID, model.Meeting)
        #    logging.warning("Set meeting to: " + str(self.meeting))
        #    if(self.meeting==None):
        #        # TODO We need to raise an exception here, not return none.
        #        # Returning None doesn't seem to do anything except end
        #        # the constructor. 
        #        logging.error("""Tried to create an event with invalid 
        #                        meetingUUID %s"""%meetingUUID)
        #        return None
        #else:
        #    self.meeting = None
        
        if meetingUUID != None:
            self.meeting = state.get_obj(meetingUUID, model.Meeting)
        else:
            self.meeting = None
        
    
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
    
    def getDict(self):
        d = {}
        
        # I think I could do some fancy self-referential loop-through-own-keys
        # thing here, but I kinda like the explicitness of doing it by hand
        # to remind what will actually be in this dictionary.
        d["eventType"] = self.eventType.type
        d["timestamp"] = self.timestamp
        d["uuid"] = self.uuid
        
        # load in the params. Put them in a separate namespace to avoid
        # collisions.
        
        # deswizzle params; we don't need to be including whole objects here,
        # just their UUIDs. The clients can unswizzle them. 
        d["params"] = {}
        logging.debug("params: " + str(self.params))
        for paramKey in self.params.keys():
            try:
                # if this works, then we were given an object that needs to be
                # converted down to a uuid. If it doesn't, then we didn't need
                # to convert it anyway.
                if(self.params[paramKey].uuid != None):
                    d["params"][paramKey] = self.params[paramKey].uuid
                else:
                    logging.debug("Tried to convert a param into a uuid and\
failed" + str(self.params[paramKey]))
            except Exception, e:
                # Fall back to just using the object directly. 
#                 logging.debug("Failed to convert a param into a UUID, probably\
#  wasn't an object to begin with. exception: " + str(e) + ", object: "
# + str(self.params[paramKey]))
                d["params"][paramKey] = self.params[paramKey]
                
            
        
        
        # Stuff in "results" stays whole and un-swizzled. This is where the
        # outcome of events goes. IE if we have a new agenda item, the whole
        # object will go here for easy unpacking on the other end.
        d["results"] = self.results
            
        # as above, this is just a temporary work around. Later, we'll enforce
        # these objects' existence
        try:
            d["meetingUUID"] = self.meeting.uuid
        except:
            d["meetingUUID"] = None

        try:
            d["actorUUID"] = self.actor.uuid
        except:
            d["actorUUID"] = None

            
        return d
        
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
            handler = self.eventType.handler
        except KeyError:
            logging.error("Tried to dispatch event type %s but no handler\
                was found."%self.eventType)
            return None
        
        # invoke the handler on this event.
        event = handler(self)
        logging.warning("self.meeting: " + str(self.meeting) + "; event: " + str(event))
        
        #all events are global now. else statement is never reached.
        # SEND EVENT TO APPROPRIATE CLIENTS
        if(self.eventType.isGlobal):
            sendEventsToDevices(state.get_devices(), [event])
            if event.meeting != None:
                event.meeting.eventHistory.append(event)
        else:
            # try:
            event.meeting.sendEvent(event)
            # except Exception, e:
            #            
            #            logging.error("Tried to send event to a meeting, but this\
            #            event didn't have a meeting set. Falling back to sending\
            #            to all devices.")
            #            logging.error("exception: " + str(e))
            #            
            #            sendEventsToDevices(state.get_devices(), [event])
                
        
        # RETURN THE RESULT
        # Handlers can return something - usually the new instance of an obj
        # that the event creates. This gets passed all the way back up the
        # dispatch chain, so the person who dispatched the event can see
        # the uuid/properties of the new object if they need it.
        f1.write(json.dumps(self, cls=model.YarnModelJSONEncoder)+"\n")
        try:
            if self.meeting!=None:
                f2.write(str(self.timestamp)+"   "+str(self.eventType)+":  Actor="+
                    str(self.actor.name)+", MeetingUUID="+str(self.meeting.uuid)+
                    ", params="+str(self.params)+"\n")
            else:
                f2.write(str(self.timestamp)+"   "+str(self.eventType)+":  Actor="+
                    str(self.actor.name)+", (No meeting defined)"+
                    ", params="+str(self.params)+"\n")
        except:
            f2.write(str(self.timestamp)+"   "+str(self.eventType)+
                ": (No actor/meeting defined), params="+str(self.params)+"\n")
        
        f1.flush()
        f2.flush()
        logging.info("Done dispatching event: " + str(self.getDict()))
        
        while (len(self.events)!=0):
            self.events.pop(0).dispatch()
        return event

    def queue(self, event):
        self.events.append(event)

def sendEventsToDevices(devices, events):
    
    # TODO do assertionerrors here if they're not both arrays?
    # or find some nice way to detect non-arrayness and wrap them?
    
    # had some trouble with names here: can't use 'user' and 'event' because
    # they're module names.
    # try:
    #     for curUser in users:
    #         for curEvent in events:
    #             curUser.enqueueEvent(curEvent)
    # except Exception, e:
    #     logging.error("sendEventsToUsers requires lists for both parameters,\
    #         and one of the parameters wasn't a list.")
    #     raise e
    for device in devices:
        for curEvent in events:
            device.enqueueEvent(curEvent)

if __name__ == '__main__':
    main()

