/**
* \arg ClassName        : SL_CallReportCompanyHandler
* \arg JIRATicket     	: PWP-9,PWP-19,PWP-88
* \arg CreatedOn      	: 2/MAR/2015
* \arg LastModifiedOn 	: 8/AUG/2015
* \arg CreatededBy    	: Pankaj Ganwani
* \arg ModifiedBy     	: Lodhi
* \arg Description    	: This class is used to hold the functions for creating the sharing records corresponding to the call report.
*/
public with sharing class SL_SharingController 
{
	/**
	    @MethodName : createSharingRecords
	    @Param 		: list of call report company record corresponding to which we have to insert call report share records
	    @Description: This method will be called from both call report handler and call report company handler for creating the sharing records corresponding to the call report records.
    **/
	public static void createSharingRecords(List<Call_Report_Company__c> lstCallReportCompany)
	{
		List<Call_Report__Share> lstCallReportShare = new List<Call_Report__Share>();// list to hold sharing records corresponding to the call reports
		Map<Id, Set<Id>> mapCompanyIdToSetOfCallReport = new Map<Id, Set<Id>>();
		
		for(Call_Report_Company__c objCRC: lstCallReportCompany)
		{
			if(!mapCompanyIdToSetOfCallReport.containskey(objCRC.Relevant_Company__c))
				mapCompanyIdToSetOfCallReport.put(objCRC.Relevant_Company__c, new Set<Id>{objCRC.Call_Report__c});
			else
				mapCompanyIdToSetOfCallReport.get(objCRC.Relevant_Company__c).add(objCRC.Call_Report__c);
		}
		
		//Sharing call report with the AccountTeamMembers when a call report is inserted or updated.
		for(AccountTeamMember objAccTeams : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE AccountId IN : mapCompanyIdToSetOfCallReport.keyset()])
        {
            for(Id callReportId : mapCompanyIdToSetOfCallReport.get(objAccTeams.AccountId))
			{
				lstCallReportShare.add(new Call_Report__Share(ParentId = callReportId, UserOrGroupId = objAccTeams.UserId, AccessLevel = 'Read'));
			}
        }
        
		//Commentted by lodhi to handle the call report sharing functionality using account team member instead of Coverage_Team_Members__c.
		/*for(Coverage_Team_Members__c objCTM : [SELECT Company__c, PWP_Employee__c FROM Coverage_Team_Members__c WHERE Company__c IN: mapCompanyIdToSetOfCallReport.keyset()])
		{
			for(Id callReportId : mapCompanyIdToSetOfCallReport.get(objCTM.Company__c))
			{
				lstCallReportShare.add(new Call_Report__Share(ParentId = callReportId, UserOrGroupId = objCTM.PWP_Employee__c, AccessLevel = 'Read'));
			}
		}*/
		
		if(!lstCallReportShare.isEmpty())
			Database.insert(lstCallReportShare,false);
	}
}