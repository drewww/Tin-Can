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
import copy

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
        
        # currentMeeting? Erm. why not just meeting like the pattern
        # everywhere else? TODO think about changing this over for consistency
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
            d["currentMeeting"] = self.currentMeeting.uuid
        else:
            d["currentMeeting"] = None
            
        return d
        
    def __str__(self):
        return "[room.%s %s meet:%s]"%(self.uuid[0:6], self.name,
            str(self.currentMeeting))
        
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
        self.allParticipants = set()
        
        self.locations = set()
                
        self.eventHistory = []
        
        self.topics = []
        
        
    def userJoinedLocation(self, user, location):
        logging.info("User %s joined meeting %s in room %s"%(user.name,
            self.title, self.room.name))
        
        self.allParticipants.add(user)

    def userLeftLocation(self, user, location):
        logging.info("User %s left meeting %s in room %s"%(user.name,
            self.title, self.room.name))

    def locationJoined(self, location):
        logging.info("Location %s JOINED %s@%s with %d users"%(location.name,
        self.title, self.room.name, len(location.users)))
        
        self.locations.add(location)
        
        # add all the users in this location to the list of all users this
        # meeting has ever seen. 
        for user in location.getUsers():
            self.allParticipants.add(user)
    
    def locationLeft(self, location):
        logging.info("Location %s LEFT %s@%s with %d users"%(location.name,
        self.title, self.room.name, len(location.users)))

        self.locations.remove(location)
        location.meeting=None
        
    def getCurrentParticipants(self):
        """Returns a list of the current list of Users in this meeting."""
        
        currentParticipants = set()
        for location in self.locations:
            currentParticipants = currentParticipants.union(
                location.getUsers())
        
        return currentParticipants
        
    def addTopic(self, topic):
        self.topics.append(topic)
        
    def removeTopic(self, topic):
        self.topics.remove(topic)
    
    def setTopicList(self, topicList):
        # we need to figure out exactly what this is going to do. Is it going
        # to get a UUID list or a list of objects?
        pass
        
        
    
    def getDevices(self):
        devices = set()
        
        for location in self.locations:
            # there's probably some tricky list comprehension way to do this,
            # but I don't feel like working it out right now.
            for device in location.getDevices():
                devices.add(device)
        
        return devices
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["endedAt"] = self.endedAt
        d["isLive"] = self.isLive
        d["room"] = self.room.uuid
        
        # We are pointedly NOT including eventHistory in here. It's 
        # duplicating information that will live in the on-disk caches anyway.
        
        d["locations"] = [location.uuid for location in self.locations]
        
        d["topics"] = [topic.uuid for topic in self.topics]
        
        # Should these be just UUIDs of participants? Doing everything about
        # them, for now.
        d["allParticipants"] = [user.uuid for user in self.allParticipants]
        d["currentParticipants"] = [user.uuid for user in
            self.getCurrentParticipants()]
        
        
        return d
    
    def sendEvent(self, eventToSend):
        """Sends the 'event' to all participants in 'meeting'."""
        
        logging.info("About to send to all users in meeting: %s"
            %eventToSend.meeting.getCurrentParticipants())
            
        if(eventToSend.eventType == "JOINED"):
            # This is tricky - we want to (in the JOINED event message)
            # include the history of everything that's happened in the meeting
            # so they can get up to speed. 
            
            # first, throw all past events onto that user's queue first.
            logging.debug("Putting all past meeting events into the new\
            user's queue. Total events: %d"%len(self.eventHistory))
            event.sendEventsToDevices([eventToSend.user.getDevices()], self.eventHistory)
            
            # then send everyone (including the new user) a normal JOINED
            # event.
            event.sendEventsToDevices(self.getDevices(), [eventToSend])
        else:
            # This is the normal path for all other event types.
            event.sendEventsToDevices(self.getDevices(), [eventToSend])

        # Save the event in the meeting history.
        self.eventHistory.append(eventToSend)
        
    def __str__(self):
        return "[meet.%s@%s %s locs:%d users:%d events:%d topics:%d]"%(
            self.uuid[0:6], self.room.name, self.title, len(self.locations),
            len(self.getCurrentParticipants()), len(self.eventHistory),
            len(self.topics))
            

