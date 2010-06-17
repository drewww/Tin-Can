#!/usr/bin/env python
# encoding: utf-8
"""
types.py

Defines the basic types for the server:
 * room
 * meeting
 * user
 * task
 * topic

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import uuid
import time
import simplejson as json
import logging

import state
import event

class YarnBaseType(object):
    """Identify object with a UUID and register it with the store."""
    
    def __init__(self):
        # If one of the subclasses has already set this, move on. If it was
        # left as None, then we'll generate a new UUID for it. 
        if(self.uuid==None):
            self.uuid = str(uuid.uuid4())
        
        # Register the new object with the main object store.
        state.put_obj(self.uuid, self)
        
    def getDict(self):
        return {"uuid":self.uuid}
    
    def getJSON(self):
        """Return a JSON representation of the type."""
        return json.dumps(self.getDict())
        
    # TODO do we ever need to del these things? if so, overload that operator
    # here and make sure to pull the object out of obj. 

class Room(YarnBaseType):
    """Store the room-related information."""

    def __init__(self, name, roomUUID=None, currentMeeting=None):
        self.uuid = roomUUID
        YarnBaseType.__init__(self)
        
        self.name = name
        
        if(currentMeeting != None):
            self.currentMeeting = get_obj(currentMeeting, Meeting)
        else:
            self.currentMeeting = None
    
    def set_meeting(self, meeting):
        if(self.currentMeeting!=None):
            logging.error("Meeting was just set on this room (%s) but a \
            meeting was already in progress: %s" %(self.name,
            self.currentMeeting))
            
        self.currentMeeting = meeting
        logging.info("%s is now home to a new meeting starting now %s"
            %(self.name, meeting))
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["name"] = self.name
        
        if(self.currentMeeting!=None):
            d["currentMeetingUUID"] = self.currentMeeting.uuid
        else:
            d["currentMeetingUUID"] = None
            
        return d
        
class Meeting(YarnBaseType):
    """Store meeting-related information."""

    def __init__(self, roomUUID, title=None, meetingUUID=None,
        startedAt=None):
        self.uuid = meetingUUID
        YarnBaseType.__init__(self)
        self.room = state.get_obj(roomUUID, Room)
        self.title = title
        
        if startedAt==None:
            self.startedAt = time.time()
        else:
            self.startedAt = startedAt
            
        self.endedAt = None
        self.isLive = False
        self.allParticipants = []
        self.currentParticipants = []
        
        self.eventHistory = []
        
    def participantJoined(self, user):
        logging.info("User %s joined meeting %s in room %s"%(user.name,
            self.title, self.room.name))
        
        self.allParticipants.append(user)
        self.currentParticipants.append(user)
        
        user.inMeeting = self
        
        
    
    def participantLeft(self, user):
        logging.info("User %s left meeting %s in room %s"%(user.name,
            self.title, self.room.name))
                
        self.currentParticipants.remove(user)
        
        user.inMeeting = None
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["endedAt"] = self.endedAt
        d["isLive"] = self.isLive
        
        # We are pointedly NOT including eventHistory in here. It's 
        # duplicating information that will live in the on-disk caches anyway.
        
        # Should these be just UUIDs of participants? Doing everything about
        # them, for now.
        d["allParticipants"] = self.allParticipants
        d["currentParticipants"] = self.currentParticipants
        return d
    
    def sendEvent(self, eventToSend):
        """Sends the 'event' to all participants in 'meeting'."""
        
        logging.info("About to send to all users in meeting: %s"
            %eventToSend.meeting.currentParticipants)
            
        
        if(eventToSend.eventType == "JOINED"):
            # This is tricky - we want to (in the JOINED event message)
            # include the history of everything that's happened in the meeting
            # so they can get up to speed. 
            
            # first, throw all past events onto that user's queue first.
            logging.debug("Putting all past meeting events into the new\
            user's queue. Total events: %d"%len(self.eventHistory))
            event.sendEventsToUsers([eventToSend.user], self.eventHistory)
            
            # then send everyone (including the new user) a normal JOINED
            # event.
            event.sendEventsToUsers(self.currentParticipants, [eventToSend])
        else:
            # This is the normal path for all other event types.
            event.sendEventsToUsers(self.currentParticipants, [eventToSend])

        # Save the event in the meeting history.
        self.eventHistory.append(eventToSend)
        

class User(YarnBaseType):
    """Store meeting-related information."""
    
    def __init__(self, name=None, userUUID=None, isTable=False,
        localUsers = []):
        self.uuid = userUUID
        
        YarnBaseType.__init__(self)
        
        self.name = name
        self.inMeeting = None
        self.loggedIn = False
        self.status = None
        
        # this flag sets of this user represents an iPad being logged
        # in, and localUsers tracks what users are known to be local
        # to that iPad.
        self.isTablet = isTable
        self.localUsers = localUsers
        
        # Users have some connection tracking components, too. If we want
        # to send a message to a specific user, we need a way to reach them.
        # We'll keep track of the latest connection from that user here,
        # plus we'll keep a queue of events that this user should be notified
        # of so while we're waiting for them to connect again we don't lose
        # events. When they do reconnect, we'll flush that queue.
        self.connection = None
        self.eventQueue = []
        
    def setConnection(self, connection):
        
        # if we're already holding onto a connection, release it
        if(self.connection != None):
            try:
                self.connection.finish()
            except:
                logging.warning("Tried to double-close a connection \
                 in setConnection  user:%s"%
                    self.name)
            finally:
                # don't strictly need to do this because it's about to be
                # set again, but it's good form to pair every .finish
                # with a None-ing of the connection object.
                self.connection = None
            
        # set the new connection
        self.connection = connection
        
        # mark ourselves as logged in.
        # TODO figure out how to mark a user as logged out. 
        #      (A: flip this when the event queue gets too long,
        #          or just use that as the cue to check how long
        #          it's been since they connected. 5 seconds is
        #          enough to call it, since it really should be
        #          ms between connections.)
        self.loggedIn = True
        
        # TODO check to see if we have anything in the event queue. If we do,
        # flush the queue and close the connection.
        
        logging.debug("Set connection for %s to %s"%(self.name, connection))
        
        # check to see if events have queued up during our absence of a
        # connection. 
        if(len(self.eventQueue) > 0):
            logging.debug("Flushing existing event queue into new\
                connection.")
            self.flushQueue()
        
        
    
    def enqueueEvent(self, event):
        """Enqueue the specified event for transmission to this user.
        
        Queued events will be sent to the user immediately if they have
        a current connection, otherwise they'll be bundled and sent to
        the user when they next reconnect."""
        
        self.eventQueue.append(event)
        logging.debug("Enqueued event. Queue length now %d"%
            len(self.eventQueue))
        
        if(self.connection!=None):
            self.flushQueue()
    
    def flushQueue(self):
        """Dumps the contents of the queue onto the current connection.
        
        Most of the time this is just going to be one event, but there are
        a few situations when it might be more. If there's network latency
        and a client doesn't have a connection for a few seconds, a few events
        might happen at once, and we want to make sure they make it to all 
        clients. The other situation is when a user joins an existing meeting:
        the system will then dump the entire event history of that meeting
        into the new users' queue so they can resimulate the meeting process
        all the way up to the present."""
        
        if(self.connection==None):
            logging.error("Tried to flush queue on %s but there was no \
                open connection for the user."%self.name)
            return
        
        logging.debug("Flushing queue of %d events on %s"%
            (len(self.eventQueue),self.name))
        self.connection.write(json.dumps(self.eventQueue,
            cls=YarnModelJSONEncoder))
        self.connection.finish()
        self.connection = None
        
        # TODO wait for ACK from the client that it received these events.
        self.eventQueue = []
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["name"] = self.name
        if(self.inMeeting!=None):
            d["inMeetingUUID"] = self.inMeeting.uuid
        else:
            d["inMeetingUUID"] = None
            
        d["loggedIn"] = self.loggedIn
        d["status"] = self.status
        return d


class MeetingObjectType(YarnBaseType):
    """Defines some basic properties that are shared by meeting objects."""

    def __init__(self, creatorUUID, meetingUUID):
        YarnBaseType.__init__(self)

        # TODO we almost certainly want to unswizzle these UUIDS
        # to their actual objects. When we do that, we'll need to
        # switch all the getDict methods to getting the UUID instead
        # of just taking the whole object like it does now.
        self.createdBy = creatorUUID
        self.createdAt = time.time()

        self.meeting = meetingUUID
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["createdBy"] = self.createdBy.uuid
        d["createdat"] = self.createdAt
        d["meeting"] = self.meeting.uuid
        return d

class Task(MeetingObjectType):
    """Store information about a task."""
    
    def __init__(self, meetingUUID, creatorUUID, text):
        self.uuid=None

        MeetingObjectType.__init__(self, creatorUUID, meetingUUID)
        self.text = text
        self.ownedBy = None
        
    def getDict(self):
        d = MeetingObjectType.getDict(self)
        d["text"] = self.text
        d["ownedBy"] = self.ownedBy.uuid
        return d

class Topic(MeetingObjectType):
    """Store information about a topic."""

    def __init__(self, meetingUUID, creatorUUID, text, timeStarted=None,
        timeEnded=None):
        self.uuid=None

        MeetingObjectType.__init__(self, creatorUUID, meetingUUID)
        self.text = text
        self.timeStarted = timeStarted
        self.timeEnded = timeEnded

    def getDict(self):
        d = MeetingObjectType.getDict(self)
        d["text"] = self.text
        d["timeStarted"] = self.timeStarted
        d["timeEnded"] = self.timeEnded
        return d


class YarnModelJSONEncoder(json.JSONEncoder):
    """JSON Encoder for Yarn model objects."""
    def default(self, obj):
        if isinstance(obj, YarnBaseType) or isinstance(obj, event.Event):
            # use the getDict method for model objects, since we can't
            # encode python objects to JSON directly.
            return obj.getDict()
        return json.JSONEncoder.default(self, obj)

if __name__ == "__main__":
    # try making some new things and spitting them back out again.
    room1 = Room("Garden")
    room2 = Room("Orange and Green")
    
    print "room 1: " + str(room1)
    print "room 1 json: " + str(room1.getJSON())
    print "obj store: " + str(db)
    
