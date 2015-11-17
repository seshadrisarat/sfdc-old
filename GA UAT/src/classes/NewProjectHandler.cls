/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class NewProjectHandler extends GAPSMailHandlerBase implements Messaging.InboundEmailHandler 
{
	
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) 
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		
		String strSubjectLine=(email.subject.trim().equals('')?'[no title]':email.subject);
		String strEmailBody=(email.htmlBody != null ?email.htmlBody:email.plainTextBody);
		
		strEmailBody=((strEmailBody.length()>32000)?strEmailBody.substring(0,31999):strEmailBody);
		strSubjectLine=((strSubjectLine.length()>75)?strSubjectLine.substring(0,74):strSubjectLine);

		try
		{
			User u=findUser(email.fromAddress);
			Contact c=findContact(email.fromAddress);
			
			Task__c t=new Task__c(Title__c=strSubjectLine,Status__c='New', Description__c=strEmailBody,Requestor__c=c.Id, OwnerID=u.Id, Stakeholder_Team__c=u.Group_Name__c );
			insert t;
			
			saveAttachments(email, t.Id);
			
			//CWD-- the following 2 lines are now handled via the FollowTeamTask trigger
			//EntitySubscription follow=new EntitySubscription(parentId=t.id,subscriberid=u.Id);
			//insert follow;
			
			
		}
        catch(GAPSException eG)
        {
        	result.success=false;
        	result.message='An error occured: '+eG.getMessage()+'\n\n\n'+getHelpText(true);
        }
        catch(Exception e)
        {
        	result.success=false;	
        	result.message='An error occured: '+e.getMessage()+'\n\n\n'+getHelpText(true);
        }

        return result;
    } 
}