class Device(YarnBaseType):
    """Holds just the connection-related stuff. Devices are the actual
    physical objects that are used by people to interact with the system. We
    keep them as a separate class because when want to send a message, we 
    can only address devices, not individual users. This split is important
    because users can be interacting with multiple devices at once. 
    
    Devices are owned by actors, and actors can have one or more devices
    associatd with them. Devices maintain a link back to their actor (of which
    they can have only one) so that when a new connection comes in, we know
    who to attribute it to.
    
    Devices maintain all the connection-management-related stuff like queues,
    connection timeouts, etc.
    """
    
    def __init__(self):
        self.uuid = None
        YarnBaseType.__init__(self)
        self.connection = None
        self.actor = None
        self.eventQueue = []
    
    def isConnected(self):
        # I wish we could inspect connection._finished to double-check...
        # There's a risk here because if we forget to set the connection to
        # None when it's gone, this is going to be wrong.
        return self.connection != None
    
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
                open connection for the device."%self.uuid)
            return

        logging.debug("Flushing queue of %d events on device %s"%
            (len(self.eventQueue),self.uuid))
        self.connection.write(json.dumps(self.eventQueue,
            cls=YarnModelJSONEncoder))
        self.connection.finish()
        self.connection = None

        # TODO wait for ACK from the client that it received these events.
        self.eventQueue = []
    
    def setConnection(self, connection):

        # if we're already holding onto a connection, release it
        if(self.connection != None):
            try:
                logging.debug("Shutting down pre-existing connection from %s"%
                    self.actor.name)
                self.connection.finish()
            except:
                logging.warning("Tried to double-close a connection \
                 in setConnection actor:%s"%
                    self.actor.name)
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

        logging.debug("Updated connection for device %s"%self)

        # check to see if events have queued up during our absence of a
        # connection. 
        if(len(self.eventQueue) > 0):
            logging.debug("Flushing existing event queue into new\
                connection.")
            self.flushQueue()
    
    def __repr__(self):
        return self.__str__()
    
    def __str__(self):
        # What are the important elements of this user?
        # - uuid
        # - has active connection
        # - has queued items
        # - actor associated
        if(self.actor!=None):
            return "[dev.%s conn:%s q:%d act:%s]"%(self.uuid[0:6],
            self.isConnected(),len(self.eventQueue), self.actor.name)
        else:
            return "[dev.%s conn:%s q:%d act:None]"%(self.uuid[0:6],
            self.isConnected(),len(self.eventQueue))

class Actor(YarnBaseType):
    """An abstract base class that can represent either a Location or a User.
    
    Actors are the objects that are responsible for originating Events,
    and share a number of important features that both Locations and Users
    have. """
    
    def __init__(self, name=None, actorUUID=None):
        self.uuid = actorUUID
        
        YarnBaseType.__init__(self)
        
        self._devices = set()
        self.name = name
        
        
    def getDict(self):
        d = YarnBaseType.getDict(self)
        
        # devices are NOT serialized and sent to clients because they're
        # server-only representations for packaging connections. 
        #
        # Leaving this whole structure in here for now because we might need
        # to plug into it later. But for now it's just a passthrough.
        d["name"] = self.name
        
        return d
        
    def isLoggedIn(self):
        return len(self._devices) > 0
    
    def addDevice(self, device):
        self._devices.add(device)
        device.actor = self
    
    def removeDevice(self, device):
        self._devices.remove(device)
        device.actor = None
    
    def getMeeting(self):
        logging.warning("Called getMeeting on Actor. Should only ever be\
called on Users or Locations (the concerete subclasses of Actor.)")
        return None
    
    def getDevices(self):
        """Returns all the devices present at this location.
        
        Used for communication purposes, so Events can be enqueued on those 
        Device's connections."""
        return self._devices

