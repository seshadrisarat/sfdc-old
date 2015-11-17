/**
* \arg ClassName      : SL_WS_EmailDocument
* \arg JIRATicket     : OAKHILL-20
* \arg CreatedOn      : 13/NOV/2014
* \arg LastModifiedOn : 10/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to Email the documents on click of Email Report button on detail page of report generator record.
*/
global class SL_WS_EmailDocument 
{
	static final String APPROVED_STATUS = 'Approved';//variable to hold approved status
	static final String REJECTED_STATUS = 'Rejected';//variable to hold rejected status
	/** 
        * @Name         : emailDocuments
        * @parameter    : report generator Id and report generator type
        * @Description  : This method will be called to send the documents as email to all Contacts
    */ 
	Webservice static String emailDocuments(String strReportGeneratorId, String reportGeneratorType)
	{		
		return callBatchProcess(strReportGeneratorId,reportGeneratorType);//calling method to kick off batch process
	}
	
	/** 
        * @Name         : callBatchProcess
        * @parameter    : report generator Id and report generator type
        * @Description  : This method will call the batch process which will send email to all investor contacts corresponding to Related accounts of current report generator fund.
    */ 
    private static String callBatchProcess(String strReportGeneratorId, String reportGeneratorType)
    {
    	SL_LoopParameterForEmail__c objLoopParameterForEmail = SL_LoopParameterForEmail__c.getInstance(reportGeneratorType);
		//checking if custom setting record is created or not
		if(objLoopParameterForEmail == null)
     		return 'Please set up the configuration for '+reportGeneratorType;
		
		//fetching all approved transaction document records corresponding to current report generator
		List<Investor_Report_Document__c> lstTransactionDocument = [SELECT Id,(SELECT Id, Contact__c FROM Document_Recipients__r) FROM Investor_Report_Document__c WHERE Report_Generator__c=:strReportGeneratorId AND Status__c =:APPROVED_STATUS];
		
		//checking if list is not empty
		if(!lstTransactionDocument.isEmpty())
		{
			Database.executeBatch(new SL_Batch_EmailDocument(lstTransactionDocument,Userinfo.getSessionId(), objLoopParameterForEmail.DDPId__c, objLoopParameterForEmail.Delivery_Option_Id__c),2000);
			update new Report_Generator__c(Id = strReportGeneratorId, 
										   Status__c = [SELECT COUNT() FROM Investor_Report_Document__c WHERE Report_Generator__c=:strReportGeneratorId AND Status__c=:REJECTED_STATUS] > 0 ? 'Emailed except Rejected' : [SELECT COUNT() FROM Investor_Report_Document__c WHERE Report_Generator__c=:strReportGeneratorId]!=lstTransactionDocument.size() ?  'Partially Emailed' : 'Fully Emailed');//updating the report generator object with emailed status
			return Label.SL_ReportGeneratorJobProcessing;
		}
		else
			return Label.SL_NoTransactionFound;
    }
}