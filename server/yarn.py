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
            (r"/users/connected", ConnectedUsersHandler),
            (r"/users/disconnected", DisconnectedUsersHandler),
            (r"/users/", AllUsersHandler),
            (r"/users/add", AddUserHandler),
            (r"/users/login", LoginHandler),
            (r"/connect/", ConnectionHandler),
            (r"/connect/ping/", PingHandler),
            (r"/connect/test", ConnectTestHandler),
            (r"/users/choose", ChooseUsersHandler),
            (r"/agenda/", AgendaHandler),
            (r"/agendajqt/", AgendaJQTHandler)
            ]
        
        settings = dict(
            # using a throw-away secret for now - this really should be
            # loaded out of a configuration file, so we don't have to check
            # it into the repository. Don't trust this for ANYTHING.
            cookie_secret="61oETzKXQAGaYdkL5gEmGeJJFuYh7EQnp2XdTP1o/Vo=",
            template_path=os.path.join(os.path.dirname(__file__),
                "templates"),
            static_path=os.path.join(os.path.dirname(__file__), "static"),
            login_url="/users/login"
        )
        
        # TODO make this depend on a startup option like -v
        # options.logging="debug"
        #logging.basicConfig(level=logging.DEBUG)
        
        tornado.web.Application.__init__(self, handlers, **settings)


class BaseHandler(tornado.web.RequestHandler):
    def get_current_user(self):
        userUUID = self.get_secure_cookie("userUUID")

        user = state.get_obj(userUUID, User)
        if(user==None):
            raise HTTPError("400", "Specified user UUID %s\
            didn't exist or wasn't a valid user."%userUUID)
            return None
        return user


# TODO Is there a way to make json.dump default to using YarnModelJSONEncoder?
# It's really annoying to have to specify it every time I need to dump
# something.
class RoomsHandler(tornado.web.RequestHandler):
    def get(self):
        """Returns a list of rooms."""
        self.write(json.dumps(state.rooms, cls=YarnModelJSONEncoder))

class AllUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.dumps(state.users, cls=YarnModelJSONEncoder))

class ConnectedUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.dumps(state.get_logged_in_users(),
            cls=YarnModelJSONEncoder))

class DisconnectedUsersHandler(tornado.web.RequestHandler):
    def get(self):
        result = json.dumps(state.get_logged_out_users(),
            cls=YarnModelJSONEncoder)
        logging.info("writing result: " + str(result))
        self.write(result)
        logging.info("After writing to page.")
        self.finish()

class ConnectTestHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("connect.html", users=state.get_logged_out_users(),
            rooms=state.rooms)

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
        user = self.get_current_user()
                    
        if(not user.loggedIn):
            logging.debug("received a connect request from a non-logged-\
            in user: %s"%user.name)
            
            # need to do this after checking for logged-in status, 
            # otherwise loggedIn is always true because this side-effects
            # and sets 
            user.setConnection(self)
        else:
            # if the user is already logged in, we don't really care - 
            # just update their connection to match. Don't need to 
            # trigger any events. We don't even particularly care if
            # they have the other parameters; we already know what they're
            # connected to. (TODO figure out how to deal with a smooth
            # switch between meetings. Can you do that without forcing
            # a log out event from the previous one? Deal with this later)
            logging.info("User %s already logged in. Connection saved."%
                user.name)
            user.setConnection(self)            
        

class JoinRoomHandler(BaseHandler):
    
    @tornado.web.authenticated
    def post(self):
        roomUUID = self.get_argument("roomUUID")

        user = self.get_current_user()
        
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
                %s for user %s"%(room.name, user.name))
                
                # For a discussion of why we're not just making
                # the object here and adding the user to the 
                # meeting by directly manipulating the objects,
                # you can read up on the Event Model here:
                # http://wiki.github.com/drewww/Tin-Can/eventmodel
                
                newMeetingEvent = Event("NEW_MEETING",
                    user.uuid, None, {"room":room})
                newMeetingEvent = newMeetingEvent.dispatch()
                
                # Can't do this until we have events changing
                # the internal state of the server, because
                # the meeting with that UUID doesn't actually
                # exist yet. Going to check this in without
                # that chunk. The earlier stuff is working great.
                userJoinedEvent = Event("JOINED", user.uuid,
                    newMeetingEvent.results["meeting"].uuid)
                userJoinedEvent.dispatch()
                
            else:
                # pull the existing meeting.
                meeting = room.currentMeeting
                
                # we need to mark this user as joining this
                # meeting TODO TODO TODO
                userJoinedEvent = Event("JOINED", user.uuid,
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
        pass
        # All we need to make a new user is a namexxx
    
    
class LoginHandler(tornado.web.RequestHandler):
    
    def post(self):
        # this is just a placeholder for now until Stephanie's login stuff
        # is all online. 
        userUUID = self.get_argument("userUUID")

        user = state.get_obj(userUUID, User)
        if(user==None):
            raise HTTPError("400", "Specified user UUID %s\
            didn't exist or wasn't a valid user."%userUUID)
            return None
        
        # otherwise, set the secure cookie for the user ID.
        logging.info("Logged in user %s, set cookie."%user.name)
        self.set_secure_cookie("userUUID", user.uuid)
        


class AddTopicHandler(tornado.web.RequestHandler):
    def post(self):
        userUUID = self.get_argument("userUUID")
        meetingUUID = self.get_argument("")
        topic = self.get_argument("topic")
        
        

class PingHandler(tornado.web.RequestHandler):
    """A testing handler to test connection management issue."""
    
    def get(self):
        # make a trivial ping event. 
        event = Event("PING", None, None)
        
        state.send_event_to_users(state.get_logged_in_users(), event)

class AgendaHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("agenda_edit.html")
        
class ChooseUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("login.html")

class AgendaJQTHandler(tornado.web.RequestHandler):
    def get(self):
        self.render("agenda_jqtouch.html")



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
