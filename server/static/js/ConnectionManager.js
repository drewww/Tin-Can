// ConnectionManager
//
// Handles all communication between Tin Can web clients and the server.
// Given a userUUID, connects and manages device authentication, etc. Keeps
// a persistent connection open to the server at all times to receive events.

function ConnectionManager() {
    console.log("Constructing a new connection manager.");
}

ConnectionManager.prototype = {
   
   userUUID: null,
   currentConnectRequest: null,
   isConnected: false,
   
   eventListeners: [],
   
   setUser: function(userUUID) {
        console.log("Setting userUUID: " + userUUID);
        this.userUUID = userUUID;
   },
   
   connect: function () {
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
               this.publishEvent("CONNECT_COMPLETE", {});
               
               var self = this;
               this.currentConnectRequest=setTimeout(
                   function() {self.startPersistentConnection();}, 10);
               },
           error: function () { console.log("FAIL (login)");},
           context: this,
           data: { "actorUUID": this.userUUID }
        });
        
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
        this.currentConnectRequest = $.ajax({
            url: '/connect/',
            type: "GET",
            dataType: "JSON",
            success: function (data) {
                events = $.parseJSON(data);
                var self = this;
                this.currentConnectRequest=setTimeout(
                    function() {self.startPersistentConnection();}, 10);
                    
                for(var i=0; i<events.length; i++) {
                    this.publishEvent(events[i]);
                }
                
                },
            error: function () {
                console.log("/connect/ failed. reconnecting.");
                
                var self = this;
                this.currentConnectRequest=setTimeout(
                    function() {self.startPersistentConnection();}, 500);
                    
                },
            data: { "actorUUID": this.userUUID },
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
        this.currentConnectRequest.abort();
        Console.log("Aborted current connection.");
    },
        
    publishEvent: function(ev) {
        
        // Depending on the event type, update the internal state
        // appropriately
        
        switch(ev.eventType) {
            case "ADD_ACTOR_DEVICE":
                // We don't really care about this one, actually.
                break;
            case "NEW_MEETING":
                meetingData = ev["results"]["meeting"]
                
                meeting = new Meeting(meetingData["uuid"],
                    meetingData["title"], meetingData["room"]);
                meeting.unswizzle();
                
                state.meetings.push(meeting);
                console.log("Added new meeting: " + meeting + " with data: "
                    + meetingData["uuid"] + "; " + meetingData["room"]);
                break;
            case "NEW_USER":
                userData = ev["results"]["user"];
                user = new User(userData["uuid"], userData["name"],
                    userData["location"]);
                user.unswizzle();
                
                state.actors.push(user);
                break;
            case "USER_JOINED_LOCATION":
                loc = state.getObj(ev["params"]["location"], Location);
                user = state.getObj(ev["actorUUID"], User);
                loc.userJoined(user);
                console.log(user.name + " joined " + loc.name);
                break;
            case "USER_LEFT_LOCATION":
                loc = state.getObj(ev["params"]["location"], Location);
                user = state.getObj(ev["actorUUID"], User);
                loc.userLeft(user);
                console.log(user.name + " left " + loc.name);
                break;
            case "LOCATION_JOINED_MEETING":
                meeting = state.getObj(ev["meetingUUID"], Meeting);
                loc = state.getObj(ev["params"]["location"], Location);
                meeting.locJoined(loc);
                console.log(loc.name + " joined " + meeting.title);
                break;
            case "LOCATION_LEFT_MEETING":
                meeting = state.getObj(ev["meetingUUID"], Meeting);
                loc = state.getObj(ev["params"]["location"], Location);
                meeting.locLeft(loc);
                
                console.log(loc.name + " left " + meeting.title);
                break;
            case "NEW_DEVICE":
                // I don't think we care about this, do we? I'm not even sure
                // it gets sent to clients. 
                break;
            
        }

        // TODO Set up a listener infrastructure so we can update pages live,
        // too. They'll register for event types and we'll send them on
        // when they arrive.
        
      console.log("EVENT: <" + ev.eventType + ">");
    },
    
    joinLocation: function(locationUUID) {
        if(!this.validateConnected()) {return;}
        
        console.log("Joining location: " + locationUUID);
        
        $.ajax({
           url: '/locations/join',
           type: "POST",
           success: function () {
               this.publishEvent("JOIN_LOCATION_COMPLETE", {});
               },
           error: function () { this.publishEvent("JOIN_LOCATION_COMPLETE",{},
            false);},
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
               this.publishEvent("JOIN_ROOM_COMPLETE", {});
               },
           error: function () { this.publishEvent("JOIN_ROOM_COMPLETE", {},
           false);},
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
               this.publishEvent("LEAVE_ROOM_COMPLETE", {});
               },
           error: function () {this.publishEvent("LEAVE_ROOM_COMPLETE", {},
            false);
           },
           context: this,
           data: { "roomUUID": roomUUID}
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
                this.publishEvent("NEW_USER_COMPLETE", {}, false);
            }
        });
    },
    
    addListener: function(callback) {
        // Pass in an object that you connectEvent called on when there is
        // a connection event. 
        
        this.eventListeners.push(callback);
    },
    
    removeListener: function(callback) {
        this.eventListeners = array_remove(this.eventListeners, callback);
    },
    
    publishEvent: function(type, result, success) {
        
        // ConnectionEvents have the form:
        // {"type":type, "results":{}}
        // Types are:
        //      CONNECT_COMPLETE    - done with initial conection, persistent
        //                            connection now open.
        //      GET_STATE_COMPLETE  - when the get_state operation is completed
        //      NEW_USER_COMPLETE
        //      LEAVE_ROOM_COMPLETE
        //      JOIN_ROOM_COMPLETE
        //      JOIN_LOCATION_COMPLETE
        //      etc, basically any server-side event type + _COMPLETE
        
        if(success==null) {
            success = true;
        }
        
        e = {"type": type, "result":result, "success":success};
        
        // Loop through the list of event listeners, and trigger
        // "connectionEvent" on each of them with the event object
        // as a parameter. If they don't have that method, sucks for them -
        // make a note in the console.
        console.log("ConnectionEvent: " + e.type + ".");
        
        for(key in this.eventListeners) {
            listener = this.eventListeners[key];
            
            try {
                listener.connectionEvent(e);
            } catch (err) {
                console.log("Tried to send event " + e + " to " + listener + 
                " but connectionEvent method was missing. You must declare" +
                " that method to receive connectionEvents.");
            }
        }
    },
    
    getState: function() {
        // callback is a function that we'll hand the three chunks of state
        // to when we get a response.
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
                
                this.publishEvent("GET_STATE_COMPLETE", {});
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