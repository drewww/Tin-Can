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
    console.log("INIT StateManager");
    // Setup the major data structures.
    this.db = {};
}

StateManager.prototype = {
    
    // Gets the object for that UUID from the database.
    getObj: function(uuid, type) {
        if(uuid==null) {
            return null;
        }
        
        try {
            obj = this.db[uuid];
        } catch(err) {
            console.log("Error getting object with uuid " + uuid + ": "
                + err);
            return null;
        }
        
        if(type==null) {
            console.log("No type specified in getObj. This is dangerous.");
            return obj;
        }

        if(obj==null) {
            console.log("No object found for " + uuid);
            return null;
        }
        
        if(obj instanceof type) {
            return obj;
        } else {
            
            // This is terrible horrible hack, but since I haven't found
            // and inhertence system in javascript that I like and the only
            // REAL place where I want/need inheretence is location/user,
            // I'm just going to hack it in here.
            if(type==User && obj instanceof Location) {
                return obj;
            } else if(type==Location && obj instanceof User) {
                return obj;
            } else {            
                console.log("Object with UUID " + uuid + " not instance of type"+
                type + ".");
                return null;
            }
        }
    },
    
    putObj: function(key, value) {
        this.db[key] = value;
    },
    
    initStateManager: function(users, locs, rooms, meetings) {
        // Loop through all of these objects and create local 
        // JS versions of all of them to set up our data store properly.
        // This wipes all existing state, though - gotta be careful with it.
        
        console.log("this: " + this);
        
        // Set up the main data stores, and clear the database object.
        // 
        this.db = {};
        this.actors = [];
        this.rooms = [];
        this.meetings = [];
        
        // We need to do this in two passes - one pass where we make all the
        // objects using uuids as references between them, and then a 
        // second pass where we deswizzle those UUIDs to the actual objects
        // once all the objects exist in the data store.
        
        for(key in users){
            user = users[key];
            console.log("processing user: " + user);
            
            
            
            if(user["location"]!=null) {
                if (user["status"]!=null){
                    newUser = new User(user["uuid"], user["name"],
                        user["location"], user["status"], user["handRaised"]);
                }
                else{
                    newUser = new User(user["uuid"], user["name"],
                        user["location"], null, user["handRaised"]);
                }
            } else {
                if (user["status"]!=null){
                    newUser = new User(user["uuid"], user["name"],
                        null, user["status"], user["handRaised"]);
                }
                else{
                    newUser = new User(user["uuid"], user["name"],
                        null, null, user["handRaised"]);
                }
            }
            
            this.actors.push(newUser);
        }
        
        
        for(key in locs) {
            loc = locs[key];
            locationUsers = [];
            for(userKey in loc["users"]) {
                userUUID = loc["users"][userKey];
                locationUsers.push(userUUID);
            }
            
            if(loc["meetingUUID"]==null) {
                meetingUUID = null;
            } else {
                meetingUUID = loc["meetingUUID"];
            }
            
            this.actors.push(new Location(loc["uuid"], loc["name"],
                meetingUUID, locationUsers, loc["color"]));
        }
        
        for(key in rooms) {
            room = rooms[key];
                        
            this.rooms.push(new Room(room["name"], room["uuid"],
                room["currentMeeting"]));
        }
        
        for(key in meetings) {
            meeting = meetings[key];
            
            this.meetings.push(new Meeting(meeting["uuid"], meeting["title"],
                meeting["room"], meeting["startedAt"]));

            // Loop through topics and tasks and construct those properly.
            for(topicKey in meeting["topics"]) {
                
                topicData = meeting["topics"][topicKey];
                console.log("unpacking topic: ");
                console.log(topicData);
                
                newTopic = new Topic(topicData["uuid"], meeting["uuid"],
                    topicData["createdBy"], topicData["text"],
                    topicData["status"], topicData["startTime"], 
                    topicData["stopTime"], topicData["startActor"],
                    topicData["stopActor"], topicData["color"],
                    topicData["createdAt"]);

                // This will add it to the meeting.
                newTopic.unswizzle();
            }
            
            console.log("topics:");
            //console.log(topics);
            
            // Now unpack tasks.
            for(taskKey in meeting["tasks"]) {
                task = meeting["tasks"][taskKey];
                
                                                    // not meeting["uuid"]?
                newTask = new Task(task["uuid"], task["meeting"],
                    task["createdBy"], task["text"],
                    task["assignedTo"], task["assignedBy"],
                    task["createdAt"], task["assignedAt"]);
                    
                // Unswizzle will assign it to the meeting (and user, if 
                // appropriate.)
                newTask.unswizzle();
            }
            
        }
        
        // Now do an unswizzling pass. Need to do this one in order, too,
        // because locations need to be unswizzled before meetings, otherwise
        // the user list in meetings ends up with the occasional UUID in it
        
        // This is a kind of annoying dance to get around javascript 
        // iterating across keys instead of values. This array sets the
        // order in which we unswizzle types.
        allObjectCollections = {"actors":this.actors, "rooms":this.rooms,
            "meetings":this.meetings};
        for (objectType in allObjectCollections) {
            allObjectsOfType = allObjectCollections[objectType];
            console.log("Unswizzling: " + objectType);
            for (key in allObjectsOfType) {
                obj = allObjectsOfType[key];
                try {
                    obj.unswizzle();
                } catch (err) {
                    console.log("Failed to unswizzle: "+obj+" with error: "
                                + err);
                }
            }            
        }
    },
    
    getUsers: function() {
        
        users = [];
        for(key in this.actors) {
            actor = this.actors[key];
            if(actor instanceof User) {
                users.push(actor);
            }
        }
        
        return users;
        
    },
    
    getLocations: function() {
        
        locations = [];
        for(key in this.actors) {
            actor = this.actors[key];
            if(actor instanceof Location) {
                locations.push(actor);
            }
        }
        
        return locations;
    },
    
    getMeetings: function() {
        return this.meetings;
    }
}


// This should really be namespaced nicely, but I dont want to figure that
// out quite yet.
state = new StateManager();