// util.js
//
// Various utility functions that I'm tired of not having.


function array_remove(array, obj) {
    index = $.inArray(obj, array);
    console.log("index: " + index);
    if(index > -1) {
        console.log("splicing!");
        console.log("result: ");
        console.log(array.splice(index, 1));
        return array.splice(index, 1);
    } else {
        return array;
    }
}