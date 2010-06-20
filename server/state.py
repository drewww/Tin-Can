#!/usr/bin/env python
# encoding: utf-8
"""
state.py - maintain the state of the system's rooms, meetings, and users.

Created by Drew Harry on 2010-06-09.
Copyright (c) 2010 MIT Media Lab. All rights reserved.
"""

import model
import simplejson as json
import logging

# This dictionary stores all known major types. This is used primarily so 
# we can cheaply bridge UUIDs into objects. When any of these major types
# is created, it's automatically registered here (via the YarnBaseType
# constructor). 
db = {}

# Stores all the actors that we've ever seen.
actors = set()

# Stores all the rooms.
rooms = set()

def init():
    """Initialize the internal state, loading from disk."""
    pass

def init_test():
    """Initialize the internal state using test data."""

    actors.add(model.User("Drew"))
    actors.add(model.User("Paula"))    
    actors.add(model.User("Stephanie"))
    actors.add(model.User("Ariel"))
    
    actors.add(model.Location("Garden"))
    actors.add(model.Location("Orange+Green"))
    actors.add(model.Location("Garden"))
    actors.add(model.Location("E14-395"))
    
    rooms.add(model.Room("Mars"))
    rooms.add(model.Room("Jupiter"))
    rooms.add(model.Room("Venus"))
    rooms.add(model.Room("Saturn"))
    


def get_obj(key, type=None):
    """Returns the object of 'type' with that UUID from the object store.
    
    If the type doesn't match the object with that key, or there is no object
    with that key in the database, returns None."""
    
    try:
        obj = db[key];
    except KeyError:
        logging.warning("No object for UUID: %s"%key)
        return None
    
    # If no type is specified, assume we don't care what the type of the
    # return is. This is bad form, though - we should ALWAYS be enforcing
    # proper types out of this method.
    if type==None:
        logging.warning("No type specified in get_obj. This is dangerous. Key:%s"%key)
        return obj
    
    # Otherwise, check that it's the right type. If it is, return it.
    # If it's not the right type, return None and throw a warning.
    if(isinstance(obj, type)):
        return obj
    else:
        logging.warning("Object with UUID %s not instance of %s" %(key, type))
        return None

def put_obj(key, value):
    """Adds an object to the main database."""
    
    # I'm not sure if we're going to need to do anything else in here, but
    # for the sake of symmetry, it makes sense to have both get and put
    # methods. 
    db[key] = value


def get_users():
    return [actor for actor in actors if isinstance(actor, model.User)]
    
def get_devices():
    """Return all current known devices. 
    
    Doesn't maintain this in memory, constructs it from scratch based
    on the list of known actors."""
    
    allDevices = set()
    
    for actor in actors:
        allDevices = allDevices | actor.getDevices()
    
    return allDevices
    
def get_locations():
    return [actor for actor in actors if isinstance(actor, model.Location)]


if __name__ == '__main__':
    init_test()
    
    print "users: " + str(users)
    print "rooms: " + str(rooms)
    print "users json: " + json.dumps(get_logged_in_users(), cls=model.YarnModelJSONEncoder)

