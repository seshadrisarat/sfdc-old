/**
* \arg ClassName      : SL_AttachmentHandler
* \arg JIRATicket     : GA-26
* \arg CreatedOn      : 12/MAY/2015
* \arg LastModifiedOn : -
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : -
* \arg Description    : This trigger handler is used to update the Contact record with most recent attachment record.
*/
public with sharing class SL_AttachmentHandler 
{
	static String strUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=';
	
	/* Start - Constructor */
	public SL_AttachmentHandler()
	{
		//Do Nothing
	}
	/* End - Constructor */
	
	/*
        * MethodName   : onAfterInsert
        * Param        : list of inserted attachment records
        * Description  : This method updates the Contact record with recently inserted attachment record
    */
	public static void onAfterInsert(List<Attachment> lstAttachment)
	{
		updateContact(lstAttachment);
	}
	
	/*
        * MethodName   : onAfterDelete
        * Param        : list of deleted attachment records
        * Description  : This method updates the Contact record with next most recent attachment record.
    */
	public static void onAfterDelete(List<Attachment> lstAttachment)
	{
		updateContact(lstAttachment);
	}
	
	/*
        * MethodName   : updateContact
        * Param        : list of deleted attachment records
        * Description  : This method updates the Contact record with most recent attachment record
    */
	private static void updateContact(List<Attachment> lstAttachment)
	{
		Map<Id,Contact> mapIdToContact = new Map<Id,Contact>();
		Set<Id> setContactId = new Set<Id>();
		
		for(Attachment objAttachment : lstAttachment)
		{
			if(objAttachment.ParentId.getSobjectType() == Contact.sobjectType)
			{
				if(!Trigger.isInsert)
					setContactId.add(objAttachment.ParentId);
				else
					mapIdToContact.put(objAttachment.ParentId, new Contact(Id = objAttachment.ParentId, Most_Recent_Resume__c = strUrl+objAttachment.Id));
			}
		}
		
		if(!setContactId.isEmpty())
		{
			for(Attachment objAttachment : [SELECT Id, ParentId FROM Attachment WHERE ParentId IN : setContactId ORDER BY LastModifiedDate])
				mapIdToContact.put(objAttachment.ParentId, new Contact(Id = objAttachment.ParentId, Most_Recent_Resume__c = strUrl+objAttachment.Id));
			
			for(Id contactId : setContactId)
			{
				if(!mapIdToContact.containskey(contactId))
					mapIdToContact.put(contactId, new Contact(Id = contactId, Most_Recent_Resume__c = NULL));
			}
		}
		
		if(!mapIdToContact.isEmpty())
			update mapIdToContact.values();		
	}
}