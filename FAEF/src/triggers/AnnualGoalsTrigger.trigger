trigger AnnualGoalsTrigger on AnnualGoals__c (after update, after insert, before insert, before update, after delete ,before delete, after undelete) 
{
    if (Trigger.isUndelete)  
    {       
        AnnualGoalsTriggerHandler.onAfterUndelete(Trigger.newMap);  
    }    
    else if (Trigger.isBefore)  
    {     
        if (Trigger.isInsert)  
        {       
            AnnualGoalsTriggerHandler.onBeforeInsert(Trigger.new); 
        }  
              
        if (Trigger.isUpdate)  
        {     
            AnnualGoalsTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }          
     }    

}