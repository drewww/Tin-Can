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
import time
import event as e

# DISPATCH METHODS
# These methods will not be called by anyone other than the event dispatch
# method. They determine what happens to internal state based on the event.

def _handleNewMeeting(event):
    if len(event.results)!=0:
        d = event.results["meeting"]
        logging.debug(d)
        newMeeting = model.Meeting(event.params["room"], d["title"],
            d["uuid"], d["startedAt"], d["isNamed"])
        
    else:
        newMeeting = model.Meeting(event.params["room"])
    
    # once we have the meeting, push it back into the event object.
    # pushing it into params because the outer meeting value is
    # just for specifying which meeting an event is taking place in, 
    # and this event type happens outside of a meeting context.
        event.addResult("meeting", newMeeting)
    
    # now register that meeting with the room.
    room = state.get_obj(event.params["room"], model.Room)
    room.set_meeting(newMeeting)
    
    # add this event to the meeting, so it's included at the beginning of
    # every meeting history.
    newMeeting.eventHistory.append(event)
    newMeeting.eventHistoryReadable.append("Meeting was created")
    
    return event

def _handleLeftRoom(event):
    event.meeting.userLeft(event.actor)
    
    # We DON'T need to include the actor in the result object (as above)
    # because clients will already know about this actor, so the UUID in the
    # event itself is enough.
    return event
    
def _handleNewUser(event):
    if len(event.results)==0:
        newUser = model.User(event.params["name"])
        event.addResult("actor", newUser)
    else:
        newUser = model.User(event.params["name"], event.results["actor"]["uuid"])

    # Make sure to do this for new locations, too. 
    state.add_actor(newUser)
    
    
    return event

def _handleNewRoom(event):
    if len(event.results)==0:
        newRoom = model.Room(event.params["name"])
        event.addResult("room", newRoom)
    else:
        newRoom = model.Room(event.params["name"], event.results["room"]["uuid"])
    
    state.add_room(newRoom)
    return event

def _handleNewLocation(event):
    if len(event.results)==0:
        newLocation = model.Location(event.params["name"])
        event.addResult("actor", newLocation)
    else:
        newLocation = model.Location(event.params["name"], event.results["actor"]["uuid"])
    
    state.add_actor(newLocation)
    
    return event

def _handleNewDevice(event):
    if len(event.results)==0:
        device = model.Device()
        event.addResult("device", device)
    else:
        device = model.Device(event.results["device"]["uuid"])

    return event

def _handleAddActorDevice(event):
    
    # connects devices with their actors.
    actor = state.get_obj(event.params["actor"], model.Actor)
    device = state.get_obj(event.params["device"], model.Device)
    
    # need to remove device from previous actor.
    
    if device.actor!=None:
        device.actor.removeDevice(device)
    
    actor.addDevice(device)
    return event

def _handleDeviceLeft(event):
    device = state.get_obj(event.params["device"], model.Device)
    device.logout()
    
    return event

def _handleJoinedLocation(event):
    location = state.get_obj(event.params["location"], model.Location)
    location.userJoined(event.actor)
    joinedAt = time.time()
    updateStatusEvent = e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "joined location", "time": joinedAt})
    event.queue(updateStatusEvent)
    event.params["joinedAt"] = joinedAt
    if location.isInMeeting():
        event.meeting = location.meeting
    
    if event.meeting != None:
        event.meeting.eventHistoryReadable.append(event.actor.name+
        " joined the meeting in location "+location.name)
    
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
    location = state.get_obj(event.params["location"], model.Location)
    location.userLeft(event.actor)
    
    if (len(location.getUsers())==0 and location.isInMeeting()):
        locationLeftMeetingEvent = e.Event("LOCATION_LEFT_MEETING",
        location.uuid, None, {"meeting":location.meeting.uuid})
        event.queue(locationLeftMeetingEvent)

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
    meeting = state.get_obj(event.params["meeting"], model.Meeting)
    
    location.joinedMeeting(meeting)
    
    if not meeting.isNamed:
        title = "Meeting with "
        for location in meeting.locations:
            if location.isLoggedIn:
                title = title +location.name+", "
        title = title[0:-2]
        editMeetingEvent = e.Event("EDIT_MEETING", None, None, 
        {"meeting":meeting.uuid, "title": title})
        event.queue(editMeetingEvent)
    
    meeting.eventHistoryReadable.append(location.name + " joined the meeting")
    
    return event

def _handleLocationLeftMeeting(event):
    location = event.actor
    meeting = state.get_obj(event.params["meeting"], model.Meeting)
    meeting.locationLeft(location)
    
    if (len(meeting.locations)==0):
        endMeetingEvent = e.Event("END_MEETING", event.actor.uuid, None, 
        {"meeting": meeting.uuid})
        event.queue(endMeetingEvent)
    else:
        if not meeting.isNamed:
            title = "Meeting with "
            for location in meeting.locations:
                if location.isLoggedIn:
                    title = title +location.name+", "
            title = title[0:-2]
            editMeetingEvent = e.Event("EDIT_MEETING", None, None, 
            {"meeting":meeting.uuid, "title": title})
            event.queue(editMeetingEvent)
    
    meeting.eventHistoryReadable.append(location.name + " left the meeting")
    
    return event
    
