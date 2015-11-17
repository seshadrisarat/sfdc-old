/**
*  ClassName      : SL_ContactRoleTriggerHandler
*  JIRATicket     : THOR-21,THOR-69
*  CreatedOn      : 13/AUG/2014
*  ModifiedBy     : Pradeep
*  Description    : This is the handler class to update associated Person account when ContactRole is inserted or updated.
*/
public with sharing class SL_ContactRoleTriggerHandler 
{
	/*
    	* MethodName   : onAfterInsert
        * param        : trigger.new
        * Description  : Will invoke on After insert of Contact Role record
    */
	public void onAfterInsert(List<Contact_Role__c> lstContactRole)
	{
		updateAssociatedPersonAccount(lstContactRole);
	}
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.new
        * Description  : Will invoke on After Update of Contact Role record
    */
	public void onAfterUpdate(List<Contact_Role__c> lstContactRole)
	{
		Set<Id> setOpportunityId = new Set<Id>();
		
		updateAssociatedPersonAccount(lstContactRole);
		
		///Create a set of parent opportunity id
		for(Contact_Role__c objContactRole:lstContactRole)
		{
			if(objContactRole.Opportunity__c != null)
				setOpportunityId.add(objContactRole.Opportunity__c);
		}
		
		if(!setOpportunityId.isEmpty())
			updateAssociatedOpportunity(setOpportunityId);

		/*Added for THOR-69*/	
		List<Contact_Role__c> lstContactRoleApproved = new List<Contact_Role__c>();
		set<Id> setOpportunityIdforApproved = new set<Id>();
		for(Contact_Role__c objContactRole : lstContactRole)
		{
			if(objContactRole.Status__c == 'Application Approved')
			{
				lstContactRoleApproved.add(objContactRole);
				setOpportunityIdforApproved.add(objContactRole.Opportunity__c);
			}
		}
		if(!lstContactRoleApproved.isEmpty())
			updateOpportunityOnApplicationApproval(lstContactRoleApproved , setOpportunityIdforApproved);	
		/*Added for THOR-69*/
	}
	
	/*
    	* MethodName   : updateAssociatedPersonAccount
        * param        : trigger.new
        * Description  : Method used to update associated Person account when ContactRole is inserted or updated.
    */
	private void updateAssociatedPersonAccount(List<Contact_Role__c> lstContactRole)
	{
        map<Id,Account> mapPersonAccountId_PersonAccount = new map<Id,Account>();
        map<String,String> mapContactRoleField_PersonAccountField = new map<String,String>();
        sObject objSobjectPersonAccount = new Account();
        sObject objSobjectContactRole = new Contact_Role__c();
        
        ///Create map of contact role field api name to person account field api name
        for(SL_ContactRoleToPersonAccount__c objContactRoleToPersonAccount:[SELECT Name, Contact_Role_Field_API_Name__c 
                                                                            FROM SL_ContactRoleToPersonAccount__c])
        {
        	mapContactRoleField_PersonAccountField.put(objContactRoleToPersonAccount.Contact_Role_Field_API_Name__c,objContactRoleToPersonAccount.Name);
        }
        
        ///Create data for person account to be updated
		for(Contact_Role__c objContactRole : lstContactRole)		
        {
    		objSobjectPersonAccount = new Account();
    		objSobjectContactRole = new Contact_Role__c();
			objSobjectContactRole = objContactRole; 
			objSobjectPersonAccount.put('Id',objContactRole.Person_Account__c); 
			
			///Put the values of different fields from Contact role to person account object  
			for(String objString:mapContactRoleField_PersonAccountField.keyset())
			{
				if(objSobjectContactRole.get(objString) != null)
					objSobjectPersonAccount.put(mapContactRoleField_PersonAccountField.get(objString),objSobjectContactRole.get(objString));
			} 
        	mapPersonAccountId_PersonAccount.put(objContactRole.Person_Account__c,(Account)objSobjectPersonAccount);
        }
        
    	database.update(mapPersonAccountId_PersonAccount.values(),false);
	}
	
	
	/*
    	* MethodName   : updateAssociatedOpportunity
        * param        : Set<Id> setOpportunityId
        * Description  : Method to update associated Opportunity of Contact role
    */
	private void updateAssociatedOpportunity(Set<Id> setOpportunityId)
	{
		List<Opportunity> lstOpportunityToUpdateToApplicationSubmitted = new List<Opportunity>();
		List<Opportunity> lstOpportunityToUpdateToDocumentsSubmitted = new List<Opportunity>();
		
		///Create data for Opportunity Stage
		for(Opportunity objOpportunity:[SELECT Id,StageName,(SELECT Id,Status__c FROM Contact_Roles__r)
		                                FROM Opportunity
		                                WHERE Id IN:setOpportunityId])
		{
			String strStageName = objOpportunity.StageName;
			
			///Make Stage on opp as 'Application Submitted' when all related contact role have status 'Submitted Application'
			for(Contact_Role__c objContactRole:objOpportunity.Contact_Roles__r)
			{
				if(objContactRole.Status__c == 'Submitted Application')
				{
					objOpportunity.StageName ='Application Submitted';
				}
				else
				{
					objOpportunity.StageName = strStageName;
					break;
				}	
			}
			
			lstOpportunityToUpdateToApplicationSubmitted.add(objOpportunity);
		}
		
		if(!lstOpportunityToUpdateToApplicationSubmitted.isEmpty())
			SL_ErrorLogger.invokeErrorLogger(database.update(lstOpportunityToUpdateToApplicationSubmitted,false) , lstOpportunityToUpdateToApplicationSubmitted);
			
		///Create data for Opportunity Stage
		for(Opportunity objOpportunity:[SELECT Id,StageName,(SELECT Id,Status__c FROM Contact_Roles__r)
		                                FROM Opportunity
		                                WHERE Id IN:setOpportunityId])
		{
			String strStageName = objOpportunity.StageName;
		
			///Make Stage on opp as 'Application and Documents Are Submitted' when all related contact role have status 'Documents Uploaded'
			for(Contact_Role__c objContactRole:objOpportunity.Contact_Roles__r)
			{
				if(objContactRole.Status__c == 'Documents Uploaded')
				{
					objOpportunity.StageName ='Application and Documents Are Submitted';
				}
				else
				{
					objOpportunity.StageName = strStageName;
					break;
				}	
			}
			
			lstOpportunityToUpdateToDocumentsSubmitted.add(objOpportunity);
		}
		
		if(!lstOpportunityToUpdateToDocumentsSubmitted.isEmpty())
		{
		   /* SL_ErrorLogger.invokeErrorLogger( , lstOpportunityToUpdateToDocumentsSubmitted);*/
		   try{
		    database.update(lstOpportunityToUpdateToDocumentsSubmitted,true);    
		   }
		   catch(Exception ex)
		   {
		   	if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
		       insert new Error_Log__c(Debug_Log__c = 'Error:' + ex.getMessage() + ' Stack Trace:' + ex.getStackTraceString() + ' Line No:' + ex.getLineNumber());
		   }
		}
			
	}

	/*
    	* MethodName   : updateOpportunityOnApplicationApproval(Added for THOR-69)
        * param        : List<Contact_Role__c> lstContactRoleApproved ,Set<Id> setOpportunityId
        * Description  : Method to update OpportunityStatus to Application Approved if All Contact Role Status are set to Application Approved 
    */

	private void updateOpportunityOnApplicationApproval(List<Contact_Role__c> lstContactRoleApproved , set<Id> setOpportunityId)
	{
	    system.debug('Contact Role Trigger Invoked');
	    
		Set<Id> setOpportunityApproved = new Set<Id>();
		Set<Id> setOpportunityNotApproved = new Set<Id>();
		List<Opportunity> lstOpportunityToUpdate = new List<Opportunity>();
		Map<Id , Contact_Role__c> mapIdToContactRoles = new Map<Id , Contact_Role__c>();
		Set<String> setOpportunityStageNameToIgnore = new Set<String>{'Lease Signed by Thor' , 'Lease Signed by Tenants' , 
		                                                              'Lease Sent' , 'Closed Lost' , 'Application Rejected'};

		mapIdToContactRoles.putAll(lstContactRoleApproved);
		for(Contact_Role__c objContactRole : [Select Id,Opportunity__c 
											  from Contact_Role__c 
											  where Opportunity__c IN :setOpportunityId 
											  AND ((Status__c != 'Application Approved' 
											  AND Id Not In:mapIdToContactRoles.keySet())
											  OR (Opportunity__r.StageName IN :setOpportunityStageNameToIgnore))])
		{
			setOpportunityNotApproved.add(objContactRole.Opportunity__c);
		}

		for(Contact_Role__c objContactRole : lstContactRoleApproved)
		{
			if(!setOpportunityNotApproved.contains(objContactRole.Opportunity__c))
			{
				if(objContactRole.Status__c == 'Application Approved')
				{
					setOpportunityApproved.add(objContactRole.Opportunity__c);
				}
				else
				{
					if(setOpportunityApproved.contains(objContactRole.Opportunity__c))
					{
						setOpportunityApproved.remove(objContactRole.Opportunity__c);
						setOpportunityNotApproved.add(objContactRole.Opportunity__c);
					}
				}
			}
		}

		for(Id OpportunityId : setOpportunityApproved)
		{
			lstOpportunityToUpdate.add(new Opportunity(Id=OpportunityId , StageName='Application Approved'));
		}
        
        try{
		if(!lstOpportunityToUpdate.isEmpty())
			update lstOpportunityToUpdate;
        } 
        catch(Exception ex)
        {
        	if(!Error_Logging__c.getall().values().isEmpty() && Error_Logging__c.getall().values()[0].isErrorLog__c)
            	insert new Error_Log__c(Debug_Log__c = 'Error:' + ex.getMessage() + '\n Stack Trace:' + ex.getStackTraceString() + '\n Line No:' + ex.getLineNumber());
        }
	}
	
}