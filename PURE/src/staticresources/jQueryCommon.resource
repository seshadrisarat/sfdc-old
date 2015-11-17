var j$ = jQuery.noConflict();

function escapeColons(compName){
    var escapedString = compName.replace(/:/g,"\\:");
    return escapedString;
}