def _handleEndMeeting(event):
    meeting = state.get_obj(event.params["meeting"], model.Meeting)
    
    meeting.room.currentMeeting = None
    meeting.room = None
    
    return event
    
def _handleEditMeeting(event):
    meeting = state.get_obj(event.params["meeting"], model.Meeting)
    title = event.params["title"]
    
    meeting.setTitle(title)
    
    meeting.eventHistoryReadable.append("Meeting name changed to "+title)
    return event

def _handleNewTopic(event):
    text = event.params["text"]
    
    # TODO write a real color picker here.
    if len(event.results)==0:
        newTopic = model.Topic(event.meeting.uuid, event.actor.uuid, text,
            status=model.Topic.FUTURE, color="006600")
        event.addResult("topic", newTopic)
    else:
        logging.debug(event.results)
        d=event.results["topic"]
        newTopic = model.Topic(event.meeting.uuid, event.actor.uuid, text, 
            status=model.Topic.FUTURE, color=d["color"], topicUUID=d["uuid"], 
            createdAt=d["createdAt"])
        
    event.meeting.addTopic(newTopic)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "created new topic", "time": newTopic.createdAt}))
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" created new topic ("+text+")")
    
    return event
    
def _handleDeleteTopic(event):

    topic = state.get_obj(event.params["topicUUID"], model.Topic)
    deletedAt = time.time()
    
    event.meeting.removeTopic(topic)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "deleted topic", "time": deletedAt}))
    #needed to keep track of statuses on client-side
    event.params["deletedAt"] = deletedAt
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" deleted topic ("+topic.text+")")
    
    return event
    
def _handleUpdateTopic(event):
    
    # in this handler, we need to manage some higher level logic.
    # We need to make sure that we keep the overall state proper.
    # IF there's a current topic open, AND the request is to
    # start a new topic, we want to close out the old topic
    # before starting the new one.

    topic = state.get_obj(event.params["topicUUID"], model.Topic)
    logging.info("Updating topic %s to have status %s", topic, event.params["status"])
    status = event.params["status"]
    editedAt = time.time()
    actor = event.actor

    # check and see if we're trying to start a topic.
    if(status=="CURRENT"):
        # now go looking for the current item
        currentTopic = [topic for topic in
            actor.getMeeting().topics if topic.status=="CURRENT"]
        if len(currentTopic) > 1:
            logging.warning("Found multiple current topics. Badness.")
        elif len(currentTopic) == 1:
            currentTopic = currentTopic[0]
            
            logging.debug("Found current topic, setting its status to"
                +" PAST")
            updateCurrentTopicEvent = e.Event("UPDATE_TOPIC", actor.uuid,
                actor.getMeeting().uuid,
                params={"topicUUID":currentTopic.uuid,
                "status":"PAST"})
            updateCurrentTopicEvent.dispatch()
        else:
            logging.debug("No current topic found, continuing.")
    
    # now we can set the target topic to its target status.)
    topic.setStatus(status, event.actor, None)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None,
        {"status": "updated topic", "time": editedAt}))
    #needed to keep track of statuses on client-side
    event.params["editedAt"] = editedAt
    
    event.meeting.eventHistoryReadable.append(event.actor.name+
        " changed the status of topic ("+ topic.text+") to "+status)
    
    return event
    
def _handleRestartTopic(event):
    topic = state.get_obj(event.params["topicUUID"], model.Topic)
    logging.debug("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
    
    # if it's a past topic, create a new one and make it current.
    # if it's a future topic, just make it current
    # if it's a current topic, do nothing
    if topic.status == model.Topic.PAST:
        
        newTopicEvent = e.Event("NEW_TOPIC", event.actor.uuid, event.meeting.uuid, {"text": topic.text})
        newTopicEvent = newTopicEvent.dispatch()
        topic = newTopicEvent.results["topic"]
        event.queue(e.Event("UPDATE_TOPIC", event.actor.uuid, event.meeting.uuid, {"topicUUID": topic.uuid, "status": model.Topic.CURRENT}))
    elif topic.status == model.Topic.FUTURE:
        # if it's a future topic, we shouldn't be getting a restart request at
        # all. filter these out before they get this far.
        pass
    
    return event
    

def _handleTopicList(event):
    logger.warning("Topic list not implemented.")
    return event

def _handleNewTask(event):
    text = event.params["text"]

    # TODO write a real color picker here.
    if len(event.results)==0:
        newTask = model.Task(event.meeting.uuid, event.actor.uuid, text)
        event.addResult("task", newTask)
    else:
        d=event.results["task"]
        newTask = model.Task(event.meeting.uuid, event.actor.uuid, text,
            taskUUID=d["uuid"], createdAt=d["createdAt"])

    event.meeting.addTask(newTask)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "created new task", "time": newTask.createdAt}))
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" created a new task ("+text+")")
    
    return event

