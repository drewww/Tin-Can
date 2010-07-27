// Model
//
// This file contains the various core data types in the system. These look
// quite similar to model.py on the server, but is missing lots of the 
// more complicated server logic that client types don't need.

function User(uuid, name, loc) {
    this.uuid = uuid;
    this.name = name;
    
    this.loc = loc;
    
    state.putObj(this.uuid, this);
}

User.prototype = {
    
    isInLocation: function() {
        return this.loc != null;
    },
    
    isInMeeting: function() {
        if(this.isInLocation) {
            return this.loc.isInMeeting();
        } else {
            return false;
        }
    },
    
    unswizzle: function() {
        // Converts uuids back into objects.
        // This is deceptive and will never execute beacuse the link between
        // users and locations is made on the location side.
        // if(this.loc != null) {
        //     this.loc = state.getObj(this.loc, Location);
        // }
    }
};


function Location(uuid, name, meeting, users) {
    this.uuid = uuid;
    this.name = name;
    
    this.meeting = meeting;
    this.users = users;
    
    state.putObj(this.uuid, this);
}

Location.prototype = {
    
    userJoined: function(user) {
        this.users.push(user);
        user.loc = this;
    },
    
    userLeft: function(user) {
        array_remove(this.users, user);
        user.loc = null;
    },
    
    joinedMeeting: function (meeting){
        this.meeting = meeting;
    },
    
    
    leftMeeting: function (meeting) {
        this.meeting = null;
    },
    
    isInMeeting: function() {
        return this.meeting != null;
    },
    
    unswizzle: function() {

        
        newUsersList = [];
        for (key in this.users) {
            user = state.getObj(this.users[key], User);
            user.loc = this;
            newUsersList.push(user);
        }
        
        this.users = newUsersList;
        
        if(this.meeting!=null) {
            this.meeting = state.getObj(this.meeting, Meeting);
            this.meeting.locJoined(this);
        }
        
    }
    
};



function Room(name, uuid, currentMeeting) {
    this.name = name;
    this.uuid = uuid;
    this.currentMeeting = currentMeeting;
    
    state.putObj(this.uuid, this);
}

Room.prototype = {
    
    setMeeting: function(meeting) {
        
        if(this.currentMeeting!=null) {
            console.log("WARNING: Set the meeting on a room that already "+
            "had a meeting in it: " + meeting);
        }
        
        self.currentMeeting = meeting;
    },
    
    unswizzle: function() {
        if(this.currentMeeting!=null) {
            this.currentMeeting = state.getObj(this.currentMeeting, Meeting);
        }
    }
    
};


function Meeting(uuid, title, room) {
    this.room = room;
    this.title = title;
    this.uuid = uuid;
    
    this.allParticipants = [];
    
    this.locs = [];
    
    this.topics = [];
    
    state.putObj(this.uuid, this);
}

Meeting.prototype = {
    userJoinedLocation: function(user, loc) {
        this.allParticipants.push(user);
    },
    
    userLeftLocation: function(user, loc) {
        // nothing to do, really. 
    },
    
    locJoined: function(loc) {
        this.locs.push(loc);
        loc.joinedMeeting(this);
        
        for(key in loc.users) {
            this.userJoinedLocation(loc.users[key]);
        }
    },
    
    locLeft: function(loc) {
        loc.leftMeeting(this);
        array_remove(this.locs, loc);
    },
    
    getCurrentParticipants: function() {
        currentParticipants = [];
        
        for(loc in this.locs) {
            for(user in loc.getUsers()) {
                currentParticipants.push(user);
            }
        }   
        return currentParticipants;
    },
    
    addTopic: function(topic) {
        this.topics.push(topic);
    },
    
    removeTopic: function(topic) {
        this.topics = array_remove(this.topics, topic);
    },
    
    unswizzle: function() {
        
        // This can't be null.
        this.room = state.getObj(this.room, Room);
        this.room.currentMeeting = this;
        // We don't need to unswizzle locs or participants; those get
        // handled when the loc unswizzles. It'll register itself
        // with the meeting it's currently in. 
    }
    
};

function Topic(uuid, meetingUUID, creatorUUID, text, status, startTime, stopTime, startActorUUID,
    stopActorUUID, color) {
        
        this.uuid = uuid;
        this.meeting = meetingUUID;
        this.creator = creatorUUID;
        this.text = text;
        this.status = status;
        this.startTime = startTime;
        this.stopTime = stopTime;
        this.startActor = startActorUUID;
        this.stopActor = stopActorUUID;
        this.color = color;
        
        state.putObj(this.uuid, this);
}

Topic.prototype = {
    
    unswizzle: function() {
        
        this.meeting = state.getObj(this.meeting, Meeting);
        this.creator = state.getObj(this.creator, User);
        
        if(this.startActor != null)
            this.startActor = state.getObj(this.startActor, User);

        if(this.stopActor != null)
            this.stopActor = state.getObj(this.stopActor, User);
        
        this.meeting.addTopic(this);
    }
}


