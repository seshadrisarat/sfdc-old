public with sharing class SL_ForgotAgentUsernameController {

	public String brokerId {get; set;}
	public String dragonUsername {get;set;}
	public Boolean isError	{get;set;}

	public SL_ForgotAgentUsernameController() {
		
	}

	// send a username to registered user
	public void forgotUser()
	{
		isError = false;
		// Find the Agency Contact for the given Broker ID and Dragon Username
		List<Agency_Contact__c> agencyContact = [SELECT Contact__r.Id
							 					 FROM Agency_Contact__c
							 					 WHERE Agency__r.Broker_ID__c = :brokerId 
							 					   AND DragonID__c = :dragonUsername
							 					 LIMIT 1];
		String contactId = '';
		List<User> objUser = new List<User>();

		if(!agencyContact.isEmpty()){
			contactId = agencyContact[0].Contact__r.Id;

			objUser = [SELECT Id
					   FROM User 
					   WHERE ContactId = :contactId 
					     AND Profile.Name='PURE Broker View Partner Login User' 
					     AND IsActive = true
					   LIMIT 1];
		}

		System.debug('User: ' + objUser + ' -- ContactId: ' + contactId);
		if(!objUser.isEmpty())
		{
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTemplateId([Select Id from EmailTemplate where Name = 'Broker View of the Member Portal - Forgot Username'].Id); 
			email.setTargetObjectId(objUser[0].Id);
			email.setSenderDisplayName('PURE Insurance');
			email.setSaveAsActivity(false);

			List<Messaging.SendEmailResult> results;
			try{
				results = Messaging.sendEmail(new Messaging.Email[] { email });
				System.debug(results);
				if (results.get(0).isSuccess()) 
				{
					isError = false;	
				}
				else {
					isError = true;
					String errorMessage = results.get(0).getErrors()[0].getMessage();
				}
			}catch(Exception e){
				System.debug(e.getMessage());
			}
			
		}
		else
		{
			isError = true;
		}
	}
	
	public PageReference redirectToLoginPage()
	{
		system.debug('-----inside redirection-----');
		PageReference page = new PageReference('/BrokerLogin');
		page.setRedirect(true);
		return page;
	}
}