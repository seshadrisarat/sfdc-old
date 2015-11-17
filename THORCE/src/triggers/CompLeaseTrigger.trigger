trigger CompLeaseTrigger on Lease__c (before insert, before update) {
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