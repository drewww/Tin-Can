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
    
    """Initialize the internal state for demos"""
    newUserEvent = Event("NEW_USER", params={"name":"Drew", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Chris", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Stephanie", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Matt", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Josh", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Andrea", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Charlie", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Jaewoo", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Wu-Hsi", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Jon", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Santiago", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Claudia", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Mikell", "email":"example@example.com"})
    newUserEvent.dispatch()
    newUserEvent = Event("NEW_USER", params={"name":"Ig-Jae", "email":"example@example.com"})
    newUserEvent.dispatch()




    
    newLocationEvent = Event("NEW_LOCATION", params={"name":"E15-363"})
    newLocationEvent.dispatch()
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Garden Conf Room"})
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

def init_emerson():
    # load in all the users from a text file, so we're not checking
    # in all their information.
    
    with open("emerson.csv", "r") as f:
        for line in f:
            # split the line on comma
            params = line.split(",")
            
            newUserEvent = Event("NEW_USER", params={"name":params[0],
                "email":params[1]})
            newUserEvent.dispatch()
            
    newLocationEvent = Event("NEW_LOCATION", params={"name":"Tufte 1114"})
    newLocationEvent.dispatch()
    
    newRoomEvent = Event("NEW_ROOM", params={"name":"Mars"})
    newRoomEvent.dispatch()
    
    
    

def init_demo():
    init_test()
    
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
    locations[1].userJoined(users[5])
    locations[1].userJoined(users[6])
    locations[1].userJoined(users[7])
    locations[2].userJoined(users[8])
    locations[2].userJoined(users[9])
    locations[2].userJoined(users[10])
    locations[2].userJoined(users[11])
    locations[2].userJoined(users[12])
    locations[2].userJoined(users[13])
    
    #new meeting. I've only created one, hope that's okay.
    meeting = model.Meeting(rooms[0].uuid, startedAt=time.time()-15*60)
    rooms[0].set_meeting(meeting)
    
    locations[0].joinedMeeting(meeting)
    locations[1].joinedMeeting(meeting)
    locations[2].joinedMeeting(meeting)
    
    #new topics
    newTopic = model.Topic(meeting.uuid, users[0].uuid, "what is postmodernism?",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-14*60)
    meeting.addTopic(newTopic)
    users[0].setStatus("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[3].uuid, "the end of modernism",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-14*60)
    meeting.addTopic(newTopic)
    users[3].setStatus("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[2].uuid, "what images mean",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-13*60)
    meeting.addTopic(newTopic)
    users[2].setStatus("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[2].uuid, "media and spectacle",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-13*60)
    meeting.addTopic(newTopic)
    users[2].setStatus("created new topic", newTopic.createdAt)
    newTopic = model.Topic(meeting.uuid, users[2].uuid, "power and agency",
        status=model.Topic.FUTURE, color="006600", createdAt=time.time()-13*60)
    meeting.addTopic(newTopic)
    users[2].setStatus("created new topic", newTopic.createdAt)


    
    topics = meeting.topics
    
    #changing topic status
    topics[0].setStatus(model.Topic.CURRENT, users[4], time.time()-14*60)
    users[4].setStatus("edited topic", time.time()-14*60)
    topics[0].setStatus(model.Topic.PAST, users[3], time.time()-8*60)
    users[3].setStatus("edited topic", time.time()-8*60)
    topics[1].setStatus(model.Topic.CURRENT, users[3], time.time()-8*60)
    users[3].setStatus("edited topic", time.time()-8*60)
    topics[1].setStatus(model.Topic.PAST, users[3], time.time()-2*60)
    users[2].setStatus("edited topic", time.time()-2*60)
    topics[2].setStatus(model.Topic.CURRENT, users[3], time.time()-2*60)
    users[2].setStatus("edited topic", time.time()-2*60)

    
    #new tasks
    newTask = model.Task(meeting.uuid, users[1].uuid, "does postmodernism mean the end of history?", createdAt=time.time()-10*60)
    meeting.addTask(newTask)                                 
    users[1].setStatus("created new idea", newTask.createdAt)
    newTask = model.Task(meeting.uuid, users[0].uuid, "does Baudrillard really deny agency to human actors?", createdAt=time.time()-3*60)
    meeting.addTask(newTask)
    users[0].setStatus("created new idea", newTask.createdAt)
    newTask = model.Task(meeting.uuid, users[0].uuid, "can a media event become so large it becomes a spectacle?", createdAt=time.time()-3*60)
    meeting.addTask(newTask)
    users[0].setStatus("created new idea", newTask.createdAt)
    newTask = model.Task(meeting.uuid, users[0].uuid, "Images are no different than language - they make meaning through reading", createdAt=time.time()-3*60)
    meeting.addTask(newTask)
    users[0].setStatus("created new idea", newTask.createdAt)
    # newTask = model.Task(meeting.uuid, users[0].uuid, "update the group website with the latest photo", createdAt=time.time()-3*60)
    # meeting.addTask(newTask)
    # users[0].setStatus("created new task", newTask.createdAt)

    
    tasks = meeting.tasks
    
    #assigning tasks
    tasks[0].assign(users[2],users[4], time.time()-4*60)
    users[2].setStatus("assigned idea", tasks[0].assignedAt)
    # users[4].setStatus("claimed task", tasks[0].assignedAt)
    
    tasks[1].assign(users[3], users[3], time.time()-3*60)
    
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


def end_all_meetings():
    """Sends END_MEETING events to all open meetings."""
    
    for room in rooms:
        if(room.currentMeeting != None):
            
            logging.info("Sending an END_MEETING event to " + \
                str(room.currentMeeting.uuid))
            
            # we need to fake the actor UUID somehow, so we'll just pick
            # a random location in the meeting and blame it on that.
            actor = list(room.currentMeeting.locations)[0]
            
            endMeetingEvent = e.Event("END_MEETING", actor.uuid, None,
            {"meeting": room.currentMeeting.uuid})
            endMeetingEvent.dispatch()
            
    
    logging.info("All meetings have been ended.")

if __name__ == '__main__':
    init_test()
    
    print "users: " + str(users)
    print "rooms: " + str(rooms)
    print "users json: " + json.dumps(get_logged_in_users(), cls=model.YarnModelJSONEncoder)

