/**
* \arg ClassName      : SL_Batch_EmailDocument
* \arg JIRATicket     : OAKHILL-20
* \arg CreatedOn      : 17/NOV/2014
* \arg LastModifiedOn : 5/DEC/2014
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This batch process is used to send documents to the contacts correponding to the transaction document records.
*/
global class SL_Batch_EmailDocument implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful
{  
   String sessionId;//Current user session Id
   String ddpId;// current ddp id
   String deliveryOptionId;// delivery option id to corresponding ddp id
   List<Sobject> lstTransactionDocument; //list of transaction document records
   List<Sobject> lstSobject;
   
   /* Start - Constructor */
   global SL_Batch_EmailDocument(List<Sobject> lstTransactionDocument, String sessionId, String ddpId, String deliveryOptionId)
   {
      this.sessionId = sessionId;
      this.lstTransactionDocument = lstTransactionDocument;
      this.ddpId = ddpId;
      this.deliveryOptionId = deliveryOptionId;
      this.lstSobject = new List<Sobject>();
   }
   /* End - Constructor */
   
   //wrapper class which is used to keep attachment ids and transaction document ids corresponding to contact id
   private class ContactWrapper
   {
   		String transactionDocumentId;//this variable is used to hold transaction document id
   		String attachmentIds;// this variable is used to hold attachment Id
   		ContactWrapper(String transactionDocumentId,String attachmentIds)
   		{
   			this.transactionDocumentId = transactionDocumentId;
   			this.attachmentIds = attachmentIds;
   		}
   }  
   
   //Start Method
   global Iterable<sobject> start(Database.BatchableContext BC)
   {
      return lstTransactionDocument;
   }
	
	//Execute Method
   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
   		Map<Id,Id> mapTransDocIdToDocId = new Map<Id,Id>();// this variable is used to keep recent document id corresponding to the transaction document id
   		List<Investor_Report_Document__c> lstTransactionDocument = (List<Investor_Report_Document__c>)scope;// list of transaction document records
        Map<Id, List<Document_Recipient__c>> mapTransDocIdTolstContactId = new Map<Id, List<Document_Recipient__c>>();// this map is used to hold the transaction document id and its corresponding list of contact ids
        Map<String,ContactWrapper> mapContactIdToContactWrapper = new Map<String,ContactWrapper>();// this map is used to hold the contact id and its corresponding combination of transaction id and attachments
        
        Loop.loopMessage lm = new Loop.loopMessage();
		lm.sessionId = sessionId;
		lm.batchNotification = Loop.loopMessage.Notification.BEGIN_AND_COMPLETE;
		
		//Iterating over transaction document object to get ids in a set
		for(Investor_Report_Document__c objTranDocument : lstTransactionDocument)
		{
			//checking if there are any document recipients exist corresponding to this transaction document record
			if(!objTranDocument.Document_Recipients__r.isEmpty())
			{
				mapTransDocIdTolstContactId.put(objTranDocument.Id, objTranDocument.Document_Recipients__r);
			}
		}		
		
		//Iterating over stored document object to store document corresponding to transaction document
		for(LStore__Stored_Document__c objStoredDocument : [SELECT LStore__Related_Object_Id__c, Id FROM LStore__Stored_Document__c WHERE LStore__Related_Object_Id__c IN:mapTransDocIdTolstContactId.keyset() ORDER BY CreatedDate])
		{
			mapTransDocIdToDocId.put(objStoredDocument.LStore__Related_Object_Id__c, objStoredDocument.Id);
		}
		
		//iterating over map key set
		for(Id transactionDocId : mapTransDocIdToDocId.keyset())
		{
			//checking if map contains key
			if(mapTransDocIdTolstContactId.containskey(transactionDocId))
			{
				lstSobject.add(new Investor_Report_Document__c(Id = transactionDocId, Status__c = 'Sent'));
				for(Document_Recipient__c objDR : mapTransDocIdTolstContactId.get(transactionDocId))
				{
					if(!mapContactIdToContactWrapper.containskey(objDR.Contact__c))
						mapContactIdToContactWrapper.put(objDR.Contact__c, new ContactWrapper(transactionDocId, mapTransDocIdToDocId.get(transactionDocId)));
					else
					{
						ContactWrapper objContactWrapper = mapContactIdToContactWrapper.get(objDR.Contact__c);
						objContactWrapper.attachmentIds = String.join(new List<String>{objContactWrapper.attachmentIds, mapTransDocIdToDocId.get(transactionDocId)},'|');
						mapContactIdToContactWrapper.put(objDR.Contact__c, objContactWrapper);
					}
					lstSobject.add(new Document_Recipient__c(Id = objDR.Id, Status__c = 'Sent'));
				}
			}
		}
		//Iterating over transaction document records to create corresponding documents
		for(String contactId : mapContactIdToContactWrapper.keyset())
		{
			ContactWrapper objContactWrapper = mapContactIdToContactWrapper.get(contactId);
			lm.requests.add(new Loop.loopMessage.loopMessageRequest(objContactWrapper.transactionDocumentId, ddpId, new Map<String,String>{'deploy'=>deliveryOptionId,'attachIds'=>objContactWrapper.attachmentIds,'SFContact'=>contactId}));
		}
		//checking if list is not empty
		if(!lm.requests.isEmpty())
			lm.sendAllRequests();//calling class to send request to loop web service
			
   }
	
	//Finish Method
   global void finish(Database.BatchableContext BC)
   {
   		if(!lstSobject.isEmpty())
   			update lstSobject;
   }
}