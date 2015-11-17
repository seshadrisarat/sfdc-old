/**
* \arg ClassName        : SL_OpportunityTeamMemberHandler
* \arg JIRATicket     	: PWP-88
* \arg CreatedOn      	: 23/JULY/2015
* \arg LastModifiedOn	: 03/SEP/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Handler class for SL_OpportunityTeamMember trigger
*/
public without sharing class SL_OpportunityTeamMemberHandler 
{
    /**
	    @MethodName : onAfterInsert
	    @Param 		: new map of OpportunityTeamMember records  
	    @Description: This method called on after insert of OpportunityTeamMember records.
    **/
    public void onAfterInsert(Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamNew)
    {
        manageAccountTeamMembers(new Map<Id, Project_Coverage_Team_Member__c>(), mapIdToOppTeamNew);
    }
    /* End */
    
    /**
	    @MethodName : onAfterUpdate
	    @Param 		: old and new map of OpportunityTeamMember records 
	    @Description: This method called on after Update of OpportunityTeamMember record.
    **/
    public void onAfterUpdate(Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamOld, Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamNew)
    {
        manageAccountTeamMembers(mapIdToOppTeamOld, mapIdToOppTeamNew);
    }
    /* End */
    
    /**
	    @MethodName : onAfterDelete
	    @Param 		: old map of OpportunityTeamMember records 
	    @Description: This method called on after delete of OpportunityTeamMember record.
    **/
    public void onAfterDelete(Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamOld)
    {
        manageAccountTeamMembers(mapIdToOppTeamOld, new Map<Id, Project_Coverage_Team_Member__c>());
    }
    /* End */
    
    /**
	    @MethodName : manageAccountTeamMembers
	    @Param 		: old and new map of OpportunityTeamMember records 
	    @Description: This method will add OpportunityTeamMember to Account Team.
    **/
    private void manageAccountTeamMembers(Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamOld, Map<Id, Project_Coverage_Team_Member__c> mapIdToOppTeamNew)
    {
        Set<Id> setAccountIdToManageAccTeams = new Set<Id>();
        Set<Id> setOppotunityId = new Set<Id>();
        Set<Id> setCoverageTeamId = new Set<Id>();
        Map<String, AccountTeamMember> mapUserIdRoleToAccountTeams = new Map<String, AccountTeamMember>();
        Map<String, AccountTeamMember> mapExistingAccountTeams = new Map<String, AccountTeamMember>();
        List<AccountTeamMember> lstAccountTeamsToDelete = new List<AccountTeamMember>();
        
        //If trigger is after delete then collecting all the opportunity ids here
        if(mapIdToOppTeamNew.isEmpty())
        {
            for(Project_Coverage_Team_Member__c objOppTeam : mapIdToOppTeamOld.values())
            {
                setOppotunityId.add(objOppTeam.Project__c);
            }
        }
        //Trigger is after update of after insert 
        else
        {
            for(Project_Coverage_Team_Member__c objOppTeam : mapIdToOppTeamNew.values())
            {
                setOppotunityId.add(objOppTeam.Project__c);
                    
                if(objOppTeam.User__c != null)
                    setCoverageTeamId.add(objOppTeam.Id);
            }
        }
        
        //Collecting all account ids related to opportunity
        for(Opportunity objOpportunity : [SELECT Id, AccountId FROM Opportunity WHERE AccountId != null AND Id IN : setOppotunityId])
        {
            setAccountIdToManageAccTeams.add(objOpportunity.AccountId);
        }
        
        //Added by Lodhi as part of PWP-133 to avoid sending of email to the newly added members
        if(!mapIdToOppTeamNew.isEmpty() && mapIdToOppTeamOld.isEmpty())
            setAccountIdToManageAccTeams.addAll(setCoverageTeamId);
            
        //Calling method to insert AccountTeam members.
        if(!setAccountIdToManageAccTeams.isEmpty())
            SL_ManageAccountTeamMembers.createAccountTeamMembers(setAccountIdToManageAccTeams);    
    }
    /* End */
}