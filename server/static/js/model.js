// Model
//
// This file contains the various core data types in the system. These look
// quite similar to model.py on the server, but is missing lots of the 
// more complicated server logic that client types don't need.

function User(uuid, name, location) {
    this.uuid = uuid;
    this.name = name;
    
    this.location = location;
}

User.prototype = {
    
    
    isInLocation: function() {
        return this.location != null;
    },
    
    isInMeeting: function() {
        return this.location.isInMeeting();
    }
};


function Location(uuid, name, meeting, users) {
    this.uuid = uuid;
    this.name = name;
    
    this.meeting = meeting;
    this.users = users;
}

Location.prototype = {
    
    userJoined: function(user) {
        this.users.push(user);
    },
    
    userLeft: function(user) {
        this.users.remove(user);
    },
    
    joinedMeeting: function (meeting){
        this.meeting = meeting;
    },
    
    
    leftMeeting: function (meeting) {
        
    },
    
    
    isInMeeting: function() {
        return this.location.isInMeeting();
    }
};



function Room(name, roomUUID, currentMeeting) {
    this.name = name;
    this.roomUUID = roomUUID;
    this.currentMeeting = currentMeeting;
}

Room.prototype = {
    
    setMeeting: function(meeting) {
        
        if(this.currentMeeting!=null) {
            console.log("WARNING: Set the meeting on a room that already "+
            "had a meeting in it: " + meeting);
        }
        
        self.currentMeeting = meeting;
    }
    
};


function Meeting(roomUUID, title, meetingUUID) {
    this.roomUUID = roomUUID;
    this.title = title;
    this.meetingUUID = meetingUUID;
    
    this.allParticipants = [];
    
    this.locations = [];
}

Meeting.prototype = {
    userJoinedLocation: function(user, location) {
        this.allParticipants.push(user);
    },
    
    userLeftLocation: function(user, location) {
        // nothing to do, really. 
    },
    
    locationJoined: function(location) {
        this.locations.push(location);
    },
    
    locationLeft: function(location) {
        this.locations.remove(location);
    },
    
    getCurrentParticipants: function() {
        currentParticipants = [];
        
        for(location in this.locations) {
            for(user in location.getUsers()) {
                currentParticipants.push(user);
            }
        }   
        return currentParticipants;
    }
};



