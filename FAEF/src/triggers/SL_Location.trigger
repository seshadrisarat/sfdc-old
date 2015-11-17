/*
* Trigger Name  : SL_Location 
* JIRA Ticket   : FAEF-5
* Created on    : 7/23/13
* Description   : The purpose of this trigger is to update the location number to the next 
*                   largest available integer when looking at the list of locations on an account. 
*                 This trigger will also update all the equipment tax rates for any equipment on non-funded schedules.
*/

trigger SL_Location on Location__c (after insert, after update)  
{
    // Constructor
    SL_Location_Handler handler = new SL_Location_Handler(Trigger.isExecuting, Trigger.size);
    
    // After Insert
    if(trigger.isAfter && trigger.isInsert){
        handler.onAfterInsert(trigger.newMap);
    }
    
    // After Update
    if(trigger.isAfter && trigger.isUpdate){
        handler.onAfterUpdate(trigger.newMap, trigger.oldMap);   
    }   
}