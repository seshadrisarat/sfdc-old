/**
* \arg ClassName      : SL_StoredDocumentHandler
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 6/NOV/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This class serves as trigger handler for stored document trigger to update the related transaction document record with document link.
*/
public without sharing class SL_StoredDocumentHandler 
{
	/* Start - Constructor */
	public SL_StoredDocumentHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*!
      *  @MethodName: onAfterInsert
      *  @param None: New list of stored document records
      *  @Description: This method will be called on after insert event of stored document record
    */
	public void onAfterInsert(List<LStore__Stored_Document__c> lstStoredDocument)
	{
		Set<Id> setRelatedId = new Set<Id>();//set to hold the values of related object ids
		Map<Id,Investor_Report_Document__c> mapIdToTransactionDocument = new Map<Id,Investor_Report_Document__c>(); //map to hold the transaction document record id and its corresponding latest updated transaction document record 
		Map<Id, Report_Generator__c> mapIdToReportGenerator = new Map<Id, Report_Generator__c>(); //map to hold the report generator id to its corresponding report generator object
		//Iterating over stored document record to collect Id of related object
		for(LStore__Stored_Document__c obj : lstStoredDocument)
		{
			setRelatedId.add(obj.LStore__Related_Object_Id__c);
		}
		
		//Fetching the stored document records based in ascending order
   		for(LStore__Stored_Document__c objStoredDocument : [SELECT Id, LStore__Related_Object_Id__c FROM LStore__Stored_Document__c WHERE LStore__Related_Object_Id__c IN : setRelatedId ORDER BY CreatedDate])
		{
			//checking if related object record belongs to transaction document 
			if(Id.valueOf(objStoredDocument.LStore__Related_Object_Id__c).getSobjectType() == Investor_Report_Document__c.getSobjectType())
			{
				mapIdToTransactionDocument.put(objStoredDocument.LStore__Related_Object_Id__c,new Investor_Report_Document__c(Id = objStoredDocument.LStore__Related_Object_Id__c, Status__c = 'Unsent' , Document_Link__c = '/apex/lstore__storedDocViewRestore?id='+objStoredDocument.Id+'&action=download&contentType=redirect&loopurl=&looppackage=&instance=&version='));
			}
		}
		if(!mapIdToTransactionDocument.isEmpty())
		{
			update mapIdToTransactionDocument.values();//updating the transaction document records
			
			//iterating over transaction document records to update its corresponding report generator status
			for(Investor_Report_Document__c objTransasctionDocument : [SELECT Report_Generator__c FROM Investor_Report_Document__c WHERE Id IN : mapIdToTransactionDocument.keySet()])
			{
				mapIdToReportGenerator.put(objTransasctionDocument.Report_Generator__c, new Report_Generator__c(Id = objTransasctionDocument.Report_Generator__c, Status__c='Report Generated'));
			}
	
			if(!mapIdToReportGenerator.isEmpty())
				update mapIdToReportGenerator.values();//updating the report generator records.
		}
	}
}