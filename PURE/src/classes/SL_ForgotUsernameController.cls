/*
*  PageName       : SL_ForgotUsernameController
*  JIRATicket     : PURE-5
*  CreatedOn      : 12/26/2013
*  ModifiedBy     : Hemant
*  Description    : Sending forgot username to there register email address.  
*/
public with sharing class SL_ForgotUsernameController {
	
	public String memberId {get; set;}
	public Boolean isError	{get;set;}
	
	public SL_ForgotUsernameController()
	{
		///
		
	}
	// send a username to registered user
	public void forgotUser()
	{
		isError = false;
		List<Account> acc = [SELECT Id, Member_Key_EDW__c, (SELECT Id FROM Contacts) 
							FROM Account 
							WHERE Member_Key_EDW__c =:memberId 
							LIMIT 1];

		Set<Id> contactIds = new Set<Id>();
		if(!acc.isEmpty())
		{
			if(acc[0].Contacts != null)
			{
				for(Contact con : acc[0].Contacts)
				{
					contactIds.add(con.Id);
				}
			}
		}

		List<User> objUser = [SELECT Id
								FROM User 
								WHERE ContactId IN :contactIds AND Profile.Name='Pure Customer Community Login User' AND IsActive = true
								LIMIT 1];
		System.debug('User: ' + objUser + ' -- ContactIds: ' + contactIds + ' -- Account: ' + acc);
		if(!objUser.isEmpty())
		{
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setTemplateId([Select Id from EmailTemplate where Name = 'Forgot Username Email Reminder'].Id); 
			email.setTargetObjectId(objUser[0].Id);
			email.setSenderDisplayName('PURE Insurance');
			email.setSaveAsActivity(false);

			List<Messaging.SendEmailResult> results;
			try{
				results = Messaging.sendEmail(new Messaging.Email[] { email });
				System.debug(results);
				if (results.get(0).isSuccess()) 
				{
					/*PageReference page = System.Page.LoginPage;
					page.setRedirect(true);
					return page;*/
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
		PageReference page = new PageReference('/LoginPage');
		page.setRedirect(true);
		return page;
	}
}