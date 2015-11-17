/**
* \arg ClassName      : AccountTickerAttachment
* \arg JIRATicket     : TT-217
* \arg CreatedOn      : 9/JUNE/2015
* \arg LastModifiedOn : 25/JUNE/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as the inbound email handler which is intended for creating Attachment records related to Account when an email is sent with ticker symbol as subject.
*/
global class AccountTickerAttachment implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
        return createAttachments(email,env);
    }
    
    private Messaging.InboundEmailResult createAttachments(Messaging.inboundEmail email,Messaging.InboundEnvelope env)
    {
    	List<Attachment> lstAttachment = new List<Attachment>();
        List<Account> lstAccount = [SELECT Id FROM Account WHERE Ticker__c =: email.Subject.trim() LIMIT 1];
        
        if(!lstAccount.isEmpty())
        {
        	Account objAccount = lstAccount[0];        	
        	
        	if(email.binaryAttachments!=NULL)
        	{
	        	for(Messaging.Inboundemail.Binaryattachment objbinaryAttachment : email.binaryAttachments)
	        	{
	        		lstAttachment.add(new Attachment(Name = objbinaryAttachment.fileName, ParentId = objAccount.Id, Body = objbinaryAttachment.Body));
	        	}
        	}
        	
        	if(email.textAttachments!=NULL)
        	{
	        	for(Messaging.Inboundemail.Textattachment objTextAttachment : email.textAttachments)
	        	{
	        		lstAttachment.add(new Attachment(Name = objTextAttachment.fileName, ParentId = objAccount.Id, Body = Blob.valueOf(objTextAttachment.Body)));
	        	}
        	}
        	
        	insert lstAttachment;
        }        
        return new Messaging.InboundEmailResult();
    }
}