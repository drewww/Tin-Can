#!/usr/bin/env python
# encoding: utf-8
"""
yarn.py - the Tin Can server.

Initializes the tornado server, sets the routing paths, initializes the model,
etc.

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import logging
import os.path
import uuid
import time

import tornado.httpserver
import tornado.ioloop
import tornado.web
from tornado.web import HTTPError
from tornado.options import define, options

import simplejson as json


import state
from model import *
from event import *

define("port", default=8888, help="run on the given port", type=int)

# TODO We need to load this out of a file somewhere so it's consistent
#      across reboots.
SERVER_UUID = uuid.uuid4()

class YarnApplication(tornado.web.Application):
    def __init__(self):
        
        handlers = [
            (r"/rooms/list", RoomsHandler),
            (r"/rooms/join", JoinRoomHandler),
            (r"/rooms/leave", LocationLeaveMeetingHandler),
            
            (r"/locations/list", LocationsHandler),
            (r"/locations/add", AddLocationHandler),
            (r"/locations/join", JoinLocationHandler),
            (r"/locations/leave", LeaveLocationHandler),
            
            (r"/meetings/edit", EditMeetingHandler),
            
            (r"/topics/add", AddTopicHandler),
            (r"/topics/delete", DeleteTopicHandler),
            (r"/topics/update", UpdateTopicHandler),
            (r"/topics/list", ListTopicHandler),
            
            (r"/tasks/add", AddTaskHandler),
            (r"/tasks/delete", DeleteTaskHandler),
            (r"/tasks/edit", EditTaskHandler),
            (r"/tasks/assign", AssignTaskHandler),
            
            (r"/users/", AllUsersHandler),
            (r"/users/add", AddUserHandler),
            
            (r"/connect/", ConnectionHandler),
            (r"/connect/test", ConnectTestHandler),
            (r"/connect/login", LoginHandler),
            (r"/connect/state", StateHandler),
            (r"/connect/logout", LogoutHandler),
            
            (r"/users/choose", ChooseUsersHandler),
            (r"/agenda/", AgendaHandler),
            (r"/agendajqt/", AgendaJQTHandler),
            
            (r"/status/", StatusHandler),
            
            (r"/rooms/",ChooseRoomsHandler),
            (r"/meeting/",MeetingHandler),
            ]
        
        settings = dict(
            # using a throw-away secret for now - this really should be
            # loaded out of a configuration file, so we don't have to check
            # it into the repository. Don't trust this for ANYTHING.
            # cookie_secret="61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o/Vo=",
            template_path=os.path.join(os.path.dirname(__file__),
                "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            login_url="/connect/login"
        )
        
        # TODO make this depend on a startup option like -v
        # options.logging="debug"
        #logging.basicConfig(level=logging.DEBUG)
        
        tornado.web.Application.__init__(self, handlers, **settings)


class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        # To avoid confusion, I want to use get_current_actor, but I think
        # I need this for compatibility with what tornado expects.
        # TODO Test that assumption.
        return self.get_current_actor()
        
        
    def get_current_actor(self):
        
        device = self.get_current_device()
        
        # now, map that device back to an actor.
        actor = device.actor
        if (actor==None):
            raise HTTPError(400, "Specified device %s doesn't have an \
            associated actor. It must set a User or Location first."
            %device.uuid)
            return None

        return actor
    
    def get_current_device(self):   
        # All logged-in users should have a deviceUUID.
        deviceUUID = self.get_cookie("deviceUUID")
        
        device = state.get_obj(deviceUUID, Device)
        if(device==None):
            raise HTTPError(400, "Specified device UUID %s\
            didn't exist or wasn't a valid device."%deviceUUID)
            return None
        
        return device

class StateHandler(tornado.web.RequestHandler):
    
    def get(self):
        
        # We want to dump all current information (deep search-ly) onto
        # the channel so a new client can initialize their internal state
        # representation of users, locations, rooms, and meetings.
        stateDict = {
            "locations":state.get_locations(),
            "users":state.get_users(),
            "rooms":list(state.get_rooms()),
            "meetings":state.get_meetings()
            }
        
        self.write(json.dumps(stateDict, cls=YarnModelJSONEncoder))

class StatusHandler(tornado.web.RequestHandler):
    # TODO Figure out a way to protect this. It's useful for debugging,
    # but I don't want to push something that exposes the entire internal
    # state to a production machine. Do some kind of simple admin login
    # cookie trick.
    def get(self):
        users = state.get_users()
        locations = state.get_locations()
        rooms = state.rooms
        tasks = []
        
        for meeting in state.get_meetings():
            for task in meeting.tasks:
                tasks = tasks + [task]
                
        curTime = time.time()
        logging.debug("rooms: " + str(rooms) + " len: " + str(len(rooms)))
        logging.info("Providing state @%f on: %d users, %d locations, and %d\
         rooms."%(curTime, len(users), len(locations), len(rooms)))
         
        logging.info("users")
        for user in users:
            logging.debug(user)
            
        logging.info("rooms")
        for room in rooms:
            logging.debug(room)
            
        logging.info("locations")
        for location in locations:
            logging.debug(location)
            
        logging.info("tasks")
        for task in tasks:
            logging.debug(task)
    
        # logging.info("users: " + str(users))
        # logging.info("locations: " + str(locations))
        # logging.info("rooms: " + str(rooms))
        # logging.info("tasks: " + str(tasks))
        
        self.render("state.html", users=users,
            rooms=state.rooms, locations=locations,
            curTime=curTime, tasks=tasks)
        

# TODO Is there a way to make json.dump default to using YarnModelJSONEncoder?
# It's really annoying to have to specify it every time I need to dump
# something.
class RoomsHandler(tornado.web.RequestHandler):
    def get(self):
        """Returns a list of rooms."""
        self.write(json.dumps(state.rooms, cls=YarnModelJSONEncoder))

class AllUsersHandler(tornado.web.RequestHandler):
    def get(self):
        
        self.write(json.dumps(state.get_users(), cls=YarnModelJSONEncoder))

class ConnectTestHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("connect.html", users=state.get_users(),
            rooms=state.rooms, locations=state.get_locations())

class ConnectionHandler(BaseHandler):
    """Manage the persistent connections that all clients have."""
    
    @tornado.web.asynchronous
    @tornado.web.authenticated
    def get(self):
        # We're going to treat this pretty much like the toqbot
        # infrastructure -- a client will open a connection to this url and
        # we'll hold on to it until we have something to send to that client.
        #
        # We'll use per-user message queues. Those queues
        # are owned by the user objects, and whenever someone connects we
        # empty the message queue into the connection and finish it, 
        # or we hold that connection open.
        #
        # I'm concerned with having to send this stuff around all the time,
        # these UUIDs are so huge that it gets a bit ugly looking. But
        # I guess it's mostly in the background? We'll roll with it for now.
        # Most of this will get pushed into cookies anyway, I think? We'll
        # have to figure out the multiple-connections-at-once case later. 
        #
        # We ALWAYS require userUUIDs.
        
        # because arguments get treated as UTF-8 inputs, we need to 
        # re-encode back down to ASCII so we can compare. We can trust that
        # these are fundamentally ASCII to begin with because they're IDs
        # generated by the client, not user-entered text.
        actor = self.get_current_actor()
        device = self.get_current_device()
        
        # TODO Figure out if we ever actually hit this code anymore.
        if(not actor.isLoggedIn()):
            logging.debug("received a connect request from a non-logged-\
            in actor: %s"%actor.name)
            
            # need to do this after checking for logged-in status, 
            # otherwise loggedIn is always true because this side-effects
            # and sets 
            device.setConnection(self)
        else:
            # if the user is already logged in, we don't really care - 
            # just update their connection to match. Don't need to 
            # trigger any events. We don't even particularly care if
            # they have the other parameters; we already know what they're
            # connected to. (TODO figure out how to deal with a smooth
            # switch between meetings. Can you do that without forcing
            # a log out event from the previous one? Deal with this later)
            logging.info("Actor %s already logged in. Saving connection."%
                actor.name)
            device.setConnection(self)            
        

class JoinRoomHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        
        # TODO Check if the current actor has a location set yet. If not, 
        # do we want to reject the query? I think so...
        
        actor = self.get_current_actor()
        
        location = None
        if isinstance(actor, model.User):
            # If we've got a user, make sure they have a location set alrady.
            # If they don't, reject the request outright.
            user = actor
            if user.location == None:
                raise HTTPError(400, "Specified user " + user.name + 
                " isn't yet in a location, so can not join a room.")
                return
            
            location = user.location
            logging.debug("User %s is trying to join a room on their behalf\
            of their location %s"%(user.name, location.name))
        else:
            location = actor
            logging.debug("Actor is a location: " + location.name)
        
        
        # from this point forward, we're telling the location what to join,
        # not the user. the location is the user's location
        if(location.isInMeeting()):
            logging.warning("About to change rooms of a location that is\
            already in a meeting: %s. This is bad! Leave first!",
            location.meeting)
        
        roomUUID = self.get_argument("roomUUID")
        logging.debug("request has a roomUUID: %s"%roomUUID)
        room = state.get_obj(roomUUID, Room)
        if room != None:
            # check and see if the room is empty. If it is, create
            # a new meeting there and put this user in it. get the
            # meeting id of the new meeting and set it for moving 
            # forward.
            if(room.currentMeeting==None):
                logging.debug("Room %s has no meeting in it."%
                    room.name)
                # make a new meeting!
                logging.info("Initiating a new meeting in room\
                %s for actor %s"%(room.name, actor.name))
                
                # For a discussion of why we're not just making
                # the object here and adding the user to the 
                # meeting by directly manipulating the objects,
                # you can read up on the Event Model here:
                # http://wiki.github.com/drewww/Tin-Can/eventmodel
                
                newMeetingEvent = Event("NEW_MEETING",
                    actor.uuid, None, {"room":room})
                newMeetingEvent = newMeetingEvent.dispatch()

                meeting = newMeetingEvent.results["meeting"]                
            else:
                # pull the existing meeting.
                meeting = room.currentMeeting
            
            
                
            logging.debug("New meeting created, now joining people to\
            the meeting.")
            # Can't do this until we have events changing
            # the internal state of the server, because
            # the meeting with that UUID doesn't actually
            # exist yet. Going to check this in without
            # that chunk. The earlier stuff is working great.
            locationJoinedMeetingEvent = Event("LOCATION_JOINED_MEETING",
            location.uuid, None, {"meeting":meeting})
            locationJoinedMeetingEvent.dispatch()
              
        else: 
            raise HTTPError(400, "Specified room UUID %s \
            didn't exist or wasn't a valid room."%roomUUID)
            return

class LocationLeaveMeetingHandler(BaseHandler):

    @tornado.web.authenticated
    def post(self):

        # TODO Check if the current actor has a location set yet. If not, 
        # do we want to reject the query? I think so...

        actor = self.get_current_actor()

        location = None
        if isinstance(actor, model.User):
            # If we've got a user, make sure they have a location set alrady.
            # If they don't, reject the request outright.
            user = actor
            if user.location == None:
                raise HTTPError(400, "Specified user " + user.name + 
                " isn't yet in a location, so can not leave meeting.")
                return

            location = user.location
            logging.debug("User %s is trying to leave a meeting on their behalf\
            of their location %s"%(user.name, location.name))
        else:
            location = actor
            logging.debug("Actor is a location: " + location.name)


        # from this point forward, we're telling the location what to join,
        # not the user. the location is the user's location
        if(not location.isInMeeting()):
            logging.warning("Location has no meeting: %s. Join a meeting first.",
            location)

        meetingUUID = self.get_argument("meetingUUID")
        meeting = state.get_obj(meetingUUID, Meeting)
        if (location.meeting !=meeting):
            logging.warning("Location %s is not in meeting %s."
            %(location.name,meeting.uuid))
        else:
            locationLeftMeetingEvent = Event("LOCATION_LEFT_MEETING",
            location.uuid, None, {"meeting":meeting})
            locationLeftMeetingEvent.dispatch()

class AddUserHandler(tornado.web.RequestHandler):
    
    def post(self):
        newUserName = self.get_argument("newUserName")
        
        logging.info("Adding new user: " + newUserName)
        
        newUserEvent = Event("NEW_USER", None, None, {"name":newUserName})
        newUserEvent.dispatch()

class AddLocationHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        newLocationName = self.get_argument("newLocationName")
        
        logging.info("Adding new location: " + newLocationName)
        
        actor = self.get_current_actor()
        newLocationEvent = Event("NEW_LOCATION", actor.uuid, None,
            {"name":newLocationName})
        newLocationEvent.dispatch()
    

class LoginHandler(BaseHandler):
    
    def post(self):
        # first, check and see if the connection included a device cookie
        # to identify itself. This is very similar to get_current_actor in
        # BaseHandler, but slightly different because if they don't have one,
        # we bounce them to the resource where they can get on.
        deviceUUID = self.get_cookie("deviceUUID")

        if(deviceUUID==None):
            device = None
        else:
            device = state.get_obj(deviceUUID, Device)
        
        if(device==None):
            logging.debug("Received a connection that didn't have a device\
            cookie yet.")
            addDeviceEvent = Event("NEW_DEVICE")
            addDeviceEvent = addDeviceEvent.dispatch()
            device = addDeviceEvent.results["device"]
            logging.info("Set up new device with UUID %s"%device.uuid)
            self.set_cookie("deviceUUID", device.uuid)
        
        # take the actorUUID and associate the specified device with it. 
        actorUUID = self.get_argument("actorUUID")

        actor = state.get_obj(actorUUID, Actor)
        if(actor==None):
            raise HTTPError(400, "Specified actor UUID %s\
            didn't exist or wasn't a valid actor."%actorUUID)
            return None

        addActorDeviceEvent = Event("ADD_ACTOR_DEVICE", actor.uuid, params={"actor":actor,
        "device":device})
        addActorDeviceEvent.dispatch()
        
        # otherwise, set the secure cookie for the user ID.
        logging.info("Associated device (%s) with actor '%s'."%(device.uuid,
        actor.name))
        
class LogoutHandler(BaseHandler):
    
    def post(self):
        device = self.get_current_device()
        actor = self.get_current_actor()
        
        deviceLeftEvent = Event("DEVICE_LEFT", actor.uuid, 
            params={"device":device})
        deviceLeftEvent.dispatch()

class LocationsHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.puts(state.get_locations, cls=YarnModelJSONEncoder))


class JoinLocationHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        actor = self.get_current_actor()
        
        locationUUID = self.get_argument("locationUUID")
        location = state.get_obj(locationUUID, Location)
        if(location==None):
            raise HTTPError(400, "Specified location UUID %s\
            didn't exist or wasn't a valid location."%locationUUID)
            return None
        
        # Trigger the actual event.
        joinLocationEvent = Event("USER_JOINED_LOCATION", actor.uuid,
            params={"location":location})
        joinLocationEvent.dispatch()

class LeaveLocationHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        actor = self.get_current_actor()
        
        locationUUID = self.get_argument("locationUUID")
        location = state.get_obj(locationUUID, Location)
        if(location==None):
            raise HTTPError(400, "Specified location UUID %s\
            didn't exist or wasn't a valid location."%locationUUID)
            return None
        
        # Trigger the actual event.
        leaveLocationEvent = Event("USER_LEFT_LOCATION", actor.uuid,
            params={"location":location})
        leaveLocationEvent.dispatch()

class EditMeetingHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        actor = self.get_current_actor()
        meeting = state.get_obj(self.get_argument("meetingUUID"), Meeting)
        
        editMeetingEvent = Event("EDIT_MEETING", actor.uuid, 
            params={"meeting":meeting, "title": self.get_argument("title")})
        editMeetingEvent.dispatch()
        return


class AddTopicHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        actor = self.get_current_actor()
        
        newTopicEvent = Event("NEW_TOPIC", actor.uuid ,
            actor.getMeeting().uuid,
            params={"text": self.get_argument("text")})
        newTopicEvent.dispatch()
        return

class DeleteTopicHandler(BaseHandler):
    def post(self):
        actor = self.get_current_actor()
        
        deleteTopicEvent = Event("DELETE_TOPIC", actor.uuid,
            actor.getMeeting().uuid,
            params={"text":self.get_argument("topicUUID")})
        deleteTopicEvent.dispatch()
        return
        
        
class UpdateTopicHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        
        actor = self.get_current_actor()
        
        updateTopicEvent = Event("UPDATE_TOPIC", actor.uuid,
            actor.getMeeting().uuid, 
            params={"topicUUID":self.get_argument("topicUUID"),
            "status":self.get_argument("status")})
        updateTopicEvent.dispatch()
        
        return

class ListTopicHandler(BaseHandler):
    def post(self):
        userUUID = self.get_argument("userUUID")
        meetingUUID = self.get_argument("")
        topic = self.get_argument("topic")

class AddTaskHandler(BaseHandler):

    @tornado.web.authenticated
    def post(self):
        actor = self.get_current_actor()

        newTaskEvent = Event("NEW_TASK", actor.uuid ,
            actor.getMeeting().uuid,
            params={"text": self.get_argument("text")})
        newTaskEvent.dispatch()
        return

class DeleteTaskHandler(BaseHandler):
    def post(self):
        actor = self.get_current_actor()
        
        logging.debug(self.get_argument("taskUUID"))
        deleteTaskEvent = Event("DELETE_TASK", actor.uuid,
            actor.getMeeting().uuid,
            params={"taskUUID":self.get_argument("taskUUID")})
        deleteTaskEvent.dispatch()
        return

class EditTaskHandler(BaseHandler):
    def post(self):
        actor = self.get_current_actor()
        
        editTaskEvent = Event("EDIT_TASK", actor.uuid, 
            actor.getMeeting().uuid,
            params = {"taskUUID":self.get_argument("taskUUID"),
                "text":self.get_argument("text")})
        editTaskEvent.dispatch()
        
class AssignTaskHandler(BaseHandler):
    def post(self):
        actor = self.get_current_actor()
        
        # check and see if the deassign flag is set.
        deassign = self.get_argument("deassign", default=None)
        
        if(deassign==None):
            # if deassign wasn't set, look for an assignment UUID parameter
            assignedTo = state.get_obj(self.get_argument("assignedToUUID"),
                User)
            p = {"taskUUID":self.get_argument("taskUUID"),
                    "assignedTo":assignedTo, "deassign":False}
        else:
            # if deassign was set, then trigger a deassign event.
            p = {"taskUUID":self.get_argument("taskUUID"),
                    "deassign":True}
            
        logging.debug("assign params: " + str(p))
        assignTaskEvent = Event("ASSIGN_TASK", actor.uuid, 
            actor.getMeeting().uuid,
            params = p)
        assignTaskEvent.dispatch()


class AgendaHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("agenda_edit.html")
        
class ChooseUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("login.html")
        
class ChooseRoomsHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("rooms.html")

class AgendaJQTHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("agenda_jqtouch.html")

class MeetingHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("meeting.html")



# Set up the routing tables for the application.
# For now, they're really simple - one for getting information about rooms,
# one for getting information about users (and registering a new user),
# and one for managing persistent connections. 
#
# I'd like to be able to merge all the users handlers into one - not sure
# yet how to do that.

if __name__ == '__main__':
    tornado.options.parse_command_line()
    
    # This just populates the state with some trial data to have something
    # to work with and test.
    state.init_test()
    
    http_server = tornado.httpserver.HTTPServer(YarnApplication())
    
    # defaults to 8888
    http_server.listen(options.port)
    logging.info("YARN LOADED, INITIALIZED AND STARTING...")
    tornado.ioloop.IOLoop.instance().start()