class User(Actor):
    """Users are the people that are participating in the meeting.
    
    Users are not directly included in meetings - only locations can be
    part of a meeting, and users are part of a location by virtue of being
    connected to a device that's in a location."""
    
    def __init__(self, name=None, userUUID=None):
        
        Actor.__init__(self, name, userUUID)
        
        self._status = None
        self.location = None
        
    def isInLocation(self):
        return self.location != None

    def getDict(self):
        d = Actor.getDict(self)
        d["status"] = self._status
        
        if(self.location != None):
            d["location"] = self.location.uuid
        else:
            d["location"] = None
        
        return d
    
    def isInMeeting(self):
        return self.location.isInMeeting()
    
    def getMeeting(self):
        return self.location.getMeeting()
        
    def __str__(self):
        if(self.isInLocation()):
            return "[user.%s %s loc:%s devs:%d]"%(self.uuid[0:6],
                self.name, self.location.name + "@" +
                self.location.meeting.room.name,
                len(self.getDevices()))
        else:
            return "[user.%s %s loc:NONE devs:%d]"%(self.uuid[0:6],
                self.name, self.location.name + "@" +
                self.location.meeting.room.name,
                len(self.getDevices()))
    

class Location(Actor):
    """
    Locations define a specific physical location, which contains a set of
    users and devices. 
    
    Meetings are made up of participating locations, which are in turn made
    up of users and devices. Depending on what you care about, you'll 
    look at those lists differently. For communication, get the device list
    and send a message to all devices present in a Location. For display,
    Users are often the important distinction. 
    """
    
    def __init__(self, name=None, actorUUID=None):
        Actor.__init__(self, name, actorUUID)
        self.meeting = None
        self.users = set()
    
    def userJoined(self, user):
        """Adds the specified user to this location."""
        
        self.users.add(user)
        user.location = self
        
        if(self.isInMeeting()):
            self.meeting.userJoinedLocation(user, self)
        
    def userLeft(self, user):
        """Removes the specified user from this location."""
        
        self.users.remove(user)
        user.location = None
        
        if(self.isInMeeting()):
            self.meeting.userLeftLocation(user, self)
        
    
    def getUsers(self):
        return list(self.users)
    
    def getMeeting(self):
        return self.meeting
    
    def isInMeeting(self):
        return self.meeting != None

    def joinedMeeting(self, meeting):
        logging.debug("Location joined meeting.")
        meeting.locationJoined(self)
        self.meeting = meeting

        
        # create events for all our users to set them up as joining
        # the meeting.
    
    def leftMeeting(self):
        meeting.locationLeft(self)
        
            
    def getDevices(self):
        
        # Get devices specific to this location, plus all the devices that
        # all connected users have that are specific to them.
        # (copying so we don't accidentlly add these users' devices to the
        # main device list, although that wouldn't actually be the end of the
        # world.)
        allDevices = copy.copy(self._devices)
        
        for user in self.users:
            allDevices |= user.getDevices()
        
        return allDevices

    def getDict(self):
        d = Actor.getDict(self)
        
        # this is stupid, but I can't figure out how to get JSONEncoder
        # to take sets, so we have to convert to lists on the way out.
        d["users"] = [user.uuid for user in self.users]
        
        if(self.meeting!=None):
            d["meetingUUID"] = self.meeting.uuid;
        else:
            d["meetingUUID"] = None
        
        return d

    def __str__(self):
        if(self.isInMeeting()):
            return "[loc.%s %s meet:%s users:%d devs:%d]"%(self.uuid[0:6],
                self.name, str(self.meeting.title) + "@" + self.meeting.room.name,
                len(self.users), len(self.getDevices()))
        else:
            return "[loc.%s %s meet:NONE users:%d devs:%d]"%(self.uuid[0:6],
                self.name, len(self.users), len(self.getDevices()))
            


