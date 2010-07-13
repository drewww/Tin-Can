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
        
        console.log("cookie (pre): " + document.cookie);
        $.ajax({
           url: '/connect/login',
           type: "POST",
           success: function () {
               this.isConnected = true;
               
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
                    this.dispatchEvent(events[i]);
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
        
    dispatchEvent: function(ev) {
        
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
               console.log("Joined location successfully.");
               },
           error: function () { console.log("Failed to join location.");},
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
               console.log("Joined room successfully.");
               },
           error: function () { console.log("Failed to join room.");},
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
               console.log("Left room successfully.");
               },
           error: function () { console.log("Failed to leave room.");},
           context: this,
           data: { "roomUUID": roomUUID}
        });
    },
    
    getState: function() {
        // callback is a function that we'll hand the three chunks of state
        // to when we get a response.
        $.ajax({
            url: '/connect/state',
            type: "GET",
            dataType: "JSON",
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