/**
* \arg ClassName      : SL_Batch_CreateDocuments
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 31/OCT/2014
* \arg LastModifiedOn : 05/OCT/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This batch process is used to create documents corresponding to Transaction Document records.
*/
global class SL_Batch_CreateDocuments implements Database.Batchable<sObject>,Database.AllowsCallouts
{  
   String sessionId;//Current user session Id
   String ddpId;// current ddp id
   String deliveryOptionId;// delivery option id to corresponding ddp id
   String documentQueueId;//document queue id to correponding ddp id
   List<Sobject> lstTransactionDocument; //list of transaction document records
   
   /* Start - Constructor */
   global SL_Batch_CreateDocuments(List<Sobject> lstTransactionDocument, String sessionId, String ddpId, String deliveryOptionId, String documentQueueId)
   {
      this.sessionId = sessionId;
      this.lstTransactionDocument = lstTransactionDocument;
      this.ddpId = ddpId;
      this.deliveryOptionId = deliveryOptionId;
      this.documentQueueId = documentQueueId;
   }
   /* End - Constructor */
   
   //Start Method
   global Iterable<sobject> start(Database.BatchableContext BC)
   {
      return lstTransactionDocument;
   }
	
	//Execute Method
   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
   		List<Investor_Report_Document__c> lstTransactionDocument = (List<Investor_Report_Document__c>)scope;
        Loop.loopMessage lm = new Loop.loopMessage();
		lm.sessionId = sessionId;
		lm.batchNotification = Loop.loopMessage.Notification.BEGIN_AND_COMPLETE;	
		Boolean isDocumentQueue = String.isNotEmpty(documentQueueId) ? true:false;
		
		//Iterating over transaction document records to create corresponding documents
		for(Investor_Report_Document__c objTranDocument : lstTransactionDocument)
		{
			lm.requests.add(new Loop.loopMessage.loopMessageRequest(objTranDocument.Id,ddpId,new Map<string,string>{'deploy'=>deliveryOptionId}));
			if(isDocumentQueue)
				lm.requests.add(new Loop.loopMessage.loopMessageRequest(objTranDocument.Id,ddpId,new Map<string,string>{'deploy'=>documentQueueId}));
		}
		lm.sendAllRequests();//calling class to send request to loop web service
   }
	
	//Finish Method
   global void finish(Database.BatchableContext BC)
   {
   		//Do Nothing
   }
}