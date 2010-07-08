// util.js
//
// Various utility functions that I'm tired of not having.


function array_remove_object(array, obj) {
    index = $.inArray(obj, array);
        if(index > -1) {
            return array.splice(index, 1);
        }
}