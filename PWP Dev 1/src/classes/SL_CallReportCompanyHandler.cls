/**
* \arg TriggerName      : SL_CallReportCompanyHandler
* \arg JIRATicket     	: PWP-9, PWP-88
* \arg CreatedOn      	: 5/DEC/2014
* \arg LastModifiedOn 	: 8/AUG/2015
* \arg CreatededBy    	: Pankaj Ganwani
* \arg ModifiedBy     	: Lodhi
* \arg Description    	: This class serves as SL_CallReportCompany trigger handler and is used to create call report share records corresponding to those call report company records for coverage team members.
*/
public with sharing class SL_CallReportCompanyHandler 
{
	/**
	    @MethodName : onAfterInsert
	    @Param 		: list of inserted call report company records 
	    @Description: This method called on after insert of call report company record.
    **/
	public void onAfterInsert(List<Call_Report_Company__c> lstCallReportCompany)
	{
		createSharingRecords(lstCallReportCompany);
	}
	
	/**
	    @MethodName : onAfterUpdate
	    @Param 		: list of updated call report company records 
	    @Description: This method called on after insert of call report company record.
    **/
	public void onAfterUpdate(Map<Id,Call_Report_Company__c> mapNewIdToCallReportCompany, Map<Id,Call_Report_Company__c> mapOldIdToCallReportCompany)
	{
		List<Call_Report_Company__c> lstCRCForInsert = new List<Call_Report_Company__c>();
		List<Call_Report_Company__c> lstCRCForDelete = new List<Call_Report_Company__c>();
		
		for(Call_Report_Company__c objCRC : mapNewIdToCallReportCompany.values())
		{
			Call_Report_Company__c objOldCRC = mapOldIdToCallReportCompany.get(objCRC.Id);
			if(objCRC.Relevant_Company__c!=objOldCRC.Relevant_Company__c)
			{
				lstCRCForInsert.add(objCRC);
				lstCRCForDelete.add(objOldCRC);
			}
		}
		
		deleteSharingRecords(lstCRCForDelete);
		createSharingRecords(lstCRCForInsert);
	}
	
	/**
	    @MethodName : onAfterDelete
	    @Param 		: list of deleted call report company records 
	    @Description: This method called on after delete of call report company record.
    **/
	public void onAfterDelete(List<Call_Report_Company__c> lstCallReportCompany)
	{
		deleteSharingRecords(lstCallReportCompany);
	}
	
	/**
	    @MethodName : onAfterUndelete
	    @Param 		: list of undeleted call report company records 
	    @Description: This method called on after undelete of call report company record.
    **/
	public void onAfterUndelete(List<Call_Report_Company__c> lstCallReportCompany)
	{
		createSharingRecords(lstCallReportCompany);
	}
	
	/**
	    @MethodName : createSharingRecords
	    @Param 		: list of call report company record corresponding to which we have to insert call report share records
	    @Description: This method called on after insert, on after update and on after undelete events of call report company records.
    **/
	private void createSharingRecords(List<Call_Report_Company__c> lstCallReportCompany)
	{
		SL_SharingController.createSharingRecords(lstCallReportCompany);//calling function to create sharing records corresponding to call reports.
	}
	
	/**
	    @MethodName : deleteSharingRecords
	    @Param 		: list of call report company record corresponding to which we have to delete call report share records 
	    @Description: This method called on after update and on after delete events of call report company object.
    **/
	private void deleteSharingRecords(List<Call_Report_Company__c> lstCallReportCompany)
	{
		Set<Id> setAccountId = new Set<Id>();
		Set<Id> setCallReportId = new Set<Id>();
		Set<Id> setPWPEmployeeId = new Set<Id>();
		Set<String> setCallReportIdToUserId = new Set<String>();
		List<Call_Report__Share> lstCRS = new List<Call_Report__Share>();
		
		for(Call_Report_Company__c objCRC : lstCallReportCompany)
		{
			setAccountId.add(objCRC.Relevant_Company__c);
			setCallReportId.add(objCRC.Call_Report__c);
		}
		
		//Handling call report sharing functionality based on AccountTeamMember instead of Coverage_Team_Members__c
		for(AccountTeamMember objAccTeams : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE AccountId IN : setAccountId])
		{
			setPWPEmployeeId.add(objAccTeams.UserId);
		}
		
		for(Account objAccount : [SELECT Id, 
		                                 (SELECT Call_Report__c 
		                                    From Meeting_Companies__r 
		                                   WHERE Call_Report__c IN : setCallReportId),
		                                 (SELECT Id, UserId, AccountId 
		                                    FROM AccountTeamMembers 
		                                   WHERE UserId IN : setPWPEmployeeId) 
		                            FROM Account 
		                           WHERE Id NOT IN:setAccountId])
		{
			if(!objAccount.AccountTeamMembers.isEmpty() && !objAccount.Meeting_Companies__r.isEmpty())
			{
				for(AccountTeamMember objAccTeam : objAccount.AccountTeamMembers)
				{
					for(Call_Report_Company__c objCRC : objAccount.Meeting_Companies__r)
					{
						setCallReportIdToUserId.add(objCRC.Call_Report__c+'_'+ objAccTeam.UserId);
					}
				}
			}
		}
		
		/*for(Coverage_Team_Members__c objCTM : [SELECT PWP_Employee__c FROM Coverage_Team_Members__c WHERE Company__c IN : setAccountId])
		{
			setPWPEmployeeId.add(objCTM.PWP_Employee__c);
		}
		
		for(Account objAccount : [SELECT Id, (SELECT Call_Report__c From Meeting_Companies__r WHERE Call_Report__c IN : setCallReportId),(SELECT PWP_Employee__c FROM Coverage_Team_Members__r WHERE PWP_Employee__c IN : setPWPEmployeeId) FROM Account WHERE Id NOT IN:setAccountId])
		{
			if(!objAccount.Coverage_Team_Members__r.isEmpty() && !objAccount.Meeting_Companies__r.isEmpty())
			{
				for(Coverage_Team_Members__c objCTM : objAccount.Coverage_Team_Members__r)
				{
					for(Call_Report_Company__c objCRC : objAccount.Meeting_Companies__r)
					{
						setCallReportIdToUserId.add(objCRC.Call_Report__c+'_'+objCTM.PWP_Employee__c);
					}
				}
			}
		}*/
		
		for(Call_Report__Share objCRS:[SELECT ParentId, UserOrGroupId FROM Call_Report__Share WHERE ParentId IN : setCallReportId AND UserOrGroupId IN : setPWPEmployeeId AND RowCause =:'Manual'])
		{
			if(!setCallReportIdToUserId.contains(objCRS.ParentId+'_'+objCRS.UserOrGroupId))
				lstCRS.add(objCRS);
		}
		
		if(!lstCRS.isEmpty())
			Database.delete(lstCRS,false);
	}
}