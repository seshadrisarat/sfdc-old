/**
* \arg TriggerName      : SL_Opportunity
* \arg JIRATicket       : PWP-77
* \arg CreatedOn        : 23/JULY/2015
* \arg LastModifiedOn   : 23/JULY/2015
* \arg CreatededBy      : Lodhi 
* \arg ModifiedBy       : Lodhi
* \arg Description      : trigger on opportunity
*/

trigger SL_OpportunityTeamMember on OpportunityTeamMember(after delete, after insert, after update) 
{
    //Creating handler class instance
  /*  SL_OpportunityTeamMemberHandler objOppTeamHandler = new SL_OpportunityTeamMemberHandler();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            objOppTeamHandler.onAfterInsert(Trigger.newMap);    
            
        if(Trigger.isUpdate)    
            objOppTeamHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            
        if(Trigger.isDelete)
            objOppTeamHandler.onAfterDelete(Trigger.oldMap);
    } */
}