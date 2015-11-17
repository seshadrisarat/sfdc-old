/**
*  Trigger Name   : SL_ApartmentTrigger
*  CreatedOn      : 20/SEP/2014
*  ModifiedBy     : Sanath
*  Description    : Trigger to update apartment previous status field
*/
trigger SL_ApartmentTrigger on Apartment__c (before insert, before update) 
{
	SL_ApartmentTriggerHandler objApartmentTriggerHandler = new SL_ApartmentTriggerHandler();
	
	if(trigger.isBefore && trigger.isInsert)
    { 
        objApartmentTriggerHandler.onBeforeInsert(trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        objApartmentTriggerHandler.onBeforeUpdate(trigger.oldMap,trigger.newMap);
    }
}