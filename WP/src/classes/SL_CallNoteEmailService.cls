/**
* \arg ClassName      : SL_CallNoteEmailService
* \arg JIRATicket     : WP-137
* \arg CreatedOn      : 4/MAY/2015
* \arg LastModifiedOn : 6/MAY/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This email service is used to update the event description with the call notes which comes through inbound email.
*/
global class SL_CallNoteEmailService implements Messaging.Inboundemailhandler 
{
	/* Start - Variables */
	private static String HTML_TAG_PATTERN = '<.*?>';
	private static String NOTIFICATION_EMAIL = 'A Description was already entered for this meeting and your response has been appended. Please check to make sure the Description is accurate';
	/* End - Variables */
	
	/**
	    @MethodName : handleInboundEmail
	    @Param 		: inboundemail object and inboundenvelope object
	    @Description: This method is used to update the event record whose id is mentioned in email subject, with email body.
    **/
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.Inboundemail email, Messaging.Inboundenvelope envelope)
	{
		String plainTextBody = email.plainTextBody;
		String strSubject = email.subject;
		Id eventId = Id.valueOf(strSubject.substring(strSubject.lastIndexOf('-')).subStringBetween('(',')').trim());
		List<Event> lstEvent = [SELECT Description FROM Event WHERE Id =:eventId LIMIT 1];
		if(!lstEvent.isEmpty())
		{
			Event objEvent = lstEvent[0];
			String strHTMLBody = email.htmlBody;
			if(String.isNotEmpty(strHTMLBody))
			{
				String strBody = '';
				if(strHTMLBody.contains('<div dir="ltr">') && strHTMLBody.contains('<div class="gmail_extra">'))
				{
					strBody = strHTMLBody.subStringBetween('<div dir="ltr">','<div class="gmail_extra">').replaceAll('<br/>', '\n').replaceAll('<br>', '\n').replaceAll('<div>','').replaceAll('</div>','\n');
					// compile the pattern     
					Pattern patternTemp = pattern.compile(HTML_TAG_PATTERN);						
					// get your matcher instance
					Matcher matcher = patternTemp.matcher(strBody);						
					//remove the tags     
					strBody = matcher.replaceAll('');
				}
				else 
					strBody = plainTextBody;
				
				if(String.isEmpty(objEvent.Description))
				{
					objEvent.Description = strBody;
					update objEvent;
				}
				else
				{
					objEvent.Description+='\n\n'+strBody;
					update objEvent;
					
					Messaging.InboundEmailResult notificationEmail = new Messaging.Inboundemailresult();
					notificationEmail.message = String.format('{0}: {1}/{2}', new List<String>{NOTIFICATION_EMAIL, Url.getSalesforceBaseUrl().toExternalForm().replace('http','https'),eventId});
					notificationEmail.success = true;
					return notificationEmail;
				}
			}
		}	
		return new Messaging.InboundEmailResult();
	}
}