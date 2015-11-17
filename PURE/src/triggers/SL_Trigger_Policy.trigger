/* 
* Trigger Name  : SL_Trigger_Policy 
* JIRATicket    : PURE-19
* Created on    : 02/12/2014
* Modified by   : Wes Weingartner
* Description   : trigger to help integration
*/
trigger SL_Trigger_Policy on Policy__c (after insert,after update) 
{
     
    SL_Handler_Policy handler = new SL_Handler_Policy(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsInsert && trigger.isAfter)
    {
        handler.OnAfterInsert(Trigger.newMap);
    }
    else if(trigger.IsUpdate && trigger.isAfter)
    {
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }   
}