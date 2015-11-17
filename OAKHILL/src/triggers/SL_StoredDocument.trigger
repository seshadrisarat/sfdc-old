/**
* \arg ClassName      : SL_StoredDocument
* \arg JIRATicket     : OAKHILL-6
* \arg CreatedOn      : 6/NOV/2014
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger is used to update the Transaction Document record corresponding to latest stored document link.
*/
trigger SL_StoredDocument on LStore__Stored_Document__c (after insert) 
{
	SL_StoredDocumentHandler objStoredDocument = new SL_StoredDocumentHandler();//instantiate the handler class
	//checking if event id after insert
	if(trigger.isAfter && trigger.isInsert)
	{
		objStoredDocument.onAfterInsert(Trigger.new);//calling method for updating related transaction document record
	}
}