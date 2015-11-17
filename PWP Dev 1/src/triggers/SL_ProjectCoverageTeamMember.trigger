/**
* \arg TriggerName      : SL_ProjectCoverageTeamMember
* \arg JIRATicket     	: PWP-241
* \arg CreatedOn      	: 1/September/2015
* \arg LastModifiedOn	: 1/September/2015
* \arg CreatededBy    	: Sathya 
* \arg ModifiedBy     	: Sathya
* \arg Description      : trigger on Project_Coverage_Team_Member__c
*/
trigger SL_ProjectCoverageTeamMember on Project_Coverage_Team_Member__c (after delete, after insert, after update) {
	
	//Creating handler class instance
    SL_OpportunityTeamMemberHandler objOppTeamHandler = new SL_OpportunityTeamMemberHandler();
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
            objOppTeamHandler.onAfterInsert(Trigger.newMap);     
            
        if(Trigger.isUpdate)    
            objOppTeamHandler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            
        if(Trigger.isDelete)
            objOppTeamHandler.onAfterDelete(Trigger.oldMap);
    }

}