#!/usr/bin/env python
# encoding: utf-8
"""
state.py - maintain the state of the system's rooms, meetings, and users.

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import model
import simplejson as json

# This dictionary stores all known major types. This is used primarily so 
# we can cheaply bridge UUIDs into objects. When any of these major types
# is created, it's automatically registered here (via the YarnBaseType
# constructor). 
db = {}

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
    
    paula = model.User("Paula")
    
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

def send_event_to_users(users, event):
    
    for user in users:
        user.connection.write(event.getJSON())
        user.connection.finish()
    


if __name__ == '__main__':
    init_test()
    
    print "users: " + str(users)
    print "rooms: " + str(rooms)
    print "users json: " + json.dumps(get_logged_in_users(), cls=model.YarnModelJSONEncoder)

