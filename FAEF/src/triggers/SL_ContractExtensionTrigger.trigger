/*
* Trigger Name  : SL_ContractExtensionTrigger 
* JIRA Ticket   : FAEF-34
* Created on    : 01/09/2015
* Modified by   : Pradeep
* Description   : Implement a trigger on Contract Extension to create Proceed records for contract extensions and update its Schedule with given field mapping. 
*/

trigger SL_ContractExtensionTrigger on Contract_Extension__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) 
{
    SL_ContractExtensionTriggerHandler handler = new SL_ContractExtensionTriggerHandler();
    
    /* If Trigger is After Insert then calling the handler class After Insert method.*/
    if(trigger.isAfter && trigger.isInsert) 
    { 
        handler.onAfterInsert(trigger.newMap); 
    } 
    /* If Trigger is before Insert then calling the handler class before Insert method.*/
    if(trigger.isBefore && trigger.isInsert) 
    {
        handler.onBeforeInsert(trigger.new); 
    }
    
    /* If Trigger is before Insert then calling the handler class before Insert method.*/
    if(trigger.isBefore && trigger.isUpdate) 
    {
        handler.onBeforeUpdate(trigger.new); 
    }
    
    /* If Trigger is after update then calling the handler class after update method.*/
    if(trigger.isAfter && trigger.isUpdate) 
    {
        handler.onAfterUpdate(trigger.oldMap,trigger.newMap);   
    }
}