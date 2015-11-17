/*Trigger on insert of Equipment
* Trigger Name  : SL_Equipment 
* JIRA Ticket   : FAEF-2
* Created on    : 03/07/2013
* Modified by   : 
* Description   : Implement a trigger on insert, update and delete of Serial# field values on Equipment.
*/
trigger SL_Equipment on Equipment__c (after insert, after update, before delete, before insert, before update) 
{
    //Handler class for calling functions based on event
    SL_Equipment_Handler handler = new SL_Equipment_Handler();
    
    /*if(trigger.isAfter && trigger.isInsert)
    {
        // calling functions of handler class on after insert of Note
        sObjSLEquipmentHandler.onAfterInsert(Trigger.newMap); 
    } 
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        // calling functions of handler class on after insert of Note
        sObjSLEquipmentHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap); 
    } 
    
    if(trigger.isBefore && trigger.isInsert)
    {
        // calling functions of handler class on before insert of Note
        sObjSLEquipmentHandler.onBeforeInsert(Trigger.new);
    }
    
    if(trigger.isBefore && trigger.isUpdate)
    {
        // calling functions of handler class on before insert of Note
        sObjSLEquipmentHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }*/


    if(trigger.isAfter && trigger.isInsert)
    {
        handler.onAfterInsert(Trigger.newMap); 
    } 
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap); 
    } 

}