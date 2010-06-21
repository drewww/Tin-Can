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
            (r"/rooms/leave", LeaveRoomHandler),
            
            (r"/locations/list", LocationsHandler),
            (r"/locations/join", JoinLocationHandler),
            (r"/locations/leave", LeaveLocationHandler),
            
            (r"/users/", AllUsersHandler),
            (r"/users/add", AddUserHandler),
            
            (r"/connect/", ConnectionHandler),
            (r"/connect/test", ConnectTestHandler),
            (r"/connect/login", LoginHandler),

            
            (r"/users/choose", ChooseUsersHandler),
            
            (r"/agenda/", AgendaHandler)
            ]
        
        settings = dict(
            # using a throw-away secret for now - this really should be
            # loaded out of a configuration file, so we don't have to check
            # it into the repository. Don't trust this for ANYTHING.
            cookie_secret="61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o/Vo=",
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
            raise HTTPError("400", "Specified device %s doesn't have an \
            associated actor. It must set a User or Location first."
            %device.uuid)
            return None

        return actor
    
    def get_current_device(self):
        # All logged-in users should have a deviceUUID.
        deviceUUID = self.get_secure_cookie("deviceUUID")

        device = state.get_obj(deviceUUID, Device)
        if(device==None):
            raise HTTPError("400", "Specified device UUID %s\
            didn't exist or wasn't a valid device."%deviceUUID)
            return None
        
        return device


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
            logging.info("Actor %s already logged in. Connection saved."%
                actor.name)
            device.setConnection(self)            
        

class JoinRoomHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        
        # TODO Check if the current actor has a location set yet. If not, 
        # do we want to reject the query? I think so...
        
        roomUUID = self.get_argument("roomUUID")
        
        actor = self.get_current_actor()
        
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
                
                # Can't do this until we have events changing
                # the internal state of the server, because
                # the meeting with that UUID doesn't actually
                # exist yet. Going to check this in without
                # that chunk. The earlier stuff is working great.
                userJoinedEvent = Event("JOINED_MEETING", actor.uuid,
                    newMeetingEvent.results["meeting"].uuid)
                userJoinedEvent.dispatch()
                
            else:
                # pull the existing meeting.
                meeting = room.currentMeeting
                
                # we need to mark this user as joining this
                # meeting TODO TODO TODO
                userJoinedEvent = Event("JOINED_ROOM", actor.uuid,
                    meeting.uuid)
                userJoinedEvent.dispatch()
              
        else: 
            raise HTTPError("400", "Specified room UUID %s \
            didn't exist or wasn't a valid room."%roomUUID)
            return

class LeaveRoomHandler(BaseHandler):

    @tornado.web.authenticated
    def post(self):
        user = self.get_current_user()
        meeting = user.inMeeting
        
        leaveEvent = Event("LEFT", user.uuid, user.inMeeting.uuid)
        leaveEvent.dispatch()

class AddUserHandler(tornado.web.RequestHandler):
    
    def post(self):
        userName = self.get_argument()
        
        # 
    
    

class LoginHandler(BaseHandler):
    
    def post(self):
        # first, check and see if the connection included a device cookie
        # to identify itself. This is very similar to get_current_actor in
        # BaseHandler, but slightly different because if they don't have one,
        # we bounce them to the resource where they can get on.
        deviceUUID = self.get_secure_cookie("deviceUUID")

        device = state.get_obj(deviceUUID, Device)
        if(device==None):
            # redirect to /connect/device
            logging.debug("Received a connection that didn't have a device\
            cookie yet.")
            addDeviceEvent = Event("NEW_DEVICE")
            addDeviceEvent = addDeviceEvent.dispatch()
            device = addDeviceEvent.results["device"]
            logging.info("Set up new device with UUID %s"%device.uuid)
            self.set_secure_cookie("deviceUUID", device.uuid)
        
        # take the actorUUID and associate the specified device with it. 
        actorUUID = self.get_argument("actorUUID")

        actor = state.get_obj(actorUUID, Actor)
        if(actor==None):
            raise HTTPError("400", "Specified actor UUID %s\
            didn't exist or wasn't a valid actor."%actorUUID)
            return None

        addActorDeviceEvent = Event("ADD_ACTOR_DEVICE", actor.uuid, params={"actor":actor,
        "device":device})
        addActorDeviceEvent.dispatch()
        
        # otherwise, set the secure cookie for the user ID.
        logging.info("Associated device (%s) with actor '%s'."%(device.uuid,
        actor.name))

class LocationsHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.puts(state.get_locations, cls=YarnModelJSONEncoder))


class JoinLocationHandler(tornado.web.RequestHandler):
    
    @tornado.web.authenticated
    def post(self):
        user = self.get_current_user()
        
        locationUUID = self.get_argument("locationUUID")
        location = state.get_obj(locationUUID, Location)
        if(location==None):
            raise HTTPError("400", "Specified location UUID %s\
            didn't exist or wasn't a valid location."%locationUUID)
            return None

class LeaveLocationHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.puts(state.get_locations, cls=YarnModelJSONEncoder))


class AddTopicHandler(tornado.web.RequestHandler):
    def post(self):
        userUUID = self.get_argument("userUUID")
        meetingUUID = self.get_argument("")
        topic = self.get_argument("topic")
        

class AgendaHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("agenda_edit.html")
        
class ChooseUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("login.html")

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
