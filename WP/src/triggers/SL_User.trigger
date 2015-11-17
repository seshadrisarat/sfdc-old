/** 
* \author Vladislav Gumenyuk
* \date 01/08/2012
* \see https://silverline.jira.com/browse/WP-60
* \details 
* \  handling Deal.Deal_Team_Intials__c with changes in User.Initials
*/
trigger SL_User on User (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_handler_User handler = new SL_handler_User(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeInsert(Trigger.new);
        }
        else if(trigger.isAfter)
        {
            handler.OnAfterInsert(Trigger.newMap);
        }
    }
     
    else if(trigger.IsUpdate)
    {
        if(trigger.IsBefore)
        {
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
        }
        else
        {    
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
            
      //    SL_handler_User.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }  
        
}