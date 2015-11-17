trigger AccountTrigger on Account (before insert, before update) {

    ListingTriggerHandler objHandler = new ListingTriggerHandler();

    AddressTranslate at = new AddressTranslate();
    
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            at.translateSobjectAddresses(Trigger.new);
        }
        else if(Trigger.isUpdate)
        {
            at.findSobjectsRequiringTranslation(Trigger.newMap,trigger.oldMap);
        }
    }   
}