/**
* \arg ClassName      : SL_WS_CreateDocuments
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 31/OCT/2014
* \arg LastModifiedOn : 05/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class is used to create documents on click of detail page button on report generator page.
*/
global class SL_WS_CreateDocuments 
{
	 static final String REJECTED_STATUS = 'Rejected';
	 static final String CAPITAL_CALL_STATEMENT = 'Capital Call Statement';
	 
	 /** 
        * @Name         : createDocuments
        * @parameter    : report generator Id, fund id, generator type and run date
        * @Description  : This method will be called on click of detail page button of report generator page
    */ 
	webservice static String createDocuments(String strReportGeneratorId, String FundId, String reportGeneratorType, String runDate)
	{
		SL_LoopParameters__c objLoopParameters = SL_LoopParameters__c.getInstance(reportGeneratorType);
     	Date dtRunDate = Date.parse(runDate);
     	if(objLoopParameters == null)
     		return 'Please set up the configuration for '+reportGeneratorType;
		
     	List<Investor_Report_Document__c> lstTransactionDocument = new List<Investor_Report_Document__c>();//list to store transaction document records
     	List<Investor_Report_Document__c> lstRejectedTransactionDocument = new List<Investor_Report_Document__c>();//list to store rejected transaction document records
     	List<Document_Recipient__c> lstDocumentRecipient = new List<Document_Recipient__c>();// list to hold document recipient records that needs to be inserted
     	List<Transaction__c> lstTransaction = new List<Transaction__c>();// list to hold transaction records that needs to updated.
     	
     	Set<Id> setRelAccForExistingTD = new Set<Id>();//This set contains those related account ids, the transaction documents records exist
     	Map<Id,Transaction__c> mapRelAccIdToTransaction = new Map<Id,Transaction__c>();// map to hold value of transaction id corresponding to related account id
     	Map<Id, List<Investor_Contact__c>> mapRelAccIdTolstOfInvestorContact = new Map<Id, List<Investor_Contact__c>>();//map to hold investor contacts corresponding to related accounts     	
     	Boolean isCapitalCallStatement = reportGeneratorType == CAPITAL_CALL_STATEMENT ? true : false;
     	
     	//Iterating over transaction document object to filter the rejected records and created records for contacts
     	for(Investor_Report_Document__c objTransactionDocument : [SELECT Id, Status__c, Related_Account__c, Transaction__c ,Transaction__r.Related_Account__c FROM Investor_Report_Document__c WHERE Report_Generator__c=:strReportGeneratorId])
     	{
     		//Checking if status is rejected
     		if(objTransactionDocument.Status__c == REJECTED_STATUS)
     			lstRejectedTransactionDocument.add(objTransactionDocument);
     			
     		setRelAccForExistingTD.add(objTransactionDocument.Related_Account__c);     		
     	}
     	
     	//if report generator type is capital call statement
     	if(!isCapitalCallStatement)
     	{			
			//Iterating over list of transaction records to fill the map
			for(Transaction__c objTransaction : [SELECT Id, Related_Account__c, Report_Generator__c FROM Transaction__c WHERE RecordType.DeveloperName =: objLoopParameters.Record_Type_Developer_Name__c AND Related_Account__r.Fund__c=:FundId AND Date_Of_Notice__c =:dtRunDate])
	        {
	        	mapRelAccIdToTransaction.put(objTransaction.Related_Account__c, objTransaction);
	        }
     	}
     	else
     	{
     		//if report generator type is capital call statement then we will fetch related accounts corresponding to current year month end balance
     		for(Month_End_Balance__c objMonthEndBalance : [SELECT Related_Account__c FROM Month_End_Balance__c WHERE Related_Account__r.Fund__c =:FundId AND CALENDAR_MONTH(As_of_Date__c) <=:dtRunDate.month() AND CALENDAR_YEAR(As_of_Date__c) =:dtRunDate.year()])
     		{
     			mapRelAccIdToTransaction.put(objMonthEndBalance.Related_Account__c, null);
     		}
     	}
     	//set to hold related account ids so that we can refer it in dynamic soql.
     	Set<Id> setRelatedAccountId = mapRelAccIdToTransaction.keyset();
        
        //Iterating over Related account record to create transaction document record and their recipient records
        for(Related_Account__c objRA : Database.query(String.format('{0}{1}{2}{3}', new String[]{'SELECT ID, (SELECT Contact__c, Contact__r.Name FROM Investor_Contacts__r WHERE  ', objLoopParameters.Checkbox_API_Name__c,' = true) ',' FROM Related_Account__c WHERE Id IN : setRelatedAccountId'})))
        {
        	if(!setRelAccForExistingTD.contains(objRA.Id))
        	{
	        	if(mapRelAccIdToTransaction.containskey(objRA.Id) && mapRelAccIdToTransaction.get(objRA.Id)!=null)
	        	{
		        	lstTransactionDocument.add(new Investor_Report_Document__c(Report_Generator__c = strReportGeneratorId, Related_Account__c = objRA.Id, Status__c='Unsent', Transaction__c = mapRelAccIdToTransaction.containskey(objRA.Id) && mapRelAccIdToTransaction.get(objRA.Id)!=null ? mapRelAccIdToTransaction.get(objRA.Id).Id : null));
		        	lstTransaction.add(new Transaction__c(Id = mapRelAccIdToTransaction.get(objRA.Id).Id, Report_Generator__c = strReportGeneratorId));
	        	}
	        	else
	        		lstTransactionDocument.add(new Investor_Report_Document__c(Report_Generator__c = strReportGeneratorId, Related_Account__c = objRA.Id, Status__c='Unsent'));
	        	if(!objRA.Investor_Contacts__r.isEmpty())
	        	{        		
	        		mapRelAccIdTolstOfInvestorContact.put(objRA.Id, objRA.Investor_Contacts__r);
	        	}
        	}
        }
        
        //Checking if list is not empty
        if(!lstTransactionDocument.isEmpty())
        {
	        insert lstTransactionDocument;//performing DML
	        if(!lstTransaction.isEmpty())
	        	update lstTransaction;//updating the related transaction records with current report generator id
	        List<Investor_Report_Document__c> lstTransactionDocumentToUpdate = new List<Investor_Report_Document__c>();//This list is used to hold those transaction document records which needs to be updated.
	        //Iterating over inserted transaction document records to create the corresponding document recipient records
	        for(Investor_Report_Document__c objTransactionDocument : lstTransactionDocument)
	        {
	        	if(mapRelAccIdTolstOfInvestorContact.containskey(objTransactionDocument.Related_Account__c))
	        	{
	        		String strAddtionalRecipients = '';//this variable is used to hold the value of additional recipients in comma separated fashion
	        		for(Investor_Contact__c objInvestorContact : mapRelAccIdTolstOfInvestorContact.get(objTransactionDocument.Related_Account__c))
	        		{
	        			strAddtionalRecipients = String.isBlank(strAddtionalRecipients) ? objInvestorContact.Contact__r.Name : String.join(new List<String>{strAddtionalRecipients, objInvestorContact.Contact__r.Name},', ');
	        			lstDocumentRecipient.add(new Document_Recipient__c(Contact__c = objInvestorContact.Contact__c, Investor_Report_Document__c = objTransactionDocument.Id));
	        		}
	        		objTransactionDocument.Additional_Recipients__c = strAddtionalRecipients;
	        		lstTransactionDocumentToUpdate.add(objTransactionDocument);
	        	}
	        }
	        //null check
	        if(!lstDocumentRecipient.isEmpty())
	        	insert lstDocumentRecipient;
	        //null check
	        if(!lstTransactionDocumentToUpdate.isEmpty())
	        	update lstTransactionDocumentToUpdate;
        }	
	        
         //Checking for emptiness of the list
    	if(!lstRejectedTransactionDocument.isEmpty())
    		lstTransactionDocument.addAll(lstRejectedTransactionDocument);
        
        //checking if list is not empty		
		if(!lstTransactionDocument.isEmpty())
		{
			//executing the batch process on click of button
			Database.executeBatch(new SL_Batch_CreateDocuments(lstTransactionDocument,Userinfo.getSessionId(), objLoopParameters.DDPId__c, objLoopParameters.DeliveryOptionId__c, objLoopParameters.Document_Queue_Delivery_Option_Id__c),10);
			update new Report_Generator__c(Id = strReportGeneratorId, Status__c = 'Documents In Progress');//updating the report generator object
			return Label.SL_ReportGeneratorJobProcessing;
		}
		else
			return Label.SL_NoTransactionFound;
	}
}