/*
* Trigger Name  : SL_Proceeds_Trigger 
* JIRA Ticket   : FAEF-35
* Created on    : 18/09/2014
* Modified by   : Harsh
* Description   : Implement a trigger on Insert, Update, Delete and Undelete of Proceeds records. It will calculate the 
*/
trigger SL_Proceeds_Trigger on Proceeds__c (after insert, before insert, after undelete, after update, before delete) {

    SL_Proceeds_Handler handler = new SL_Proceeds_Handler();//Creating the instance of handler class.
    
    /* If Trigger is After Insert then calling the handler class After Insert method.*/
    if(trigger.isInsert) {
        if(Trigger.isBefore){
            handler.onBeforeInsert(trigger.new);
        }
        else{
            handler.onAfterInsert(trigger.new); 
        }
    } 
    
    /* If Trigger is After Update then calling the Handler class After Update method.*/
    if(trigger.isAfter && trigger.isUpdate) {
        
        handler.onAfterUpdate(trigger.oldMap, trigger.newMap); 
    } 
    
    /* If Trigger is Before Delete then calling the handler class After Delete method.*/
    if(trigger.isBefore && trigger.isDelete) {
        
        handler.onBeforeDelete(trigger.old);
    } 
    
    /* If Trigger is After Undelete then calling the Handler class After Undelete method.*/
    if(trigger.isAfter && trigger.isUnDelete) {
        
        handler.onAfterUnDelete(trigger.new); 
    } 

}