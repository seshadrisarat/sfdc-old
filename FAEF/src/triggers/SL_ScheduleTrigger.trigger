/*
* Trigger Name  : SL_ScheduleTrigger 
* JIRA Ticket   : FAEF-3
* Created on    : 7/3/13
* Description   : The purpose of this trigger is to properly set the 
*                 Name and Schedule_Number__c fields on the schedule following the MLA-## format. 
*/

trigger SL_ScheduleTrigger on Schedule__c (after insert, before update, after update)  
{
    // Constructor
    SL_Schedule_Handler handler = new SL_Schedule_Handler(Trigger.isExecuting, Trigger.size);
    
    // After Insert
    if(trigger.isAfter && trigger.isInsert){
    	
        handler.onAfterInsert(trigger.newMap);
    }
    // Before Update
    if(trigger.isBefore && trigger.isUpdate){
        handler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
    }
    // After Update
    if(trigger.isAfter && trigger.isUpdate){
        handler.onAfterUpdate(trigger.newMap, trigger.oldMap);
    }
}