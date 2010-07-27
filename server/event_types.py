#!/usr/bin/env python
# encoding: utf-8
"""
event_types.py

Defines methods for handling different event types. None of these should be
called directly - they are always called by the event dispatch system in 
event.py. Also defines known event types and how to execute them. 

Created by Drew Harry on 2010-07-25.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import model
import logging
import state

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
    
def _handleNewLocation(event):
    newLocation = model.Location(event.params["name"])
    state.add_actor(newLocation)
    
    event.addResult("actor", newLocation)
    return event

def _handleNewDevice(event):
    device = model.Device()

    event.addResult("device", device)

    return event

def _handleAddActorDevice(event):
    
    # connects devices with their actors.
    actor = event.params["actor"]
    device = event.params["device"]
    
    # need to remove device from previous actor.
    
    if device.actor!=None:
        device.actor.removeDevice(device)
    
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
    location = event.actor
    meeting = event.params["meeting"]
    
    location.joinedMeeting(meeting)
    return event

def _handleLocationLeftMeeting(event):
    location = event.actor
    meeting = event.params["meeting"]

    meeting.locationLeft(location)
    return event

def _handleNewTopic(event):
    text = event.params["text"]
    
    # TODO write a real color picker here.
    newTopic = model.Topic(event.meeting.uuid, event.actor.uuid, text,
        status=model.Topic.FUTURE, color="006600")
        
    event.meeting.addTopic(newTopic)
    event.addResult("topic", newTopic)
    return event
    
def _handleDeleteTopic(event):
    text = event.params["text"]
    topic = state.get_obj(event.params["topicUUID"], Topic)
    
    event.meeting.removeTopic(topic)
    
    return event
    
def _handleUpdateTopic(event):
    topic = state.get_obj(event.params["topicUUID"], Topic)
    status = event.params["status"]
    
    topic.setStatus(status)
    
    return event

def _handleTopicList(event):
    logger.warning("Topic list not implemented.")
    return event



# This class just wraps the different features of an event into a nice 
# container. Different events expect different parameters and are dispatched
# differently, and this puts all those differences in one concise place.
class EventType:
    types = {}

    def __init__(self, type, params, handler, isGlobal, requiresActor):
        self.type = type
        self.params = params
        self.handler = handler
        
        # global events have two features:
        # 1. They don't require a meetingUUID
        # 2. They are dispatched to all connected users, not people in a
        #    specific meeting.
        
        self.isGlobal = isGlobal
        self.requiresActor = requiresActor

        EventType.types[self.type] = self

    def __str__(self):
        return self.type


# Defines each event type, what parameters it expects, the name of its
# handler, whether or not it is a global event, and whether it requires
# an actor to be defined.

EventType("NEW_MEETING",        ["room"],   _handleNewMeeting,  True,   True)
EventType("NEW_USER",           ["name"],   _handleNewUser,     True,   False)
EventType("NEW_LOCATION",       ["name"],   _handleNewLocation, True,   False)

EventType("NEW_DEVICE",         [],         _handleNewDevice,   True,   True)
EventType("ADD_ACTOR_DEVICE",   ["actor", "device"], _handleAddActorDevice,
    True, True)


EventType("USER_JOINED_LOCATION",   ["location"], _handleJoinedLocation, True,
    True)
EventType("USER_LEFT_LOCATION",     ["location"], _handleLeftLocation,   True,
    True)

EventType("LOCATION_JOINED_MEETING",["meeting"], _handleLocationJoinedMeeting,
    True, True)
EventType("LOCATION_LEFT_MEETING",  ["meeting"], _handleLocationLeftMeeting,
    True, True)

EventType("NEW_TOPIC",      ["text"],               _handleNewTopic, False,
    True)
EventType("DELETE_TOPIC",   ["topicUUID"],          _handleDeleteTopic, False,
    True)
EventType("UPDATE_TOPIC",   ["topicUUID", "status"],_handleUpdateTopic, False,
    True)
EventType("SET_TOPIC_LIST", ["text"],               _handleTopicList, False,
    True)