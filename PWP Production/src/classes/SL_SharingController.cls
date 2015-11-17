/**
* \arg ClassName        : SL_CallReportCompanyHandler
* \arg JIRATicket     	: PWP-9,PWP-19
* \arg CreatedOn      	: 2/MAR/2015
* \arg LastModifiedOn 	: -
* \arg CreatededBy    	: Pankaj Ganwani
* \arg ModifiedBy     	: -
* \arg Description    	: This class is used to hold the functions for creating the sharing records corresponding to the call report.
*/
public with sharing class SL_SharingController 
{
	/* Start - Constructor */
	public SL_SharingController()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
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
		
		for(Coverage_Team_Members__c objCTM : [SELECT Company__c, PWP_Employee__c FROM Coverage_Team_Members__c WHERE Company__c IN: mapCompanyIdToSetOfCallReport.keyset()])
		{
			for(Id callReportId : mapCompanyIdToSetOfCallReport.get(objCTM.Company__c))
			{
				lstCallReportShare.add(new Call_Report__Share(ParentId = callReportId, UserOrGroupId = objCTM.PWP_Employee__c, AccessLevel = 'Read'));
			}
		}
		
		if(!lstCallReportShare.isEmpty())
			Database.insert(lstCallReportShare,false);
	}
}