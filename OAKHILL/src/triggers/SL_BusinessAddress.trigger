/**  
* \arg TriggerName    : SL_Account
* \arg JIRATicket     : OAKHILL-3
* \arg CreatedOn      : 01/SEP/2014
* \arg LastModifiedOn : 01/SEP/2014
* \arg CreatededBy    : Lodhi
* \arg ModifiedBy     : -
* \arg Description    : Business Address Trigger
*/
trigger SL_BusinessAddress on Business_Address__c (after insert, after update, before delete) 
{
    SL_BusinessAddressHandler objBusinessAddressHandler = new SL_BusinessAddressHandler();
    //If trigger is after insert
    if(trigger.isAfter && trigger.isInsert)
    {
        objBusinessAddressHandler.onAfterInsert(trigger.new);
    }
    //If trigger is after update
    if(trigger.isAfter && trigger.isUpdate)   
    {
        objBusinessAddressHandler.OnAfterUpdate(trigger.oldMap, trigger.new);
    }   
    //If trigger is before delete
    if(trigger.isBefore && trigger.isDelete)   
    {
        objBusinessAddressHandler.onBeforeDelete(trigger.old);
    }
}