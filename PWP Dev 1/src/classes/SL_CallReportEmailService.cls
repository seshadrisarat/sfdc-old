/**
* \arg ClassName      : SL_CallReportEmailService
* \arg JIRATicket     : PWP-18
* \arg CreatedOn      : 31/MAR/2015
* \arg LastModifiedOn : 27/MAY/2015
* \arg CreatededBy    : Pankaj Ganwani
* \arg ModifiedBy     : Pankaj Ganwani
* \arg Description    : This class serves as the email service for creating call report corresponding to the received reply of sent emails to owners of activities.
*/
global class SL_CallReportEmailService implements Messaging.Inboundemailhandler
{
	/* Start - Variables */
	private static String HTML_TAG_PATTERN = '<.*?>';
	/* End - Variables */
	
	/**
	    @MethodName : handleInboundEmail
	    @Param 		: inboundemail object and inboundenvelope object
	    @Description: This method is used to create call report and update the corresponding Event with inserted call report id. This method will handle the inbound emails that would be sent to email address specified in email service.
    **/
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.Inboundemail email, Messaging.Inboundenvelope envelope)
	{
		try
		{
		    system.debug('=====25======'+email.fromAddress);
			String plainTextBody = email.plainTextBody;
			String strSubject = email.subject.replace('Re: Sandbox:', '').trim();
			if(strSubject.contains('-'))
			{
				String activityId = strSubject.substring(strSubject.lastIndexOf('-')).remove('-').trim();
				List<Event> lstEvent = [SELECT OwnerId, AccountId, ActivityDate, Subject FROM Event WHERE Id =: activityId LIMIT 1];
				List <User> lstUser = [Select Email From User where Id =:lstEvent[0].OwnerId ];
				//system.debug();
				if(!lstEvent.isEmpty() && email.fromAddress == lstUser[0].Email)
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
						//when reply is sent from outlook
						else if(String.isNotEmpty(plainTextBody) && plainTextBody.contains('From: noreply@salesforce.com'))
						{
							strBody = email.plainTextBody.replace(plainTextBody.subString(plainTextBody.indexOf('From: noreply@salesforce.com')),'').trim();
						}
						
						if(strBody.contains('Please see important legal disclaimer at') && strBody.contains('delivered by all parties thereto.'))
						{
							String endText = 'delivered by all parties thereto.';
							Integer startIndex = strBody.lastIndexOf('Please see important legal disclaimer at');
							Integer endIndex = strBody.lastIndexOf('delivered by all parties thereto.') + endText.length();
							strBody = strBody.replace(strBody.substring(startIndex, endIndex), '');								
						}
						
						/*Added by Lodhi PWP-43 - added Do_Not_Fire_Trigger__c flag to Avoiding firing of trigger while creating call report from create call report link and from email service handler.*/
						Call_Report__c objCR = new Call_Report__c(Name = (objEvent.Subject.length() > 80) ? objEvent.Subject.subString(0, 80) : objEvent.Subject,
						                                          Do_Not_Fire_Trigger__c = true, Notes__c  = strBody, OwnerId = objEvent.OwnerId,
						                                          Reference_Account__c = objEvent.AccountId, Call_Report_Date__c = objEvent.ActivityDate);
						insert objCR;
						
						List<Call_Report_Attendees__c> lstCRA = new List<Call_Report_Attendees__c>();
						
						for(EventRelation objEventRelation : [SELECT RelationId FROM EventRelation WHERE EventId =: activityId])
						{
							if(objEventRelation.RelationId.getSobjectType() == Contact.sobjectType)
								lstCRA.add(new Call_Report_Attendees__c(Call_Report__c = objCR.Id, Call_Report_Attendee__c = objEventRelation.RelationId));
						}
						
						if(!lstCRA.isEmpty())
							insert lstCRA;
						
						update new Event(Id = activityId, Call_Report_Id__c = objCR.Id);
					}
				}
			}
		}
		catch(EmailException ex)
		{
			
		}
		return new Messaging.InboundEmailResult();
	}
}