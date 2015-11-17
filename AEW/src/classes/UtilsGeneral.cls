global class UtilsGeneral {
    
    global static sObject newBlankSObject(sObject so) {
        return so.getSObjectType().newSObject();
    }
    
}