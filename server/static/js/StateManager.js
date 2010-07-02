// StateManager
//
// Keeps track of the state of the system. This includes certain global 
// information and meeting specific information. All queries about remote
// information are routed through here. When the ConnectionManager receives
// events, those events trigger changes in the StateManager.
// 
// Global data:
//  - user list and status
//  - room status
//  - (meetings, transitive from rooms)
//
// Meeting data:
//  - current participants
//  - tasks related stuff
//  - agenda related stuff
//  - etc.
// 
// When the StateManager starts, it will request global state data from 
// the server, so it can initialize its various info. From that point forward,
// events will update it. 
//
// This class closely mirrors state.py on the server (and will have a
// matching obj-c version eventually, too.)


function StateManager() {
    // Setup the major data structures.
    this.db = {};
    
    // I'd really like this to be a set, but what can you do.
    this.actors = [];
    
    this.rooms = [];
    
    // Kick off an initialization request to the server.
    connection.getState(this.initStateManager);
}

StateManager.prototype = {
    
    // Gets the object for that UUID from the database.
    getObj: function(uuid, type) {
        try {
            obj = db[uuid];
        } catch(err) {
            console.log("Error getting object with uuid " + uuid + ": "
                + err);
            return null;
        }
        
        if(type==null) {
            console.log("No type specified in getObj. This is dangerous.");
            return obj;
        }
        
        if(obj instanceof type) {
            return obj;
        } else {
            console.log("Object with UUID " + uuid + " not instance of type"+
            type + ".");
            return null;
        }
    },
    
    putObj: function(key, value) {
        this.db[key] = value;
    },
    
    initStateManager: function(users, locations, rooms) {
        // Loop through all of these objects and create local 
        // JS versions of all of them to set up our data store properly.
        
        console.log("Got callback response from the server.");
    }
}


// This should really be namespaced nicely, but I dont want to figure that
// out quite yet.
state = new StateManager();