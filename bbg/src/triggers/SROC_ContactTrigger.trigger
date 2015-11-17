//Trigger on Contact
trigger SROC_ContactTrigger on Contact (after insert,before update) {

	SROC_ContactTriggerHandler handler = new SROC_ContactTriggerHandler();
    
    //On After Insert Case
    if(Trigger.isafter && Trigger.isInsert) {

        handler.onAfterInsert(Trigger.new);
    }
    
    //On Before Update Case
    if(Trigger.isbefore && Trigger.isUpdate) {

        handler.onBeforeUpdate(Trigger.oldMap,Trigger.newMap); 
    }
}