def _handleDeleteTask(event):
    logging.debug(event.params["taskUUID"])
    task = state.get_obj(event.params["taskUUID"], model.Task)
    logging.debug(task)
    deletedAt = time.time()
    
    event.meeting.removeTask(task)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "deleted task", "time": deletedAt}))
    #needed to keep track of statuses on client-side
    event.params["deletedAt"] = deletedAt
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" deleted task ("+task.text+")")
    
    return event

def _handleEditTask(event):
    text = event.params["text"]
    task = state.get_obj(event.params["taskUUID"], model.Task)
    editedAt = time.time()
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" changed task ("+task.text+") to task ("+text+")")
    
    task.setText(text)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "editted task", "time": editedAt}))
    #needed to keep track of statuses on client-side
    event.params["editedAt"] = editedAt
    
    
    
    return event
    
def _handleAssignTask(event):
    task = state.get_obj(event.params["taskUUID"], model.Task)
    task.assignedAt = time.time()
    
    assignedBy = state.get_obj(event.actor.uuid, model.Actor)
    
    deassign = event.params["deassign"]

    if(not deassign):
        assignedTo = state.get_obj(event.params["assignedTo"], model.User)
        task.assign(assignedBy,assignedTo, None)
        event.queue(e.Event("UPDATE_STATUS", assignedBy.uuid, None, {"status": "assigned task", "time": task.assignedAt}))
        event.queue(e.Event("UPDATE_STATUS", assignedTo.uuid, None, {"status": "claimed task", "time": task.assignedAt}))
        
        event.meeting.eventHistoryReadable.append(assignedBy.name + " assigned task ("+task.text+") to "+assignedTo.name)
    else:
        task.deassign(assignedBy)
        event.queue(e.Event("UPDATE_STATUS", assignedBy.uuid, None, {"status": "deassigned task", "time": task.assignedAt}))
        
        event.meeting.eventHistoryReadable.append(assignedBy.name + " deassigned task ("+task.text+")")

    event.params["assignedAt"]=task.assignedAt
    return event
    
def _handleHandRaise(event):
    event.actor.handRaised =  not event.actor.handRaised
    
    return event
    
def _handleUpdateStatus(event):
    event.actor.setStatus(event.params["status"], event.params["time"])
    logging.debug("status now: " + str(event.actor.status))
    
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
EventType("NEW_ROOM",           ["name"],   _handleNewRoom,     True,   False)

EventType("NEW_DEVICE",         [],         _handleNewDevice,   True,   True)
EventType("ADD_ACTOR_DEVICE",   ["actor", "device"], _handleAddActorDevice,
    True, True)
EventType("DEVICE_LEFT",        ["device"], _handleDeviceLeft,  True,   False)


EventType("USER_JOINED_LOCATION",   ["location"], _handleJoinedLocation, True,
    True)
EventType("USER_LEFT_LOCATION",     ["location"], _handleLeftLocation,   True,
    True)

EventType("LOCATION_JOINED_MEETING",["meeting"], _handleLocationJoinedMeeting,
    True, True)
EventType("LOCATION_LEFT_MEETING",  ["meeting"], _handleLocationLeftMeeting,
    True, True)
    
EventType("EDIT_MEETING", ["meeting", "title"], _handleEditMeeting, True, False)
EventType("END_MEETING", ["meeting"], _handleEndMeeting, True, True)

EventType("NEW_TOPIC",      ["text"],               _handleNewTopic, True,
    True)
EventType("DELETE_TOPIC",   ["topicUUID"],          _handleDeleteTopic, True,
    True)
EventType("UPDATE_TOPIC",   ["topicUUID", "status"],_handleUpdateTopic, True,
    True)
EventType("RESTART_TOPIC",   ["topicUUID"]       ,_handleRestartTopic, True,
    True)
EventType("SET_TOPIC_LIST", ["text"],               _handleTopicList, True,
    True)

EventType("NEW_TASK",      ["text"],                _handleNewTask, True,
    True)
EventType("DELETE_TASK",   ["taskUUID"],            _handleDeleteTask, True,
    True)
EventType("EDIT_TASK",   ["taskUUID", "text"],      _handleEditTask, True,
    True)
EventType("ASSIGN_TASK", ["taskUUID"],_handleAssignTask, True,
    True)
    
EventType("HAND_RAISE", [], _handleHandRaise, True, True)
EventType("UPDATE_STATUS", ["status", "time"], _handleUpdateStatus, True, True)

