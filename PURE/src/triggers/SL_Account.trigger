/* 
* Trigger Name  : SL_Trigger_Policy 
* JIRATicket    :
* Created on    : 03/24/14
* Modified by   : Kyle Lawson
* Description   : Trigger to update Contact Info records on Account when necessary.
*/

trigger SL_Account on Account (after update, before update) {
     
    SL_Account_Trigger_Handler handler = new Sl_Account_Trigger_Handler(Trigger.isExecuting, Trigger.size);
     
    if(trigger.IsUpdate){
        if(trigger.IsAfter){
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
        }
    }
}