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
import os

import mail
import util

import tornado.template as template

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
    # I'm not totally sure why the second case here exists. When will newUser
    # get called and there's already a user object in the results dict?
    if len(event.results)==0:
        newUser = model.User(event.params["name"],\
            email=event.params["email"])
        event.addResult("actor", newUser)
    else:
        newUser = model.User(event.params["name"],
            event.results["actor"]["uuid"])

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
    updateStatusEvent = e.Event("UPDATE_STATUS", event.actor.uuid, None,
        {"status": "joined location", "time": joinedAt})
    event.queue(updateStatusEvent)
    event.params["joinedAt"] = joinedAt
    if location.isInMeeting():
        event.meeting = location.meeting
    
    if event.meeting != None:
        event.meeting.eventHistoryReadable.append(event.actor.name+
        " joined the meeting in location "+location.name)
    
    
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

    # we need to stop the current topic for data purity reasons
    currentTopic = meeting.getCurrentTopic()
    endTopicEvent = e.Event("UPDATE_TOPIC", event.actor.uuid,
        meeting.uuid, 
        params={"topicUUID":currentTopic.uuid, "status":"PAST"})

    # do this first so we don't have a current topic hanging around anymore
    # which will cause lingering issues with the organize-ideas-by-topic
    # code below.
    endTopicEvent.dispatch()

    # do a few sideeffecting things that, if done first, will start breaking
    # any future events related to this meeting.
    meeting.room.currentMeeting = None
    meeting.room = None
    
        
    
    # load the template
    # can probably speed this up by making this a global thing and loading
    # the template once, but for now this is rare + fine.
    loader = template.Loader("templates")
    t = loader.load("timeline.html")
    
    # do some other variable prep work
    metadata = {}
    metadata["meetingStart"] = meeting.eventHistory[0].timestamp
    metadata["meetingEnd"] = meeting.eventHistory[-1].timestamp
    

    # run through all the events to filter out stuff we don't want to show
    # for now, this is just personally created ideas. That shouldn't be
    # available to end-users.
    
    outEvents = []
    
    for event in meeting.eventHistory:
        if event.eventType == EventType.types["NEW_TASK"]:
            if event.params["createInPool"]:
                outEvents.append(event)
        elif event.eventType == EventType.types["RESTART_TOPIC"]:
            # try to do something fancy about removing the "NEW TOPIC" for
            # this topic, so we don't get two entries for it? For now, just
            # exclude it.
            pass
        else:
            outEvents.append(event)
    
    # do a pass on topics, too, sorting them based on start time (if it has
    # one) otherwise, put it at the end.
    
    futureTopics = []
    pastTopics = []
    for topic in meeting.topics:
        if(topic.status == "FUTURE"):
            futureTopics.append(topic)
        else:
            # capture both current and past here
            pastTopics.append(topic)
    
    # now sort pastTopics based on startTime. 
    pastTopics.sort(key=lambda topic:topic.startTime)
    
    # put the lists back together.
    outTopics = pastTopics + futureTopics
    
    
    # now we want to cluster the data around topics, so we have a topic-based
    # view of what happened in the meeting. The data structure will be a list
    # (sorted by time) of dictionaries, where each dictionary has two keys:
    # a topic object, and a list of ideas that happened inside that topic. 
    
    # we'll construct this by maintaining two separate lists. 
    
    # start on the first topic
    curTopic = pastTopics[0]
    topicIndex = 0
    topicsDict = []
    
    curTopicDict = {"topic":curTopic, "ideas":[]}
    
    done = False
    eventIndex = 0
    while not done:
        
        # get the next event (assuming the event index gets incremented,
        # which you can skip if you want to keep processing a previous
        # event. this happens when the topic changes.)
        try:
            event = outEvents[eventIndex]
        except:
            logging.debug("Dropping out of loop - at end of event list.")
            topicsDict.append(curTopicDict)
            
            # check and see if there are any remaining topics. If there are,
            # we need to add them on with empty idea lists.
            
            # if the current eventIndex is not the last item,
            # then we have topics left that don't have events
            # in them, but should still be on the list
            while (topicIndex != len(pastTopics)-1):
                topicIndex = topicIndex+1
                # loop through remaining topics and add them on
                curTopic = pastTopics[topicIndex]
                curTopicDict = {"topic":curTopic, "ideas":[]}
                topicsDict.append(curTopicDict)
                
                
            done = True
        
        # skip anything that's not a new idea or wasn't created in the
        # general pool
        if event.eventType != EventType.types["NEW_TASK"] and \
            not event.params["createInPool"]:
            eventIndex = eventIndex+1
            continue
            
        # loop through all the events. Look only for NEW_TASK events.
        # (side question - what to do about ideas that happen before
        # the first topic starts? for now throw them out.)
        
        # (going to need to think about whether it's a group idea or
        #  not at some point)
        if (curTopic.startTime < event.timestamp and \
            curTopic.stopTime > event.timestamp):
            # if the event is between the current topics start and stop times
            # then add it to the ideas list and move to the next event.
            logging.debug("Adding event " + str(event) + " to cur topic "+ \
                str(curTopic))
            curTopicDict["ideas"].append(event)
            eventIndex = eventIndex+1
        elif (curTopic.stopTime < event.timestamp):
            logging.debug("Found an event beyond the topic's stop time")
            
            # first, save this topic in the main dict
            topicsDict.append(curTopicDict)
            
            # if this is the case, then we need to move onto the next topic
            # without advancing the event counter. 
            if((topicIndex+1) < len(pastTopics)):
                logging.debug("   there are more topics to process, advanting current topic!")
                topicIndex = topicIndex+1
                curTopic = pastTopics[topicIndex]
                
                curTopicDict = {"topic":curTopic, "ideas":[]}
            else:
                # we've hit the end of the topic list, drop out
                done = True
        elif (curTopic.startTime > event.timestamp):
            # this should only happen for events that happen before the first
            # topic starts. Just ignore these.
            logging.debug("Found an event that happens before the topic:" + \
                str(event) + " (before topic " + str(curTopic) + ")")
            eventIndex = eventIndex+1
    
    
    logging.debug("-------- DONE PROCESSING TOPICS + IDEAS----------")
    logging.debug("topicsDict: ")
    logging.debug(topicsDict)
    
    # run it with the current meeting.
    results = t.generate(meeting=meeting, metadata=metadata,events=outEvents,
        topics = outTopics)
    
    # now write it out to disk
    meetingEndTime = int(time.time())
    filename = str(meetingEndTime) + ".html"
    out = open("static/archive/" + filename, 'w')
    
    out.write(results)
    
    
    # now we want to email everyone a link to the file + some personalized
    # information relevant to them. Mainly, we want to send people the list
    # of stuff in their idea drawer. 
    
    # also write this out to disk so we don't lose them in the case of email
    # troubles. 
    os.mkdir("static/archive/" + str(meetingEndTime))
    
    for user in meeting.allParticipants:
        # compose and send the email.
        
        body = "Hi " + user.name + ",\n\n"
        body = body + "You can find the timeline from today's class here:\n\n"
        body = body + "http://" + util.config.get("server", "domain") + \