class MeetingObject(YarnBaseType):
    """Defines some basic properties that are shared by meeting objects."""

    def __init__(self, creatorUUID, meetingUUID, createdAt=None,
        meetingObjUUID=None):
        
        self.uuid = meetingObjUUID
        YarnBaseType.__init__(self)

        # TODO we almost certainly want to unswizzle these UUIDS
        # to their actual objects. When we do that, we'll need to
        # switch all the getDict methods to getting the UUID instead
        # of just taking the whole object like it does now.
        self.createdBy = state.get_obj(creatorUUID, Actor)
        
        if createdAt==None:
            self.createdAt = time.time()
        else:
            self.createdAt = createdAt
        
        self.meeting = state.get_obj(meetingUUID, Meeting)
        
    
    def getDict(self):
        d = YarnBaseType.getDict(self)
        d["createdBy"] = self.createdBy.uuid
        d["createdAt"] = self.createdAt
        d["meeting"] = self.meeting.uuid
        return d

class Task(MeetingObject):
    """Store information about a task."""
    
    def __init__(self, meetingUUID, creatorUUID, text, taskUUID=None):
        MeetingObject.__init__(self, creatorUUID, meetingUUID, taskUUID)
        self.text = text
        self.ownedBy = None
        
    def getDict(self):
        d = MeetingObject.getDict(self)
        d["text"] = self.text
        d["ownedBy"] = self.ownedBy.uuid
        return d

class Topic(MeetingObject):
    """Store information about a topic."""
    
    # These are possible status options for a topic. Declared as static
    # members because python doesn't have enums and the various enum work-
    # arounds on the web are obnoxious.
    PAST="PAST"
    CURRENT="CURRENT"
    FUTURE="FUTURE"
    

    def __init__(self, meetingUUID, creatorUUID, text, startTime=None,
        stopTime=None, status=None, startActorUUID=None, stopActorUUID=None,
        color=None, topicUUID=None):
        MeetingObject.__init__(self, creatorUUID, meetingUUID, topicUUID)
        
        self.text = text
        
        self.startTime = startTime
        
        if(startActorUUID!=None):
            self.startActor = state.get_obj(startActorUUID, Actor)
        else:
            self.startActor = None
        
        self.stopTime = stopTime
        
        if(stopActorUUID != None):
            self.stopActor = state.get_obj(stopActorUUID, Actor)
        else:
            self.stopActor = None
        
        # Need to decide later how to represent color. Almost certainly
        # going to just use HTML hex colors for ease, although I need to
        # check and see if there's an easy way to convert those to something
        # that objC can use.
        self.color = color
        
    
    def setStatus(self, status):
        if(status in [PAST, CURRENT, FUTURE]):
           self.status = status
        else:
           logging.warning("Tried to set a topic with an unknown\
status: " + str(status))

           # this is for initialization routines - default to something.
           if(self.status==None):
               self.status = FUTURE
    
    def setText(self, text):
        self.text = text

    def getDict(self):
        d = MeetingObject.getDict(self)
        d["text"] = self.text
        d["startTime"] = self.startTime
        d["stopTime"] = self.stopTime
        d["color"] = self.color
        
        if(self.startActor!=None):
            d["startActor"] = self.startActor.uuid
        else:
            d["startActor"] = None
        
        if(self.stopActor!=None):
            d["stopActor"] = self.stopActor.uuid
        else:
            d["stopActor"] = None
            
        return d



class YarnModelJSONEncoder(json.JSONEncoder):
    """JSON Encoder for Yarn model objects."""
    def default(self, obj):
        if isinstance(obj, YarnBaseType) or isinstance(obj, event.Event):
            # use the getDict method for model objects, since we can't
            # encode python objects to JSON directly.
            return obj.getDict()
        elif isinstance(obj, set):
            # for some reason the default encoder can't handle set objects,
            # so just convert them to lists.
            logging.warning("found set. can't figure out how to make sets\
            work yet.")
            return self.default(list(obj))
        else:
            return json.JSONEncoder.default(self, obj)

if __name__ == "__main__":
    # try making some new things and spitting them back out again.
    room1 = Room("Garden")
    room2 = Room("Orange and Green")
    
    print "room 1: " + str(room1)
    print "room 1 json: " + str(room1.getJSON())
    print "obj store: " + str(db)
    
