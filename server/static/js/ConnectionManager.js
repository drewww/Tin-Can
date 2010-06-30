Ext.namespace("tincan");

tincan.ConnectionManager = Ext.extend(Object, {
   
   userUUID: null,
   currentConnectRequest: null,
   isConnected: false,
   
    constructor: function() {
        console.log("Constructing a new connection manager.");
    },
    
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
        Ext.Ajax.request({
           url: '/connect/login',
           method: "POST",
           success: function () {
               console.log("WIN (login)");
               console.log("cookie (post): " + document.cookie);
               this.isConnected = true;
               this.startPersistentConnection.defer(50, this);
               },
           failure: function () { console.log("FAIL (login)");},
           scope: this,
           params: { "actorUUID": this.userUUID }
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
        this.currentConnectRequest = Ext.Ajax.request({
            url: '/connect/',
            method: "GET",
            success: function () {
                console.log("/connect/ closed sucessfully, reconnecting.");
                this.currentConnectRequest=this.startPersistentConnection.defer(10, this);
                console.log("Kicked off next request.");
                },
            failure: function () {
                console.log("/connect/ failed. reconnecting.");
                
                this.currentConnectRequest=this.startPersistentConnection.defer(500, this);
                console.log("Kicked off next request, with delay.");
                },
            params: { "actorUUID": this.userUUID },
            scope: this,
            timeout: 3600000   // 60 minute timeout. Ludicrous - there will
                               // definitely be responses faster than this, 
                               // but there doesn't seem to be a nice way to
                               // respond to timeouts. FF just throws an error
                               // and doesn't call the failure callback, so
                               // we need to be quite sure it never happens.
        });
    },
    
    stopPersistentConnection: function() {
        Ext.Ajax.abort(this.currentConnectRequest);
        Console.log("Aborted current connection.");
    },
    
    
    joinLocation: function(locationUUID) {
        if(!this.validateConnected()) {return}
        
        console.log("Joining location: " + locationUUID);
        
        Ext.Ajax.request({
           url: '/locations/join',
           method: "POST",
           success: function () {
               console.log("Joined location successfully.");
               },
           failure: function () { console.log("Failed to join location.");},
           scope: this,
           params: { "locationUUID": locationUUID }
        });
    },
    
    joinRoom: function(roomUUID) {
        if(!this.validateConnected()) {return}
        
        console.log("Joining room: " + roomUUID);
        
        Ext.Ajax.request({
           url: '/rooms/join',
           method: "POST",
           success: function () {
               console.log("Joined room successfully.");
               },
           failure: function () { console.log("Failed to join room.");},
           scope: this,
           params: { "roomUUID": roomUUID}
        });
    },
    
    leaveRoom: function(roomUUID) {
        if(!this.validateConnected()) {return}
        
        console.log("Leaving room: " + roomUUID);
        
        Ext.Ajax.request({
           url: '/rooms/leave',
           method: "POST",
           success: function () {
               console.log("Left room successfully.");
               },
           failure: function () { console.log("Failed to leave room.");},
           scope: this,
           params: { "roomUUID": roomUUID}
        });
    },
});

// This really should be a singleton, but I'm not really in the mood to slog
// through all this crap:
// http://stackoverflow.com/questions/1783317/singleton-pattern-and-abstraction-in-js
// 
// Faking it for now this way.
tincan.connection = new tincan.ConnectionManager();