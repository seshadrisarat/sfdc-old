trigger ObjectChangeLogTrigger on pi__ObjectChangeLog__c (before insert) {
    if (Trigger.isInsert) {
        system.debug('In the ObjectChangeLog trigger');
        
        //Assign lead to Pardot user associated with the brand
        PardotAssignment.assignToPardotOwner(trigger.new); 
    }
}