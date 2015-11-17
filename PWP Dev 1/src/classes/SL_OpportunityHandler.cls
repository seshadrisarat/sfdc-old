/**
* \arg ClassName        : SL_OpportunityHandler
* \arg JIRATicket     	: PWP-77
* \arg CreatedOn      	: 23/JULY/2015
* \arg LastModifiedOn	: 03/SEP/2015
* \arg CreatededBy    	: Lodhi 
* \arg ModifiedBy     	: Lodhi
* \arg Description      : Handler class for SL_Opportunity trigger
*/
public without sharing class SL_OpportunityHandler 
{
    /* Start - Variables */
    /* End - Variables */
    
    /**
	    @MethodName : onAfterInsert
	    @Param 		: new map of Opportunity records  
	    @Description: This method called on after insert of Opportunity records.
    **/
    public void onAfterInsert(Map<Id, Opportunity> mapIdToOpportunityNew)
    {
        updateAccountRelationshipStatus(new Map<Id, Opportunity>(), mapIdToOpportunityNew);
    }
    /* End */
    
    /**
	    @MethodName : onAfterUpdate
	    @Param 		: old and new map of Opportunity records 
	    @Description: This method called on after Update of Opportunity record.
    **/
    public void onAfterUpdate(Map<Id, Opportunity> mapIdToOpportunityOld, Map<Id, Opportunity> mapIdToOpportunityNew)
    {
        updateAccountRelationshipStatus(mapIdToOpportunityOld, mapIdToOpportunityNew);
    }
    /* End */
    
    /**
	    @MethodName : onAfterDelete
	    @Param 		: old map of Opportunity records 
	    @Description: This method called on after delete of Opportunity record.
    **/
    public void onAfterDelete(Map<Id, Opportunity> mapIdToOpportunityOld)
    {
        updateAccountRelationshipStatus(mapIdToOpportunityOld, new Map<Id, Opportunity>());
    }
    /* End */
    
    /**
	    @MethodName : updateAccountRelationshipStatus
	    @Param 		: old and new map of Opportunity records 
	    @Description: This method will update the relationship status field on the corresponding account.
    **/
    private void updateAccountRelationshipStatus(Map<Id, Opportunity> mapIdToOpportunityOld, Map<Id, Opportunity> mapIdToOpportunityNew)
    {
        Set<Id> setAccountIdToManageAccTeams = new Set<Id>();
        Set<Id> setAccountIds = new Set<Id>();
        Map<Id, Account> mapIdToAccountUpdate = new Map<Id, Account>();
        Map<String, Opportunity> mapStageAccountIdToOpportunity = new Map<String, Opportunity>();
        
        //If trigger is after delete
        if(mapIdToOpportunityNew.isEmpty())
        {
            for(Opportunity objOpportunity : mapIdToOpportunityOld.values())
            {
                if(objOpportunity.AccountId != null)
                {
                    setAccountIds.add(objOpportunity.AccountId);
                    setAccountIdToManageAccTeams.add(objOpportunity.AccountId); 
                }    
            }
        }
        
        else
        {
            for(Opportunity objNewOpp : mapIdToOpportunityNew.values())
            {
                Opportunity objOldOpp = mapIdToOpportunityOld.get(objNewOpp.Id);
                
                if(objNewOpp.AccountId != null 
                   && (Trigger.isInsert || hasValueChanged('StageName', objOldOpp, objNewOpp) || hasValueChanged('AccountId', objOldOpp, objNewOpp)
                   || hasValueChanged('CloseDate', objOldOpp, objNewOpp) || hasValueChanged('Business_Group__c', objOldOpp, objNewOpp)))
                {                   
                    setAccountIds.add(objNewOpp.AccountId);
                }  
                
                if(Trigger.isUpdate && objOldOpp.AccountId != null && hasValueChanged('AccountId', objOldOpp, objNewOpp))
                    setAccountIds.add(objOldOpp.AccountId);  
                    
                if(objNewOpp.AccountId != null && Trigger.isUpdate && hasValueChanged('StageName', objOldOpp, objNewOpp))   
                    setAccountIdToManageAccTeams.add(objNewOpp.AccountId);    
            }
        }
        
        //preparing a map of combination of opportunity stagename and account id as key and opportunity as value
        for(Opportunity objOpportunity : [SELECT Id, StageName, 
                                                 AccountId, CloseDate,
                                                 Business_Group__r.Name
                                            FROM Opportunity 
                                           WHERE AccountId IN : setAccountIds 
                                        ORDER BY CloseDate DESC])
        {
            if(!mapStageAccountIdToOpportunity.containsKey(objOpportunity.StageName +'_'+ objOpportunity.AccountId))   
                mapStageAccountIdToOpportunity.put(objOpportunity.StageName +'_'+ objOpportunity.AccountId, objOpportunity);
        }
        
        //Iterating on set of account id to update Project_Business_Group__c, Status__c and Project_Status_Date__c on the correspoding account 
        for(Id accountId : setAccountIds)
        {
            Opportunity objOpportunity;
            if(mapStageAccountIdToOpportunity.containsKey('Active Mandate_'+accountId))
            {
                objOpportunity = mapStageAccountIdToOpportunity.get('Active Mandate_'+accountId);
                mapIdToAccountUpdate.put(accountId, new Account(Id = accountId, Project_Business_Group__c = objOpportunity.Business_Group__r.Name,
                                                                Status__c = 'Active Client', Project_Status_Date__c = objOpportunity.CloseDate));
            }
            else if(mapStageAccountIdToOpportunity.containsKey('Prospective Mandate_'+accountId))
            {
                objOpportunity = mapStageAccountIdToOpportunity.get('Prospective Mandate_'+accountId);
                mapIdToAccountUpdate.put(accountId, new Account(Id = accountId, Project_Business_Group__c = objOpportunity.Business_Group__r.Name,
                                                                Status__c = 'Prospective Client',Project_Status_Date__c = objOpportunity.CloseDate));
            }
            else if(mapStageAccountIdToOpportunity.containsKey('Previous Mandate_'+accountId))
            {
                objOpportunity = mapStageAccountIdToOpportunity.get('Previous Mandate_'+accountId);
                mapIdToAccountUpdate.put(accountId, new Account(Id = accountId, Project_Business_Group__c = objOpportunity.Business_Group__r.Name,
                                                                Status__c = 'Past Mandate', Project_Status_Date__c = objOpportunity.CloseDate));
            }
            else if(mapStageAccountIdToOpportunity.containsKey('Lost/Cancelled_'+accountId))
            {
                objOpportunity = mapStageAccountIdToOpportunity.get('Lost/Cancelled_'+accountId);
                mapIdToAccountUpdate.put(accountId, new Account(Id = accountId, Project_Business_Group__c = objOpportunity.Business_Group__r.Name,
                                                                Status__c = 'Lost Mandate', Project_Status_Date__c = objOpportunity.CloseDate));
            }
            else
            {
                mapIdToAccountUpdate.put(accountId, new Account(Id = accountId, Project_Business_Group__c = null,
                                                                Status__c = null, Project_Status_Date__c = null));
            }
        }
        update mapIdToAccountUpdate.values();
        
        //Calling method to insert AccountTeam members.
        if(!setAccountIdToManageAccTeams.isEmpty())
            SL_ManageAccountTeamMembers.createAccountTeamMembers(setAccountIdToManageAccTeams);
    }
    /* End */
    
    /**
	    @MethodName : hasValueChanged
	    @Param 		: field api name, old and new sobject records 
	    @Description: This method serves as a utility method to detect the changes in field values.
    **/
    private static Boolean hasValueChanged(String strFieldAPIName, Sobject oldRecord, Sobject newRecord)
    {
        return oldRecord.get(strFieldAPIName) != newRecord.get(strFieldAPIName);
    }
    /* End */
}