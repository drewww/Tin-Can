#!/usr/bin/env python
# encoding: utf-8
"""
state.py - maintain the state of the system's rooms, meetings, and users.

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import model
import simplejson as json
import logging
import traceback
import time

from event import *

# This dictionary stores all known major types. This is used primarily so 
# we can cheaply bridge UUIDs into objects. When any of these major types
# is created, it's automatically registered here (via the YarnBaseType
# constructor). 
db = {}

# Stores all the actors that we've ever seen.
actors = set()

# Stores all the rooms.
rooms = set()

def init():
    """Initialize the internal state, loading from disk."""
    pass

def init_test():
    """Initialize the internal state using test data."""
    
    newUserEvent = Event("NEW_USER", params={"name":"Drew"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Paula"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Stephanie"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Ariel"})
    newUserEvent.dispatch()
    
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Garden"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Orange+Green"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"S+M Group Area"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"E14-395"})
    newLocationEvent.dispatch()
    
    newRoomEvent = Event("NEW_ROOM", params={"name":"Mars"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Jupiter"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Venus"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Saturn"})
    newRoomEvent.dispatch()
    
def init_demo():
    """Initialize the internal state for demos"""
    newUserEvent = Event("NEW_USER", params={"name":"Drew"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Paula"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Stephanie"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Ariel"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Josh"})
    newUserEvent.dispatch()
    
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Garden"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Orange+Green"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"S+M Group Area"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"E14-395"})
    newLocationEvent.dispatch()
    
    newRoomEvent = Event("NEW_ROOM", params={"name":"Mars"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Jupiter"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Venus"})
    newRoomEvent.dispatch()
    newRoomEvent = Event("NEW_ROOM", params={"name":"Saturn"})
    newRoomEvent.dispatch()
    
    users = state.get_users()
    locations = state.get_locations()
    rooms = [room for room in state.get_rooms()]
    
    # This is cheating. We should be using events to generate server changes, but
    # we create meetings/topics/tasks "in the past," so we'll just mess with the server state
    # directly. It will be okay since this is only for demo-ing. Doing this will make inconsistent
    # timestamps for events, but we don't use those for anything except the status pages
    
    locations[0].userJoined(users[0])
    locations[0].userJoined(users[1])
    locations[1].userJoined(users[2])
    locations[1].userJoined(users[3])
    locations[2].userJoined(users[4])
    
    #new meeting. I've only created one, hope that's okay.
    meeting = model.Meeting(rooms[0].uuid, startedAt=time.time()-15*60)
    rooms[0].set_meeting(meeting)
    
    locations[0].joinedMeeting(meeting)
    locations[1].joinedMeeting(meeting)
    locations[2].joinedMeeting(meeting)
    
    #new topics
    newTopic = model.Topic(meeting.uuid, users[0].uuid, "topic one",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-14*60)
    meeting.addTopic(newTopic)
    users[0].status=("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[3].uuid, "topic two",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-14*60)
    meeting.addTopic(newTopic)
    users[3].status=("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[2].uuid, "topic three",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-13*60)
    meeting.addTopic(newTopic)
    users[2].status=("created new topic", newTopic.createdAt)
    
    topics = meeting.topics
    
    #changing topic status
    topics[0].setStatus(model.Topic.CURRENT, users[4], time.time()-14*60)
    users[4].status=("edited topic", time.time()-14*60)
    topics[0].setStatus(model.Topic.PAST, users[3], time.time()-8*60)
    users[3].status=("edited topic", time.time()-8*60)
    topics[1].setStatus(model.Topic.CURRENT, users[3], time.time()-8*60)
    users[3].status=("edited topic", time.time()-8*60)
    
    #new tasks
    newTask = model.Task(meeting.uuid, users[1].uuid, "task one", createdAt=time.time()-10*60)
    meeting.addTask(newTask)
    users[1].status=("created new task", newTask.createdAt)
    newTask = model.Task(meeting.uuid, users[0].uuid, "task two", createdAt=time.time()-3*60)
    meeting.addTask(newTask)
    users[0].status=("created new task", newTask.createdAt)
    
    tasks = meeting.tasks
    
    #assigning tasks
    tasks[0].assign(users[2],users[4], time.time()-4*60)
    users[2].status=("assigned task", tasks[0].assignedAt)
    users[4].status=("claimed task", tasks[0].assignedAt)
    
    #since join meeting events aren't being fired, we need to manually set the title
    title = "Meeting with "
    for location in meeting.locations:
        if location.isLoggedIn:
            title = title +location.name+", "
    title = title[0:-2]
    meeting.setTitle(title)

def get_obj(key, type=None):
    """Returns the object of 'type' with that UUID from the object store.
    
    If the type doesn't match the object with that key, or there is no object
    with that key in the database, returns None."""
    
    try:
        obj = db[key];
    except KeyError:
        logging.warning("No object for UUID: %s (class: %s)"%(key, type))
        traceback.print_stack()
        return None
    
    # If no type is specified, assume we don't care what the type of the
    # return is. This is bad form, though - we should ALWAYS be enforcing
    # proper types out of this method.
    if type==None:
        logging.warning("No type specified in get_obj. This is dangerous.\
Key:%s"%key)

        return obj
    
    # Otherwise, check that it's the right type. If it is, return it.
    # If it's not the right type, return None and throw a warning.
    if(isinstance(obj, type)):
        return obj
    else:
        logging.warning("Object with UUID %s not instance of %s" %(key, type))
        traceback.print_stack()
        return None

def put_obj(key, value):
    """Adds an object to the main database."""
    
    # I'm not sure if we're going to need to do anything else in here, but
    # for the sake of symmetry, it makes sense to have both get and put
    # methods. 
    db[key] = value


def add_actor(actor):
    actors.add(actor)

def add_room(room):
    rooms.add(room)

def get_users():
    return [actor for actor in actors if isinstance(actor, model.User)]

def get_locations():
    return [actor for actor in actors if isinstance(actor, model.Location)]

def get_rooms():
    return rooms

def get_meetings():
    return [room.currentMeeting for room in get_rooms()
        if room.currentMeeting != None]
    
def get_devices():
    """Return all current known devices. 
    
    Doesn't maintain this in memory, constructs it from scratch based
    on the list of known actors."""
    
    allDevices = set()
    
    for actor in actors:
        allDevices = allDevices | actor.getDevices()
    
    return allDevices


if __name__ == '__main__':
    init_test()
    
    print "users: " + str(users)
    print "rooms: " + str(rooms)
    print "users json: " + json.dumps(get_logged_in_users(), cls=model.YarnModelJSONEncoder)

