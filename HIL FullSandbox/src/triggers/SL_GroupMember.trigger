/**
* @TriggerName  : SL_GroupMember   
* @JIRATicket   : HIL-20
* @CreatedOn    : 22/July/2015
* @ModifiedBy   : Nrusingh
* @Description  : Trigger on Group Member...
*/

trigger SL_GroupMember on Group_Member__c (after delete, after update, after insert, before delete, before update)
{
	// Callinng Handler class
	SL_GroupMemberHandler objGroupMemberHandler = new SL_GroupMemberHandler();
	
	if(trigger.isAfter) 
	{
 		if(trigger.isInsert)
   			objGroupMemberHandler.onAfterInsert(trigger.new);
 		if(trigger.isDelete)
  			objGroupMemberHandler.onAfterDelete(trigger.oldMap);
  		if(trigger.isUpdate)
  			objGroupMemberHandler.onAfterUpdate(trigger.newMap, trigger.oldMap);	
 	}
 	if(trigger.isBefore) 
	{
 		if(trigger.isDelete)
  			objGroupMemberHandler.onBeforeDelete(trigger.oldMap);
  		if(trigger.isUpdate)
  			objGroupMemberHandler.onBeforeUpdate(trigger.newMap, trigger.oldMap);
 	}
}