"/static/archive/" + filename + "\n\n"
            
        body = body + "Here are all the ideas you had in \
your bin: \n"
        
        taskString = ""
        for task in user.tasks:
            taskString = taskString + "   - " + task.text + "\n"
        
        # write the taskString out to disk
        
        taskFile = open("static/archive/" + str(meetingEndTime) + "/" + \
            str(user.email) + ".txt", 'w')
        taskFile.write(taskString)
        taskFile.close()
        
        body = body + taskString
        
        # for now hardcode my email address in, but later use a real one
        mail.sendmail(util.config.get("email", "from_email"), user.name +
            " - today's class timeline", body)
        
    
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
        
        currentTopic = [t for t in
            actor.getMeeting().topics if t.status=="CURRENT"]
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

    # by default, show ideas as created by the user who sent the message
    # but support the ability to specific a specific creator OTHER than the
    # actor. This is important in the classroom context specifically where
    # people can drag and drop ideas onto the pool, but we don't want them
    # to be "created" by the person who dragged them.
    if(event.params["createdBy"]!=None):
        createdBy = event.params["createdBy"].uuid
    else:
        createdBy = event.actor.uuid
    
    # TODO write a real color picker here.
    if len(event.results)==0:
        newTask = model.Task(event.meeting.uuid, createdBy, text,
            color=event.params["color"])
        event.addResult("task", newTask)
    else:
        d=event.results["task"]
        newTask = model.Task(event.meeting.uuid, createdBy, text,
            taskUUID=d["uuid"], createdAt=d["createdAt"],
            color=event.params["color"])
    
    # we're going to hardcode events and make them part of the person
    # who created them. we'll start by queueing up an assignment task 
    # event.queue(e.Event("ASSIGN_TASK", event.actor.uuid, event.meeting.uuid, {"taskUUID":newTask.uuid, "assignedTo":event.actor.uuid, "deassign":False}))
    
    # if the createInPool flag is thrown, create it as an unassigned idea
    # (ie the old way of doing things). otherwise, make it in the box
    # of the user who created it. 
    if(not event.params["createInPool"]):
        newTask.assign(newTask.createdBy, newTask.createdBy, None)
    else:
        # if we're creating in the pool, then we're going to call deassign
        # to make sure it's not owned by anyone.
        if(event.params["assignedBy"]):
            logging.debug("assignedBy: " + str(event.params["assignedBy"]))
            logging.debug("HANDLING POOL DEASSIGN ZONE: " + str(event.params["assignedBy"]))
            newTask.deassign(event.params["assignedBy"])
        else:
            newTask.deassign(event.actor)
    
    
    event.meeting.addTask(newTask)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "created new idea", "time": newTask.createdAt}))
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" created a new idea ("+text+")")
    
    return event

