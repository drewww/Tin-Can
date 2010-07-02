// util.js
//
// Various utility functions that I'm tired of not having.

Array.prototype.remove = function(obj) {
    index = $.inArray(obj, this);
    if(index > -1) {
        this.splice(index, 1);
    }
};