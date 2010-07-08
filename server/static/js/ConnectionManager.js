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
        console.log("cookie: " + document.cookie);
        this.currentConnectRequest = $.ajax({
            url: '/connect/',
            type: "GET",
            dataType: "JSON",
            success: function (data) {
                events = $.parseJSON(data);
                console.log(events);
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
                
                break;
            
            
        }
        
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
                    initialState["rooms"].length + ") rooms.");
                
                // console.log(state);
                
                state.initStateManager.call(state, initialState["users"],
                    initialState["locations"], initialState["rooms"]);
                    
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