def _handleDeleteTask(event):
    logging.debug(event.params["taskUUID"])
    task = state.get_obj(event.params["taskUUID"], model.Task)
    logging.debug(task)
    deletedAt = time.time()
    
    event.meeting.removeTask(task)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "deleted idea", "time": deletedAt}))
    #needed to keep track of statuses on client-side
    event.params["deletedAt"] = deletedAt
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" deleted idea ("+task.text+")")
    
    return event

def _handleEditTask(event):
    text = event.params["text"]
    task = state.get_obj(event.params["taskUUID"], model.Task)
    editedAt = time.time()
    
    event.meeting.eventHistoryReadable.append(event.actor.name+" changed idea ("+task.text+") to idea ("+text+")")
    
    task.setText(text)
    event.queue(e.Event("UPDATE_STATUS", event.actor.uuid, None, {"status": "edited idea", "time": editedAt}))
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
        event.queue(e.Event("UPDATE_STATUS", assignedBy.uuid, None, {"status": "moved idea", "time": task.assignedAt}))
        event.queue(e.Event("UPDATE_STATUS", assignedTo.uuid, None, {"status": "claimed idea", "time": task.assignedAt}))
        
        event.meeting.eventHistoryReadable.append(assignedBy.name + " moved idea ("+task.text+") to "+assignedTo.name)
    else:
        task.deassign(assignedBy)
        event.queue(e.Event("UPDATE_STATUS", assignedBy.uuid, None, {"status": "deassigned idea", "time": task.assignedAt}))
        
        event.meeting.eventHistoryReadable.append(assignedBy.name + " deassigned idea ("+task.text+")")

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

# the list of required parameters is woefully out of date here. Do we care?
# I think in almost all cases, the handlers aren't actually requiring the 
# other parameters and will fallback gracefully if they're not there.

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

