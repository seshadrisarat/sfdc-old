/**
* \arg TriggerName      : SL_DealTeamMember
* \arg JIRATicket       : FBR-2
* \arg CreatedOn        : 19/MAR/2015
* \arg LastModifiedOn   : 1/April/2015
* \arg CreatededBy      : Pankaj Ganwani
* \arg LastModifiedBy   : Pankaj Ganwani
*/
trigger SL_DealTeamMember on Deal_Team_Member__c (after insert, after update, after delete) 
{
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            SL_DealTeamMemberHandler.onAfterInsert(Trigger.new);
        if(Trigger.isUpdate)  
			SL_DealTeamMemberHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);  
        if(Trigger.isDelete)
            SL_DealTeamMemberHandler.onAfterDelete(Trigger.old);
    }
}