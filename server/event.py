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

import model

# TODO Merge EVENT_TYPES, EVENT_PARAMS, and DISPATCH (way at the bottom) 
# into one happy data structure. All the metadata about events should be
# kept together, instead of in three places. 
EVENT_TYPES = ["NEW_MEETING", "JOINED_MEETING", "LEFT_ROOM",
    "USER_JOINED_LOCATION", "USER_LEFT_LOCATION", "NEW_USER", "LOCATION_JOINED_MEETING",
    "LOCATION_LEFT_ROOM", "NEW_DEVICE", "ADD_ACTOR_DEVICE"
    ]

# Stores the required paramters for each event type. We'll use this
# to enforce complete intialization of events, and also to remind ourselves
# what's required for each event.
EVENT_PARAMS = {"NEW_MEETING":["room"],
                "NEW_USER":["name"],
                "USER_JOINED_LOCATION":["location"],
                "USER_LEFT_LOCATION": ["location"],
                "LOCATION_JOINED_MEETING": ["location"],
                "LOCATION_LEFT_MEETING": ["location"],
                "NEW_DEVICE": [],
                "ADD_ACTOR_DEVICE": ["actor", "device"]
                }

class Event:    
    def __init__(self, eventType, actorUUID=None, meetingUUID=None, params={}):
        
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
            logging.error("Tried to create event of type %s without param\
                %s. Expects: %s"%(self.eventType, missingParam,
                expectedParams))
            return None
        else:
            self.params = params
        
        # If this is a NEW_DEVICE event, we're not going to have any actor
        # information yet, so ditch out of the constructor now instead of 
        # failing on that stuff later. 
        if(self.eventType=="NEW_DEVICE"):
            self.meeting = None
            return
            
        # Eventually we'll be rigorous about checking these, but for now
        # if we get key errors, just eat them and set them to None. Too hard
        # to test without this for now.
        if(not self.eventType in ["NEW_USER"]):
            self.actor = state.get_obj(actorUUID, model.Actor)
            if(self.actor==None):
                logging.error("""Tried to create an event with
                                invalid actorUUID %s"""%actorUUID)
                return None
        else:
            logging.debug("Since this is a NEW_USER event, we can allow \
self.actor to be None.")
            self.actor = None

        # TODO Think about changing this. Makes returning the UUID
        # of the new object easier if we just say that new meetings REQUIRE
        # UUIDs too, and it's the job of the person creating a new meeting
        # event to create the UUID at that point and pass it down the chain.
        # TODO Figure out how to merge these event details into the main
        # event specification data structure, too.
        if(not self.eventType in ["NEW_MEETING", "ADD_ACTOR_DEVICE",
            "USER_JOINED_LOCATION", "USER_LEFT_LOCATION", "NEW_USER"]):
            # any event other than NEW MEETING needs to have a meeting param
            self.meeting = state.get_obj(meetingUUID, model.Meeting)
            if(self.meeting==None):
                # TODO We need to raise an exception here, not return none.
                # Returning None doesn't seem to do anything except end
                # the constructor. 
                logging.error("""Tried to create an event with invalid 
                                meetingUUID %s"""%meetingUUID)
                return None        
       
        
        
    
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
        d["eventType"] = self.eventType
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
                logging.debug("Failed to convert a param into a UUID, probably\
wasn't an object to begin with. exception: " + str(e) + ", object: "
+ str(self.params[paramKey]))
                
            
        
        
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
            handler = DISPATCH[self.eventType]
        except KeyError:
            logging.error("Tried to dispatch event type %s but no handler\
                was found."%self.eventType)
            return None
        
        # invoke the handler on this event.
        event = handler(self)
        
        # SEND EVENT TO APPROPRIATE CLIENTS
        if(self.eventType in ["NEW_MEETING","NEW_USER","NEW_DEVICE",
            "ADD_ACTOR_DEVICE", "USER_JOINED_LOCATION", "USER_LEFT_LOCATION",
            "LOCATION_JOINED_MEETING"]):
            sendEventsToDevices(state.get_devices(), [event])
        else:
            try:
                event.meeting.sendEvent(event)
            except:
                logging.error("Tried to send event to a meeting, but this\
                event didn't have a meeting set. Falling back to sending\
                to all devices.")
                sendEventsToDevices(state.get_devices(), [event])
                
        
        # RETURN THE RESULT
        # Handlers can return something - usually the new instance of an obj
        # that the event creates. This gets passed all the way back up the
        # dispatch chain, so the person who dispatched the event can see
        # the uuid/properties of the new object if they need it.
        
        logging.info("Done dispatching event: " + str(self.getDict()))
        return event

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


