Ext.namespace("tincan");

tincan.ConnectionManager = Ext.extend(Object, {
   
   userUUID: null,
   currentConnectRequest: null,
   
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
               this.startPersistentConnection.defer(50, this);
               },
           failure: function () { console.log("FAIL (login)");},
           scope: this,
           params: { "actorUUID": this.userUUID }
        });
        
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
        
    }
    
});

// This really should be a singleton, but I'm not really in the mood to slog
// through all this crap:
// http://stackoverflow.com/questions/1783317/singleton-pattern-and-abstraction-in-js
// 
// Faking it for now this way.
tincan.connection = new tincan.ConnectionManager();