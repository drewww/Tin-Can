Ext.namespace("tincan");

tincan.connection = Ext.extend(Object, {
   
    constructor: function() {
        console.log("Constructing a new connection manager.");
    }
});


// Create the single one we need. This should be a singleton, I guess, but
// I can't wrap my head around how to officially do that in JS yet.
tincan.state = new tincan.connection();