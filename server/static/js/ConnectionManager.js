Ext.namespace("tincan");

tincan.ConnectionManager = Ext.extend(Object, {
   userUUID: null,
   
    constructor: function() {
        console.log("Constructing a new connection manager.");
    },
    
    setUser: function(userUUID) {
        console.log("Setting userUUID: " + userUUID);
        this.userUUID = userUUID;
    },
    
    connect: function () {
        if(this.userUUID==null) {
            console.log("Must call setUser on the" + 
        "ConnectionManager before connecting.");
            return;
        }
        
        Ext.Ajax.request({
           url: '/connect/login',
           method: "POST",
           success: function () { console.log("WIN (login)");},
           failure: function () { console.log("FAIL (login)");},
           params: { "actorUUID": this.userUUID }
        });
    }
    
});

// This really should be a singleton, but I'm not really in the mood to slog
// through all this crap:
// http://stackoverflow.com/questions/1783317/singleton-pattern-and-abstraction-in-js
// 
// Faking it for now this way.
tincan.connection = new tincan.ConnectionManager();