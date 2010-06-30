// Model
//
// This file contains the various core data types in the system. These look
// quite similar to model.py on the server, but is missing lots of the 
// more complicated server logic that client types don't need.

function Actor(uuid, name) {
    this.uuid = uuid;
    this.name = name;
}

Actor.prototype = {};

function User(uuid, name, location) {
    this.uuid = uuid;
    this.name = name;
    
    this.location = location;
}

$.extend(User.prototype, Actor.prototype, {
    
    
    isInLocation: function() {
        return this.location != null;
    },
    
    isInMeeting: function() {
        return this.location.isInMeeting();
    }
});

function Location(uuid, name, meeting, users) {
    this.uuid = uuid;
    this.name = name;
    
    this.meeting = meeting;
    this.users = users;
}

$.extend(Location.prototype, Actor.prototype, {
    
    userJoined: function(user) {
        this.users.push(user);
    },
    
    userLeft: function(user) {
        index = $.inArray(user, this.users);
        if(index > -1) {
            this.users.splice(index, 1);
        }
    },
    
    joinedMeeting: function (meeting){
        this.meeting = meeting;
    },
    
    
    leftMeeting: function (meeting) {
        
    },
    
    
    isInMeeting: function() {
        return this.location.isInMeeting();
    }
});



function Room() {
    // TODO fill in
}

function Meeting() {
    // TODO fill in
}



