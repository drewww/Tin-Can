// util.js
//
// Various utility functions that I'm tired of not having.


function array_remove(array, obj) {
    index = $.inArray(obj, array);
    if(index > -1) {
        console.log(array.splice(index, 1));
        return array.splice(index, 1);
    } else {
        return array;
    }
}

function timesince(d, now) {
    //Takes two timestamps (in seconds) && returns time between d && now
    //as a formatted string, e.g. "10h ago", but only goes up to hours
    //so an output like "74h and 3m ago" is possible.
    now = (typeof now == 'undefined') ? new Date().getTime()/1000 : now;
    
    var diff = Math.round(now - d);
    var hours = Math.floor(diff/3600);
    var minutes = Math.floor((diff-hours*3600)/60);
    var seconds = Math.floor(diff-hours*3600-minutes*60);
    
    var o = "";
    if (hours>1) o = hours+"h";
    else if (hours==1) o = "1h";
        
    if (o!="" && minutes>0) o += " and ";
        
    if (minutes>1) o += minutes+"m";
    else if (minutes==1) o += "1m";
    
    if (o!="") o += " ago";
    else o = "just now";
    
    return o;
}