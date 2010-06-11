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
import tornado.httpserver
import tornado.ioloop
import tornado.web
import simplejson as json

import types
import state
import model

# TODO Is there a way to make json.dump default to using YarnModelJSONEncoder?
# It's really annoying to have to specify it every time I need to dump
# something.

class RoomsHandler(tornado.web.RequestHandler):
    def get(self):
        """Returns a list of current rooms."""
        self.write(json.dumps(state.rooms, cls=model.YarnModelJSONEncoder))

class AllUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.dumps(state.users, cls=model.YarnModelJSONEncoder))

class ConnectedUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.dumps(state.get_logged_in_users(), cls=model.YarnModelJSONEncoder))

class DisconnectedUsersHandler(tornado.web.RequestHandler):
    def get(self):
        self.write(json.dumps(state.get_logged_out_users(), cls=model.YarnModelJSONEncoder))

class ConnectionHandler(tornado.web.RequestHandler):
    """Manage the persistent connections that all clients have."""
    
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
        # We're going to need userUUIDs and meetingUUIDs.
        # I'm concerned with having to send this stuff around all the time,
        # these UUIDs are so huge that it gets a bit ugly looking. But
        # I guess it's mostly in the background? We'll roll with it for now.
        # Most of this will get pushed into cookies anyway, I think? We'll
        # have to figure out the multiple-connections-at-once case later. 
        self.write("Connection.")

# Set up the routing tables for the application.
# For now, they're really simple - one for getting information about rooms,
# one for getting information about users (and registering a new user),
# and one for managing persistent connections. 
#
# I'd like to be able to merge all the users handlers into one - not sure
# yet how to do that.
application = tornado.web.Application([
(r"/rooms/", RoomsHandler),
(r"/users/connected", ConnectedUsersHandler),
(r"/users/disconnected", DisconnectedUsersHandler),
(r"/users/", AllUsersHandler),
(r"/connect/", ConnectionHandler)])

if __name__ == '__main__':
    state.init_test()
    http_server = tornado.httpserver.HTTPServer(application)
    http_server.listen(8888)
    tornado.ioloop.IOLoop.instance().start()

