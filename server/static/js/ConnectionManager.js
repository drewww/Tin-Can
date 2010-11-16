
// ConnectionManager
//
// Handles all communication between Tin Can web clients and the server.
// Given a userUUID, connects and manages device authentication, etc. Keeps
// a persistent connection open to the server at all times to receive events.

function ConnectionManager() {
    console.log("INIT ConnectionManager");
}

ConnectionManager.prototype = {
   
   userUUID: null,
   currentConnectRequest: null,
   isConnected: false,
   
   eventListeners: [],
   connections: [],
   
   user: null,
   meeting: null,
   loc: null,
   loggedout: false,
   
   setUser: function(userUUID) {
        console.log("Setting userUUID: " + userUUID);
        this.userUUID = userUUID;
   },
   
   connect: function () {
       if (this.currentConnectRequest!=null){
           this.stopPersistentConnection();
           this.currentConnectRequest=null;
           setTimeout("connection.connect();",500);
       }
       else{
           this.loggedout=false;
           if(this.userUUID==null) {
               console.log("Must call setUser on the " + 
           "ConnectionManager before connecting.");
               return;
           }

           $.ajax({
              url: '/connect/login',
              type: "POST",
              success: function () {
                  this.isConnected = true;
                  this.publishEvent(this.generateEvent("LOGIN_COMPLETE", {}));

                  // Before we start a new connection, make sure to clear the
                  // previous one.
                  if(this.currentConnectRequest!=null) {
                      console.log("Aborting existing connection.");
                      this.currentConnectRequest.abort();
                  }

                  var self = this;
                  setTimeout(function() {self.startPersistentConnection();}, 0);

                  // Make sure we have an up-to-date state to work with. Doing 
                  // this after we start the persistent connection so we don't
                  // miss any state changes in the interim time between the
                  // getState and persistentConnection starting. 
                  this.getState();
                  },
              error: function () { console.log("FAIL (login)");},
              context: this,
              data: { "actorUUID": this.userUUID }
           });
       }
        
        
    },
    
    validateConnected: function () {
        if(this.isConnected == false) {
            console.log("WARNING: You must call connected before interacting"
            +" with other server commands.");
            return false;
        }
        return true;
    },
    
    startPersistentConnection: function() {
        console.log("Starting persistent connection.");
        this.currentConnectRequest = $.ajax({
            url: '/connect/',
            type: "GET",
            dataType: "JSON",
            success: function (data) {
                console.log("/connect/ succeded.");
                events = $.parseJSON(data);
                var self = this;
                
                
                if (!this.loggedout){
                    setTimeout(function(){self.startPersistentConnection();}, 10);

                    if (events!=null){
                        for(var i=0; i<events.length; i++) {
                            this.dispatchEvent(events[i]);
                        }
                    }
                    
                    // This code makes sure that we don't end up in reconnection infinite
                    // loops when the server gets restarted - it'll try to reconnect
                    // up to 10 times and then stop. Requests older than one second
                    // ago are filtered out, so this system doesn't catch normal
                    // reconnection cycles (or a few fast event transmissions that
                    // don't represent an infinite loop.)
                    time = new Date();
                    this.connections.push(time);
                    var tempConnections = []
                    for (key in this.connections){
                        if (time-this.connections[key]<1000){
                            tempConnections.push(this.connections[key]);
                        }
                    }
                    this.connections=tempConnections;
                    if (this.connections.length>10){
                        this.stopPersistentConnection();
                        $('body').html("Connection failed. Please try again.")
                    }
                    
                }
                else{
                //    this.loggedout=false;
                }
                
                // Not generating events here because dispatch is almost
                // certainly going to be generating them. 
                
                },
            error: function (data) {
                console.log("/connect/ failed. reconnecting.");
                console.log(data)
                
                this.publishEvent(this.generateEvent("CONNECT_COMPLETE", {},
                    false));
                if (!this.loggedout){
                    var self = this;
                    this.currentConnectRequest=setTimeout(
                        function() {self.startPersistentConnection();}, 500);
                }
                
                    
                },
                // Adding this extra time factor seems to help with the double
                // request issue.
            data: { "actorUUID": this.userUUID, "time": new Date().getTime() },
            context: this,
            timeout: 3600000   // 60 minute timeout. Ludicrous - there will
                               // definitely be responses faster than this, 
                               // but there doesn't seem to be a nice way to
                               // respond to timeouts. FF just throws an error
                               // and doesn't call the error callback, so
                               // we need to be quite sure it never happens.
        });
    },
    
    stopPersistentConnection: function() {
        this.loggedout = true;
        this.currentConnectRequest.abort();
        console.log("Aborted current connection.");
    },
        
    dispatchEvent: function(ev) {
        
        // Depending on the event type, update the internal state
        // appropriately
        console.log(ev);
        switch(ev.eventType) {
            case "ADD_ACTOR_DEVICE":
                // We don't really care about this one, actually.
                actor = state.getObj(ev["actorUUID"], User);
                actor.devices=actor.devices+1;
                actor.loggedIn = true;
                
                // We need to plug in the meeting detection stuff here
                // beacuse this is the only event we can guarantee firing
                // if a user logs in and the user is already in a location
                // and that location is already in a meeting. So plug in
                // the currentMeeting capture stuff here. This is in addition
                // to subsequent checks of the same thing.
                if(actor.uuid == this.userUUID){
                     this.user = user;
                     this.loc = user.loc;
                     
                     
                     // Think about the larger issues with this format
                     // sometime. Is it really a good idea to keep
                     // this.meeting separate? Maybe just refactor everything
                     // to look at this.loc.meeting instead?
                     if(this.loc.meeting != null) {
                         this.meeting = this.loc.meeting;
                     }
 
                     console.log("LOCAL location and user set: " +
                         this.loc + " / " + this.user);
                 }
                
                break;
            
            case "DEVICE_LEFT":
                actor = state.getObj(ev["actorUUID"], User);
                if (!actor.isInLocation() && actor.devices == 0){
                    actor.loggedIn = false;
                }
            
            case "DEVICE_LEFT_COMPLETE":
                console.log("hi");
                this.stopPersistentConnection();
                if (!this.user.isInLocation() && this.user.devices == 0){
                    this.user.loggedIn = false;
                }
                
                break;
                
            case "NEW_MEETING":
                meetingData = ev["results"]["meeting"]
                
                // The last param is topics - we can cheat on that, since
                // a newly created meeting isn't going to have any.
                meeting = new Meeting(meetingData["uuid"],
                    meetingData["title"], meetingData["room"],
                    meetingData["startedAt"], []);
                meeting.unswizzle();
                
                
                state.meetings.push(meeting);
                console.log("Added new meeting: " + meeting + " with data: "
                    + meetingData["uuid"] + "; " + meetingData["room"]);
                break;
                
            case "NEW_USER":
                userData = ev["results"]["actor"];
                user = new User(userData["uuid"], userData["name"],
                    userData["location"]);
                user.unswizzle();
                
                state.actors.push(user);
                console.log("New user: " + user.name);
                break;
            
            case "NEW_LOCATION":
                locData = ev["results"]["actor"];
                loc = new Location(locData["uuid"], locData["name"],
                    locData["meetingUUID"], locData["users"],
                    locData["color"]);
                loc.unswizzle();
                state.actors.push(loc);
                console.log("New location: " + loc.name);
                break;
            
            case "USER_JOINED_LOCATION":
                loc = state.getObj(ev["params"]["location"], Location);
                user = state.getObj(ev["actorUUID"], User);
                loc.userJoined(user);
                user.loggedIn=true;
                
                if(user.uuid == this.userUUID){
                    this.user = user;
                    this.loc = loc;
                    
                    console.log("LOCAL location and user set: " +
                        this.loc + " / " + this.user);
                }
                
                console.log(user.name + " joined " + loc.name);
                user.status = {type: "joined location", 
                    time: new Date(ev["params"]["joinedAt"]*1000)}
                break;
                
            case "USER_LEFT_LOCATION":
                loc = state.getObj(ev["params"]["location"], Location);
                user = state.getObj(ev["actorUUID"], User);
                loc.userLeft(user);
                
                if (this.user!=null){
                    if(user.uuid == this.user.uuid) {
                        // means WE'VE left a location.
                        this.loc = null;
                        console.log("Local location set to null.");
                    }
                }
                
                if (user.devices == 0){
                    user.loggedIn = false;
                }
                
                console.log(user.name + " left " + loc.name);
                break;
                
            case "LOCATION_JOINED_MEETING":
                meeting = state.getObj(ev["params"]["meeting"], Meeting);
                loc = state.getObj(ev.actorUUID, Location);
                meeting.locJoined(loc);
                
                if (this.loc!=null){
                    console.log("my loc: " + this.loc.uuid + " / " + loc.uuid);
                    if(loc.uuid == this.loc.uuid) {
                        this.meeting = meeting;
                        console.log("LOCAL meeting set: " + meeting);
                        this.publishEvent(this.generateEvent("LOCAL_MEETING_SET",
                            {}));

                    }
                }
                
                console.log(loc.name + " joined " + meeting.title);
                break;
                
            case "LOCATION_LEFT_MEETING":
                meeting = state.getObj(ev["params"]["meeting"], Meeting);
                loc = state.getObj(ev.actorUUID, Location);
                meeting.locLeft(loc);
                
                if (this.loc!=null){
                    if(loc.uuid == this.loc.uuid) {
                        this.meeting = null;
                    }
                }
                
                console.log(loc.name + " left " + meeting.title);
                break;
                
            case "EDIT_MEETING":
                meeting = state.getObj(ev["params"]["meeting"], Meeting);
                title = ev["params"]["title"];
                
                meeting.title=title;
                console.log("meeting "+meeting.uuid+" is now "+title);
                break;
            
            case "NEW_TOPIC":
                // we should only be getting this message for our current
                // meeting.
                topicData = ev["results"]["topic"];
                console.log("Topic data coming next");
                console.log(topicData);
                topic = new Topic(topicData["uuid"], topicData["meeting"],
                    topicData["createdBy"], topicData["text"],
                    topicData["status"], topicData["startTime"],
                    topicData["stopTime"], topicData["startActor"],
                    topicData["stopActor"], topicData["color"],
                    topicData["createdAt"]);
                topic.unswizzle();

                console.log("Made a new topic!");
                actor = state.getObj(ev.actorUUID, User)
                actor.status = {type: "created new topic", 
                    time: topic.createdAt}
                break;
            
            case "UPDATE_TOPIC":
                
                topic = state.getObj(ev["params"]["topicUUID"], Topic);
                actor = state.getObj(ev.actorUUID, User);
                
                status = ev["params"]["status"];
                
                if(topic.status=="FUTURE" && status=="CURRENT") {
                    // This means that we're starting this item,
                    // so we should mark it as such in the client.
                    topic.startActor = actor;
                    topic.startTime = new Date();
                } else if(topic.status=="CURRENT" && status=="PAST") {
                        // This means that we're stopping this item,
                        // so we should mark it as such in the client.
                        topic.stopActor = actor;
                        topic.stopTime = new Date();
                }
                
                topic.status=status;
                
                console.log("Set topic status to " + status)
                actor = state.getObj(ev.actorUUID, User)
                actor.status = {type: "edited topic", 
                    time: new Date(ev["params"]["editedAt"]*1000)}
                break;
                
            case "NEW_TASK":
                // we should only be getting this message for our current
                // meeting.
                taskData = ev["results"]["task"];
                console.log("Task data coming next");
                console.log(taskData);
                task = new Task(taskData["uuid"], taskData["meeting"],
                    taskData["createdBy"], taskData["text"],
                    taskData["assignedTo"], taskData["assignedBy"],
                    taskData["createdAt"], taskData["assignedAt"]);
                task.unswizzle();
                
                console.log("Made a new task!");
                actor = state.getObj(ev.actorUUID, User)
                actor.status = {type: "created new task", 
                    time: task.createdAt}
                break;
            
            case "DELETE_TASK":
                task = state.getObj(ev["params"]["taskUUID"],Task);
                meeting = task.meeting
                console.log(meeting);
                console.log("Deleting task:" + task.uuid)
                
                meeting.removeTask(task);
                actor = state.getObj(ev.actorUUID, User)
                actor.status = {type: "deleted task", 
                    time: new Date(ev["params"]["deletedAt"]*1000)}
                break;
                
            case "EDIT_TASK":
                task = state.getObj(ev["params"]["taskUUID"],Task);
                text = ev["params"]["text"];
                
                console.log("Task "+task.uuid+ " is "+text);
                task.text=text;
                actor = state.getObj(ev.actorUUID, User)
                actor.status = {type: "edited task", 
                    time: new Date(ev["params"]["editedAt"]*1000)}
                break;
                
            case "ASSIGN_TASK":
                task = state.getObj(ev["params"]["taskUUID"],Task);
                
                //is this supposed to be user?
                // (Yes, but only for very stupid reasons - I never settled
                //  on a proper inheretence system in JS, and getObj is
                //  hardcoded to accept either a location or a user when User
                //  is specified. This should get fixed at some point.)
                assignedBy = state.getObj(ev.actorUUID,User); 
                task.assignedAt = new Date(ev["params"]["assignedAt"]*1000);
                if(ev["params"]["deassign"]) {
                    console.log("Deassigning task.");
                    task.deassign(assignedBy);
                    assignedBy.status = {type: "deassigned task", time: task.assignedAt}                 
                } else {
                    console.log("Assigning task.");
                    assignedTo = state.getObj(ev["params"]["assignedTo"],
                        User);                    
                    task.assign(assignedBy, assignedTo);
                    assignedBy.status = {type: "assigned task", time: task.assignedAt}
                    assignedTo.status = {type: "claimed task", time: task.assignedAt}
                }
                
                break;
                
            case "HAND_RAISE":
                actor = state.getObj(ev.actorUUID, User);
                actor.handRaised = !actor.handRaised;
                
                if (actor.handRaised){
                    console.log(actor.name+" raised a hand");
                }
                else{
                    console.log(actor.name+" is no longer raising a hand");
                }
            
            case "NEW_DEVICE":
                // I don't think we care about this, do we?
                
                // maybe capture this.user here? not sure.
                break;
            
        }

        // Setting this so people downstream of these published events
        // can easily distinguish between events from the server and
        // events generated locally.
        ev.localEvent = false;
        this.publishEvent(ev);
    },
    
    generateEvent: function(type, result, success) {
        return {"eventType":type, "results":result, "success":success,
        "localEvent":true};
    },
    
    publishEvent: function(ev) {
        
        // ConnectionEvents have the form:
        // {"type":type, "results":{}}
        // Types are:
        //      CONNECT_COMPLETE    - done with initial conection, persistent
        //                            connection now open.
        //      GET_STATE_COMPLETE  - when the get_state operation is done
        //      NEW_USER_COMPLETE
        //      LEAVE_ROOM_COMPLETE
        //      JOIN_ROOM_COMPLETE
        //      JOIN_LOCATION_COMPLETE
        //      etc, basically any server-side event type + _COMPLETE
        
    
        // Loop through the list of event listeners, and trigger
        // "connectionEvent" on each of them with the event object
        // as a parameter. If they don't have that method, sucks for them -
        // make a note in the console.
        // console.log("ConnectionEvent: " + type + ".");
        
        for(key in this.eventListeners) {
            listener = this.eventListeners[key];
            
         try {
                listener.connectionEvent(ev);
            } catch (err) {
                console.log(err);
                console.log("Tried to send event " + ev.eventType + " to "
                + listener + " but connectionEvent method was missing. You " +
                " must declare that method to receive connectionEvents.");
            }
        }
    },
    
    logout: function() {
        if(!this.validateConnected()) {return;}
        
        console.log("Logging out");
        $.ajax({
           url: '/connect/logout',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("DEVICE_LEFT_COMPLETE",
                {}));
                this.stopPersistentConnection();
               },
           error: function () { this.publishEvent(this.generateEvent(
               "DEVICE_LEFT_COMPLETE", false));},
           context: this,
           data: { }
        });
    },
    
    leave: function(locationUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Logging out and leaving location");
        $.ajax({
           url: '/locations/leave',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("LEAVE_LOCATION_COMPLETE",
                {}));
                this.logout();
               },
           error: function () { this.publishEvent(this.generateEvent(
               "LEAVE_LOCATION_COMPLETE", false));},
           context: this,
           data: { "locationUUID": locationUUID }
        });
    },
    
    joinLocation: function(locationUUID, userUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Joining location: " + locationUUID);
        None=null
        
        if (userUUID==null)
            $.ajax({
               url: '/locations/join',
               type: "POST",
               success: function () {
                   this.publishEvent(this.generateEvent("JOIN_LOCATION_COMPLETE",
                    {}));
                   },
               error: function () { this.publishEvent(this.generateEvent(
                   "JOIN_LOCATION_COMPLETE", false));},
               context: this,
               data: { "locationUUID": locationUUID, "userUUID": "null" }
            });
        else{
            $.ajax({
               url: '/locations/join',
               type: "POST",
               success: function () {
                   this.publishEvent(this.generateEvent("JOIN_LOCATION_COMPLETE",
                    {}));
                   },
               error: function () { this.publishEvent(this.generateEvent(
                   "JOIN_LOCATION_COMPLETE", false));},
               context: this,
               data: { "locationUUID": locationUUID, "userUUID": userUUID }
            });
        }
    },
    
    leaveLocation: function(locationUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Leaving location: " + locationUUID);
        
        $.ajax({
           url: '/locations/leave',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("LEAVE_LOCATION_COMPLETE",
                {}));
               },
           error: function () { this.publishEvent(this.generateEvent(
               "LEAVE_LOCATION_COMPLETE", false));},
           context: this,
           data: { "locationUUID": locationUUID }
        });
    },
    
    joinRoom: function(roomUUID) {
        if(!this.validateConnected()) {return''}
        
        console.log("Joining room: " + roomUUID);
        
        $.ajax({
           url: '/rooms/join',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("JOIN_ROOM_COMPLETE",
                {}));
               },
           error: function () { this.publishEvent(this.generateEvent(
               "JOIN_ROOM_COMPLETE", {}, false));},
           context: this,
           data: { "roomUUID": roomUUID}
        });
    },
    
    leaveRoom: function(roomUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Leaving room: " + roomUUID);
        
        $.ajax({
           url: '/rooms/leave',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("LEAVE_ROOM_COMPLETE",
                {}));
               },
           error: function () {this.publishEvent(this.generateEvent(
               "LEAVE_ROOM_COMPLETE", {}, false));
           },
           context: this,
           data: { "roomUUID": roomUUID}
        });
    },
    
    leaveMeeting: function(meetingUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Leaving meeting: " + meetingUUID);
        
        $.ajax({
           url: '/rooms/leave',
           type: "POST",
           success: function () {
               this.publishEvent(this.generateEvent("LEAVE_MEETING_COMPLETE",
                {}));
               },
           error: function () { this.publishEvent(this.generateEvent(
               "LEAVE_MEETING_COMPLETE", false));},
           context: this,
           data: { "meetingUUID": meetingUUID }
        });
    },
    
    addUser: function(name, refreshState) {
        // Trigger an add-user event on the server. Will 
        
        // Be aware that you probably don't have an option connection with
        // the server at this point, so you shouldn't expect the NEW_USER
        // event to actually arrive at the client. 
        //
        // You should almost certainly call getState again on the connection
        // manager after this succeeds. Hardcoding that in for now, since
        // that seems like the easiest option.
        
        // The refreshState flag sets whether or not we should trigger a full
        // reset of the client state. This is the easiest way (right now) to 
        // make sure we have all the current users in memory, since we're not
        // going to get a message about it from the server.
        if(refreshState==null) {
            refreshState = false;
        }
        
        $.ajax({
            url: '/users/add',
            type: "POST",
            context: this,
            data: {"newUserName":name},
            success: function () {
                this.publishEvent("NEW_USER_COMPLETE", {});
                
                if(refreshState) {
                    this.getState();
                }
            },
            error: function() {
                this.publishEvent(this.generateEvent("NEW_USER_COMPLETE", {},
                false));
            }
        });
    },
    
    addLocation: function(name) {
        $.ajax({
            url: '/locations/add',
            type: "POST",
            context: this,
            data: {"newLocationName":name},
            success: function () {
                this.publishEvent(this.generateEvent("NEW_LOCATION_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("NEW_LOCATION_COMPLETE",
                    {}, false));
            }
        });
    },
    
    editMeeting: function(meetingUUID, title) {
        $.ajax({
            url: '/meetings/edit',
            type: "POST",
            context: this,
            data: {"meetingUUID":meetingUUID, "title":title},
            success: function () {
                this.publishEvent(this.generateEvent("EDIT_MEETING_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("EDIT_MEETING_COMPLETE",
                    {}, false));
            }
        });
    },
    
    addTopic: function(text) {
        $.ajax({
            url: '/topics/add',
            type: "POST",
            context: this,
            data: {"text":text},
            success: function () {
                this.publishEvent(this.generateEvent("NEW_TOPIC_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("NEW_TOPIC_COMPLETE",
                    {}, false));
            }
        });
    },
    
    updateTopic: function(topicUUID, status) {
        $.ajax({
            url: '/topics/update',
            type: "POST",
            context: this,
            data: {"status":status, "topicUUID":topicUUID},
            success: function () {
                this.publishEvent(this.generateEvent("UPDATE_TOPIC_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("UPDATE_TOPIC_COMPLETE",
                    {}, false));
            }
        });
    },
    
    removeTopic: function(topicUUID) {
        $.ajax({
            url: '/topics/delete',
            type: "POST",
            context: this,
            data: {"topicUUID":topicUUID},
            success: function () {
                this.publishEvent(this.generateEvent("DELETE_TOPIC_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("DELETE_TOPIC_COMPLETE",
                    {}, false));
            }
        });
    },
    
    restartTopic: function(topicUUID) {
        $.ajax({
            url: '/topics/restart',
            type: "POST",
            context: this,
            data: {"topicUUID":topicUUID},
            success: function () {
                this.publishEvent(this.generateEvent("RESTART_TOPIC_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("RESTART_TOPIC_COMPLETE",
                    {}, false));
            }
        });
    },
    
    addTask: function(text) {
        $.ajax({
            url: '/tasks/add',
            type: "POST",
            context: this,
            data: {"text":text},
            success: function () {
                this.publishEvent(this.generateEvent("NEW_TASK_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("NEW_TASK_COMPLETE",
                    {}, false));
            }
        });
    },
    
    deleteTask: function(taskUUID) {
        $.ajax({
            url: '/tasks/delete',
            type: "POST",
            context: this,
            data: {"taskUUID":taskUUID},
            success: function () {
                this.publishEvent(this.generateEvent("DELETE_TASK_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("DELETE_TASK_COMPLETE",
                    {}, false));
            }
        });
    },
    
    editTask: function(taskUUID, text) {
        $.ajax({
            url: '/tasks/edit',
            type: "POST",
            context: this,
            data: {"taskUUID":taskUUID,"text":text},
            success: function () {
                this.publishEvent(this.generateEvent("EDIT_TASK_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("EDIT_TASK_COMPLETE",
                    {}, false));
            }
        });
    },
    
    assignTask: function(taskUUID,assignedToUUID) {

        theData = {"taskUUID":taskUUID,"assignedToUUID":assignedToUUID};

        $.ajax({
            url: '/tasks/assign',
            type: "POST",
            context: this,
            data: theData,
            success: function () {
                this.publishEvent(this.generateEvent("ASSIGN_TASK_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("ASSIGN_TASK_COMPLETE",
                    {}, false));
            }
        });
    },
    
    deassignTask: function(taskUUID) {
        theData = {"taskUUID":taskUUID, "deassign":true};
        
        $.ajax({
            url: '/tasks/assign',
            type: "POST",
            context: this,
            data: theData,
            success: function () {
                this.publishEvent(this.generateEvent("ASSIGN_TASK_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("ASSIGN_TASK_COMPLETE",
                    {}, false));
            }
        });
    },
    
    raiseHand: function(){
        $.ajax({
            url: '/users/hand',
            type: "POST",
            context: this,
            data: {},
            success: function () {
                this.publishEvent(this.generateEvent("HAND_RAISE_COMPLETE",
                    {}));
            },
            error: function() {
                this.publishEvent(this.generateEvent("HAND_RAISE_COMPLETE",
                    {}, false));
            }
        });
    },
    
    // Returns the meeting that this client is currently in. Might be null,
    // if this client hasn't joined a meeting yet. 
    getCurrentMeeting: function() {
        return this.meeting;
    },
    
    addListener: function(callback) {
        // Pass in an object that you connectEvent called on when there is
        // a connection event. 
        
        this.eventListeners.push(callback);
    },
    
    removeListener: function(callback) {
        this.eventListeners = array_remove(this.eventListeners, callback);
    },
    
    getState: function() {
        $.ajax({
            url: '/connect/state',
            type: "GET",
            dataType: "JSON",
            context: this,
            success: function (data) {
                initialState = $.parseJSON(data);
                console.log("Received state response: (" +
                    initialState["users"].length + ") users, (" +
                    initialState["locations"].length + ") locations, (" +
                    initialState["rooms"].length + ") rooms, (" +
                    initialState["meetings"].length + ") meetings.");
                
                // console.log(state);
                
                state.initStateManager.call(state, initialState["users"],
                    initialState["locations"], initialState["rooms"],
                    initialState["meetings"]);
                
                this.publishEvent(this.generateEvent("GET_STATE_COMPLETE",
                    {}));
                }
            });
    }
};

// This really should be a singleton, but I'm not really in the mood to slog
// through all this crap:
// http://stackoverflow.com/questions/1783317/singleton-pattern-and-abstraction-in-js
// 
// Faking it for now this way.
connection = new ConnectionManager();