# DISPATCH METHODS
# These methods will not be called by anyone other than the event dispatch
# method. They determine what happens to internal state based on the event.

def _handleNewMeeting(event):
    newMeeting = model.Meeting(event.params["room"].uuid)
    
    # once we have the meeting, push it back into the event object.
    # pushing it into params because the outer meeting value is
    # just for specifying which meeting an event is taking place in, 
    # and this event type happens outside of a meeting context.
    event.addResult("meeting", newMeeting)
    
    # now register that meeting with the room.
    event.params["room"].set_meeting(newMeeting)
    
    # add this event to the meeting, so it's included at the beginning of
    # every meeting history.
    newMeeting.eventHistory.append(event)
    
    
    return event

# def _handleJoinedRoom(event):
#     event.meeting.userJoined(event.actor)
#     
#     # this is a little wonky, but the way the event system works, it doesn't
#     # include the full user object (ie event.user) in every event because
#     # most of the time all we need to know is what their UUID is. But in this
#     # case it's a new user, so we need to give clients all the info they need
#     # to create a new local user object. 
#     event.addResult("actor", event.actor)
#     return event
    
def _handleLeftRoom(event):
    event.meeting.userLeft(event.actor)
    
    # We DON'T need to include the actor in the result object (as above)
    # because clients will already know about this actor, so the UUID in the
    # event itself is enough.
    return event
    
def _handleNewUser(event):
    newUser = model.User(event.params["name"])

    # Make sure to do this for new locations, too. 
    state.add_actor(newUser)
    
    event.addResult("actor", newUser)
    return event

def _handleNewDevice(event):
    device = model.Device()

    event.addResult("device", device)

    return event

def _handleAddActorDevice(event):
    # connects devices with their actors.
    actor = event.params["actor"]
    device = event.params["device"]
    
    actor.addDevice(device)
    
    return event
    

def _handleJoinedLocation(event):
    location = event.params["location"]
    location.userJoined(event.actor)
    
    # event.addResult("user", event.actor)
    
    # Turning this off for now - I think we can live without it.
    # The USER_JOINED_LOCATION event will fire, and clients should be able
    # to imply the rest. 
    # if location.isInMeeting():
    #      actorJoinedEvent = Event("JOINED_MEETING", event.actor.uuid,
    #          location.meeting.uuid)
    # 
    #      # TODO Need to do something about dispatch order here. This joined
    #      # event is going to finish dispatching before the joined_location
    #      # event does, which might cause some trouble. Need a way for events
    #      # to dispatch in the order they're created, not the order they're 
    #      # executed. 
    #      actorJoinedEvent.dispatch()
    
    return event

def _handleLeftLocation(event):
    location = event.params["location"]
    location.userLeft(event.actor)

    # Turning this off for now - I think we can live without it.
    # The USER_JOINED_LOCATION event will fire, and clients should be able
    # to imply the rest.
    # if location.isInMeeting():
    #     userLeftEvent = Event("LEFT_ROOM", event.user.uuid,
    #         location.meeting.uuid)
    # 
    #     # TODO Need to do something about dispatch order here. This joined
    #     # event is going to finish dispatching before the joined_location
    #     # event does, which might cause some trouble. Need a way for events
    #     # to dispatch in the order they're created, not the order they're 
    #     # executed. 
    #     userLeftEvent.dispatch()
    
    return event


def _handleLocationJoinedMeeting(event):
    # For all the users in this location, fire joined messages
    location = event.params["location"]
    meeting = event.meeting
    
    location.joinedMeeting(meeting)
    return event

def _handleLocationLeftMeeting(event):
    location = event.params["location"]
    meeting = event.meeting

    location.leftMeeting(meeting)
    return event

# Maps EVENT_TYPES to the functions that handle those events. Used in 
# Event.dispatch. 
DISPATCH = {"NEW_MEETING":_handleNewMeeting,
            "NEW_USER":_handleNewUser,
            "USER_JOINED_LOCATION":_handleJoinedLocation,
            "USER_LEFT_LOCATION": _handleLeftLocation,
            "LOCATION_JOINED_MEETING": _handleLocationJoinedMeeting,
            "LOCATION_LEFT_MEETING": None,
            "NEW_DEVICE": _handleNewDevice,
            "ADD_ACTOR_DEVICE": _handleAddActorDevice
            }

if __name__ == '__main__':
    main()

