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
        
    // Kick off an initialization request to the server.
    connection.getState(this.initStateManager);
}

StateManager.prototype = {
    
    // Gets the object for that UUID from the database.
    getObj: function(uuid, type) {
        if(uuid==null) {
            return null;
        }
        
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
    
    initStateManager: function(users, locs, rooms) {
        // Loop through all of these objects and create local 
        // JS versions of all of them to set up our data store properly.
        // This wipes all existing state, though - gotta be careful with it.
        
        console.log("this: " + this);
        
        // alert("IN INITSTATEMANAGER this.location: " + this.location);
        // alert("IN INITSTATEMANAGER location: " + location);
        // alert("IN INITSTATEMANAGER this: " + this);
        
        // Set up the main data stores, and clear the database object.
        // 
        this.db = {};
        this.actors = [];
        this.rooms = [];
        
        // We need to do this in two passes - one pass where we make all the
        // objects using uuids as references between them, and then a 
        // second pass where we deswizzle those UUIDs to the actual objects
        // once all the objects exist in the data store.
        
        for(key in users){
            user = users[key];
            console.log("processing user: " + user);
            if(user["location"]!=null) {
                this.actors.push(new User(user["uuid"], user["name"], user["location"]["uuid"]));
            } else {
                this.actors.push(new User(user["uuid"], user["name"], null));
            }
        }
        
        
        for(key in locs) {
            loc = locs[key];
            locationUsers = [];
            for(userKey in loc["users"]) {
                user = loc["users"][userKey];
                locationUsers.push(user["uuid"]);
            }
            
            if(location["meeting"]==null) {
                meetingUUID = null;
            } else {
                meetingUUID = loc["meeting"]["uuid"];
            }
            
            this.actors.push(new Location(loc["uuid"], loc["name"], meetingUUID, locationUsers));
        }
        
        for(key in rooms) {
            room = rooms[key];
                        
            this.rooms.push(new Room(room["name"], room["uuid"], room["currentMeetingUUID"]));
        }
        
        
        // Now do an unswizzling pass.
        for(key in this.db) {
            obj = this.db[key];
            try {
                if(obj instanceof User) {
                    console.log("user");
                    User(obj).unswizzle();
                } else if(obj instanceof Location) {
                    console.log("location");
                    Location(obj).unswizzle();
                } else if(obj instanceof Room) {
                    console.log("room");
                    Room(obj).unswizzle();
                } else if(obj instanceof Meeting) {
                    console.log("meeting");
                    Meeting(obj).unswizzle();
                }
            } catch (err){
                console.log("Failed to unswizzle: " + obj + " with error: " + err);
            }
        }
        
    }
}


// This should really be namespaced nicely, but I dont want to figure that
// out quite yet.
state = new StateManager();