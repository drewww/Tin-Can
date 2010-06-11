#!/usr/bin/env python
# encoding: utf-8
"""
state.py - maintain the state of the system's rooms, meetings, and users.

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import model
import simplejson as json

# Stores all the users that we've ever seen.
users = []

# Stores all the rooms.
rooms = []

def init():
    """Initialize the internal state, loading from disk."""
    pass

def init_test():
    """Initialize the internal state using test data."""
    drew = model.User("Drew")
    drew.loggedIn = True
    
    paula = model.User("Paula")
    paula.loggedIn = True
    
    users.append(drew)
    users.append(paula)
    
    users.append(model.User("Stephanie"))
    users.append(model.User("Ariel"))
    
    rooms.append(model.Room("Garden"))
    rooms.append(model.Room("Orange + Green"))

def get_logged_out_users():
    """Returns only users that are not currently logged in."""
    return [user for user in users if not user.loggedIn]
    pass
    
def get_logged_in_users():
    """Returns only users that are currently logged in."""
    return [user for user in users if user.loggedIn]
    pass

if __name__ == '__main__':
    init_test()
    
    print "users: " + str(users)
    print "rooms: " + str(rooms)
    print "users json: " + json.dumps(get_logged_in_users(), cls=model.YarnModelJSONEncoder)

