/** 
* \author Vlad Gumenyuk 
* \date 10/10/2012
* \see https://silverline.jira.com/browse/WP-8, https://silverline.jira.com/browse/WP-7
* \ Company Team Member Trigger
* \details Additional 
* \ Trigger logic on Deal Team on Insert/Update/Delete to keep "Company Team Member" object up-to-date with all deals in the system. Only the Deal, Company, Employee (Contact), and Status information will be shared in the resulting record.
*/
trigger SL_Deal_Team on Deal_Team__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_handler_Deal_Team handler = new SL_handler_Deal_Team(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_handler_Deal_Team.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else{           
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
      //    SL_handler_Deal_Team.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //    SL_handler_Deal_Team.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        handler.OnUndelete(trigger.new);
    }
             
}