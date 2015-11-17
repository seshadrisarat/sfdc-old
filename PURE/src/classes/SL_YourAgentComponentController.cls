/*
*  ClassName      : SL_YourAgentComponentController
*  JIRATicket     : PURE-1, PURE-17
*  CreatedOn      : 1/10/2014
*  ModifiedBy     : Sandeep
*  Description    : Controller to hold logged in user agent information and it is also used to send an email regarding query entered from user to PURE authorixed members 
*/
public with sharing class SL_YourAgentComponentController 
{
	public Account brokerInformation			{get;set;}
	public Account member 						{get;set;}
	public Boolean isAgentAssociated			{get;set;}
	public Boolean isLogo						{get;set;}
	public Boolean isDefaultImage				{get;set;}
	public String photoUrl						{get;set;}
	public Boolean isContactpage				{get;set;}
	public String memberName					{get;set;}
	public String memberId						{get;set;}
	
	public String memberServiceEmailInfo		{get;set;}//To store information entered from user's for member service.
	public String memberAdvocateEmailInfo		{get;set;}//To store information entered from user's for advocate.
	public String claimEmailInfo				{get;set;}//To store information entered from user's for claim.
	
	public String pureInsurancelink			{get;set;}
	public String privacyPolicyLink			{get;set;}
	public String fAQlink					{get;set;}
	public String shareYourStorylink		{get;set;}
	
	/* Main Constructor */
	public SL_YourAgentComponentController()
	{
		//String userBrokerId = '';//To store user's account id.
		photoUrl = '';
		pureInsurancelink = privacyPolicyLink = fAQlink = shareYourStorylink = '';
		isAgentAssociated = isLogo = isContactpage = false;
		brokerInformation = new Account();
		member = new Account();
		memberServiceEmailInfo = memberAdvocateEmailInfo = claimEmailInfo = '';
		
		if(Apexpages.currentPage().getUrl() != null){
			if(Apexpages.currentPage().getUrl().contains('ContactUsPage'))
			{
				isContactpage = true;
			}
		}
		
		PortalURLMap__c oFAQ = new PortalURLMap__c();
		PortalURLMap__c oPureinsurance = new PortalURLMap__c();
		PortalURLMap__c oPrivacyPolicy = new PortalURLMap__c();
		PortalURLMap__c oShareYourStory = new PortalURLMap__c();
		
		oFAQ = PortalURLMap__c.getInstance('FAQ');
		oPureinsurance = PortalURLMap__c.getInstance('pureInsurance.com');
		oPrivacyPolicy = PortalURLMap__c.getInstance('PrivacyPolicy');
		oShareYourStory = PortalURLMap__c.getInstance('ShareYourStory');

		fAQlink = (oFAQ != null) ? oFAQ.URL__c : '#';
		pureInsurancelink = (oPureinsurance != null) ? oPureinsurance.URL__c : '#';
		privacyPolicyLink = (oPrivacyPolicy != null) ? oPrivacyPolicy.URL__c : '#';
		shareYourStorylink = (oShareYourStory != null) ? oShareYourStory.URL__c : '#';
		pageAction();
	}
	
	/*
        * MethodName        : pageAction
        * param             : None
        * Description       : This function will be called on load of contactusPage.
    */
	public pageReference pageAction()
	{
		String userAccountId ='';
		String brokerId = '';
		String strBrocker = '';
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		String strQuery = 'SELECT Id, Phone, Primary_Email__c,Name,Member_Key_EDW__c';
		String strMember = 'Member';
		String userId = Userinfo.getUserId();
		List<Account> lstAccount = new List<Account>();
		
		/* If it is accessed from AgentHomepage // Added regarding PURE-63   */
		if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
		{
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');
			
			for(User objUser : [SELECT Id, ContactId FROM User WHERE Id =: userId LIMIT 1]){
				strContactId = objUser.ContactId;
			}
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active'
										   AND (Agency__r.Broker_Status__c = 'Active' 
										   OR Agency__r.Broker_Status__c = 'Suspended with Access')]){
				setAgencyContactId.add(obj.Agency__c);
				brokerId = obj.Agency__c;
			}

			System.debug('!!!! brokerId: ' + brokerId);
			
			if(!setAgencyContactId.isEmpty()){
				strBrocker = 'Broker__c IN: setAgencyContactId';
			}
			else {
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			/* This is to query logged in user account id.*/
			for(User objUser : [Select Id, Contact.AccountId, Contact.Account.Broker__c from User where Id=: userId limit 1])
			{
				userAccountId = objUser.Contact.AccountId;
				brokerId = objUser.Contact.Account.Broker__c;
			}	
		}
		
		// If we are accessing this from another user, we are not accessing through the community, so don't do this query
		if(strProfileName == 'Pure Customer Community Login User' || strProfileName == 'PURE Broker View Partner Login User'){

			if(!String.isEmpty(strBrocker) && strBrocker != '')
			{
				strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + 
							strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';

				lstAccount = Database.query(strQuery);
				
				if(lstAccount.isEmpty() || lstAccount == null )
					return (new PageReference('/Exception'));
			}
			else
			{
				strQuery +=	' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
				lstAccount = Database.query(strQuery);
			}
			
			if(!lstAccount.isEmpty() && lstAccount != null)
			{
				member = lstAccount[0];
				memberName = lstAccount[0].Name;
				memberId = lstAccount[0].Id;
			}
		}

		System.debug('~~~~~UserAccountId: ' + userAccountId);

		if(userAccountId != null)
		{
			
			List<Account> brokersList = [SELECT Id, Name, Logo__c, Phone, Website 
										 FROM Account WHERE ID =:brokerId];

			System.debug('~~~~~brokerId: ' + brokerId + ' -- brokersList: ' + brokersList);
			if(!brokersList.isEmpty())
			{
				isAgentAssociated = true;
				brokerInformation = brokersList[0];
			}
		}
		// Billing Page.
		if(ApexPages.currentPage().getParameters().containsKey('aId') || test.isRunningTest())
		{
			String aId = ApexPages.currentPage().getParameters().get('aId');
			List<Account> acct = [select Id, Broker__c from Account where id=:aId];
			if(!acct.isEmpty())
			{
				brokerId = acct[0].Broker__c;
			}
		}
		// Landing Page
		if(ApexPages.currentPage().getParameters().containsKey('cId') || test.isRunningTest())
		{
			String cId = ApexPages.currentPage().getParameters().get('cId');
			List<Contact> con = [select Id, Account.Broker__c from contact where id=:cId];
			if(!con.isEmpty())
			{
				brokerId = con[0].Account.Broker__c;
			}
		}
		// Policy detail page.
		if(ApexPages.currentPage().getParameters().containsKey('pId') || test.isRunningTest())
		{
			String pId = ApexPages.currentPage().getParameters().get('pId');
			List<Policy__c> acct = [select Id, Member__r.Broker__c from Policy__c where id=:pId];
			if(!acct.isEmpty())
			{
				brokerId = acct[0].Member__r.Broker__c;
			}
		}
		//Claim page.
		if(ApexPages.currentPage().getParameters().containsKey('url') || test.isRunningTest())
		{
			String strClaimNumber = ApexPages.currentPage().getParameters().get('url');
			if(strClaimNumber != null && strClaimNumber != '') 
			{
				List<Claim__c> lstClaim = new List<Claim__c>([Select Id, Member__r.Broker__c From Claim__c Where Claim_Number__c = :strClaimNumber]);
				if(!lstClaim.isEmpty()) 
				{
					if(lstClaim[0].Member__r.Broker__c != null)
					{
						brokerId = lstClaim[0].Member__r.Broker__c;
					}
				}
			}
		}

		if(brokerId != null){
			List<Account> brokerList = [Select Id, Name, Logo__c, Phone, Website from Account where Id=:brokerId];
			if(!brokerList.isEmpty())
			{
				isAgentAssociated = true;
				brokerInformation=brokerList[0];
			}
		}
		
		isDefaultImage = false;
		isLogo = false;

		brokerId = (brokerId == null?'':brokerId);
		
		for(Portal_Image__c objPortalImage : [Select Id, Image__c, Broker__c, Static_Resource_Image_Path__c, 
													 Use_Photo_Field__c 
											  From Portal_Image__c 
											  Where Broker__c =: brokerId
											  		])
		{
			isLogo = true;
			if(objPortalImage.Use_Photo_Field__c == true)
			{
				if(objPortalImage.Image__c != null)
					photoUrl = objPortalImage.Image__c;
				else
					isLogo = false;
			}
			else
			{
				if(objPortalImage.Static_Resource_Image_Path__c != null) {
					photoUrl = objPortalImage.Static_Resource_Image_Path__c;
					isDefaultImage = true;
				}
				else
					isLogo = false;
			}
		}
		return null;
	}
	
	/*
        * MethodName        : sendEmailToMemberServices
        * param             : None
        * Description       : This function will called when user enters any query and feedback in member service text box and clicks on submit.
    */
	public PageReference sendEmailToMemberServices()
	{
		Messaging.reserveSingleEmailCapacity(1);
		try{
			EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Portal_ContactUs_Member_Services'];

			
			if(emailTemplate !=null)
			{
				String subject = emailTemplate.Subject;
				String htmlBody = emailTemplate.HtmlValue;
				String plainBody = emailTemplate.Body;
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setSaveAsActivity(false);
				email.setSenderDisplayName('Member Portal');
				subject = subject.replace('{!Account.Name}', member.Name);
				subject = subject.replace('{!Account.Member_Key_EDW__c}',member.Member_Key_EDW__c);
				email.setSubject(subject);

				htmlBody = htmlBody.replace('{!Account.Name}', member.Name);
				htmlBody = htmlBody.replace('{!Account.Primary_Email__c}', member.Primary_Email__c);
				htmlBody = htmlBody.replace('{!Account.Phone}', member.Phone);
				htmlBody = htmlBody.replace('MEMBER_SERVICES_TEXT_PLACEHOLDER', memberServiceEmailInfo);
				email.setHtmlBody(htmlBody);

				plainBody = plainBody.replace('{!Account.Name}', member.Name);
				plainBody = plainBody.replace('{!Account.Primary_Email__c}',member.Primary_Email__c);
				plainBody = plainBody.replace('{!Account.Phone}',member.Phone);
				plainBody = plainBody.replace('MEMBER_SERVICES_TEXT_PLACEHOLDER', memberServiceEmailInfo.stripHtmlTags());
				email.setPlainTextBody(plainBody);

				// Try to find the default claims user to send the email to.
				List<User> objMADefaultUser = [SELECT Id FROM User 
												  WHERE IsActive = true AND Default_MemberService_User__c = true
												  ORDER BY LastLoginDate DESC NULLS LAST LIMIT 1 ];
				if(!objMADefaultUser.isEmpty())
				{
					email.setTargetObjectId(objMADefaultUser[0].Id);
				}
				else
				{
					email.setToAddresses(new List<String>{'service@pureinsurance.com'});
				}
			    
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
			}
		}
		catch(Exception e){
			String description =  'Email Template not found when trying to use contact us page, member services section, on the portal. For member:' + member.Name + '; member id: ' + member.Member_Key_EDW__c + ' with message: ' + memberServiceEmailInfo + '. <br>Exception: ' +e.getMessage();
			createDebugLog(description,member.Member_Key_EDW__c);
		}
		
		Pagereference pg = new Pagereference('/ContactUsPage');
		return pg;
		
	}
	
	/*
        * MethodName        : sendEmailToMemberAdvocate
        * param             : None
        * Description       : This function will called when user enters any query and feedback in member advocate text box and clicks on submit.
    */
	public PageReference sendEmailToMemberAdvocate()
	{
		Messaging.reserveSingleEmailCapacity(1);
		try{
			EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Portal_ContactUs_Member_Advocate'];

			
			if(emailTemplate !=null)
			{
				String subject = emailTemplate.Subject;
				String htmlBody = emailTemplate.HtmlValue;
				String plainBody = emailTemplate.Body;
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setSaveAsActivity(false);
				email.setSenderDisplayName('Member Portal');
				subject = subject.replace('{!Account.Name}', member.Name);
				subject = subject.replace('{!Account.Member_Key_EDW__c}',member.Member_Key_EDW__c);
				email.setSubject(subject);

				htmlBody = htmlBody.replace('{!Account.Name}', member.Name);
				htmlBody = htmlBody.replace('{!Account.Primary_Email__c}', member.Primary_Email__c);
				htmlBody = htmlBody.replace('{!Account.Phone}', member.Phone);
				htmlBody = htmlBody.replace('MEMBER_ADVOCATE_TEXT_PLACEHOLDER', memberAdvocateEmailInfo);
				email.setHtmlBody(htmlBody);

				plainBody = plainBody.replace('{!Account.Name}', member.Name);
				plainBody = plainBody.replace('{!Account.Primary_Email__c}',member.Primary_Email__c);
				plainBody = plainBody.replace('{!Account.Phone}',member.Phone);
				plainBody = plainBody.replace('MEMBER_ADVOCATE_TEXT_PLACEHOLDER', memberAdvocateEmailInfo.stripHtmlTags());
				email.setPlainTextBody(plainBody);

				// Try to find the default claims user to send the email to.
				List<User> objMADefaultUser = [SELECT Id FROM User 
												  WHERE IsActive = true AND Default_Member_Advocate_User__c = true
												  ORDER BY LastLoginDate DESC NULLS LAST LIMIT 1 ];
				if(!objMADefaultUser.isEmpty())
				{
					email.setTargetObjectId(objMADefaultUser[0].Id);
				}
				else
				{
					email.setToAddresses(new List<String>{'memberadvocate@pureinsurance.com'});
				}
			    
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
			}
		}
		catch(Exception e){
			String description =  'Email Template not found when trying to use contact us page, member advocate section, on the portal. For member:' + member.Name + '; member id: ' + member.Member_Key_EDW__c + ' with message: ' + memberAdvocateEmailInfo + '. <br>Exception: ' +e.getMessage();
			createDebugLog(description,member.Member_Key_EDW__c);
		}
		
		Pagereference pg = new Pagereference('/ContactUsPage');
		return pg;
	}
	
	/*
        * MethodName        : sendEmailToClaims
        * param             : None
        * Description       : This function will called when user enters any query and feedback in member claim text box and clicks on submit.
    */
	public PageReference sendEmailToClaims()
	{
		
		Messaging.reserveSingleEmailCapacity(1);
		try{
			EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Portal_ContactUs_Claims'];

			
			if(emailTemplate !=null)
			{
				String subject = emailTemplate.Subject;
				String htmlBody = emailTemplate.HtmlValue;
				String plainBody = emailTemplate.Body;
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				email.setSaveAsActivity(false);
				email.setSenderDisplayName('Member Portal');
				//email.setTemplateId(emailTemplate.Id);
				subject = subject.replace('{!Account.Name}', member.Name);
				subject = subject.replace('{!Account.Member_Key_EDW__c}',member.Member_Key_EDW__c);
				email.setSubject(subject);

				htmlBody = htmlBody.replace('{!Account.Name}', member.Name);
				htmlBody = htmlBody.replace('{!Account.Primary_Email__c}', member.Primary_Email__c);
				htmlBody = htmlBody.replace('{!Account.Phone}', member.Phone);
				htmlBody = htmlBody.replace('CLAIMS_EMAIL_TEXT_PLACEHOLDER', claimEmailInfo);
				email.setHtmlBody(htmlBody);

				plainBody = plainBody.replace('{!Account.Name}', member.Name);
				plainBody = plainBody.replace('{!Account.Primary_Email__c}',member.Primary_Email__c);
				plainBody = plainBody.replace('{!Account.Phone}',member.Phone);
				plainBody = plainBody.replace('CLAIMS_EMAIL_TEXT_PLACEHOLDER', claimEmailInfo.stripHtmlTags());
				email.setPlainTextBody(plainBody);

				// Try to find the default claims user to send the email to.
				List<User> objClaimDefaultUser = [SELECT Id FROM User 
												  WHERE IsActive = true AND Default_Claims_User__c = true
												  ORDER BY LastLoginDate DESC NULLS LAST LIMIT 1 ];
				if(!objClaimDefaultUser.isEmpty())
				{
					email.setTargetObjectId(objClaimDefaultUser[0].Id);
				}
				else
				{
					email.setToAddresses(new List<String>{'claims@pureinsurance.com'});
				}
			    
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
			}
		}
		catch(Exception e){
			String description =  'Email Template not found when trying to use contact us page, claim section, on the portal. For member:' + member.Name + '; member id: ' + member.Member_Key_EDW__c + ' with message: ' + claimEmailInfo + '. <br>Exception: ' +e.getMessage();
			createDebugLog(description,member.Member_Key_EDW__c);
		}
		
		Pagereference pg = new Pagereference('/ContactUsPage');
		return pg;
	}

	private void createDebugLog(string message, string recId)
	{
		Debug_Log__c log = new Debug_Log__c(Description__c=message,Record_Id__c=recId);
		insert log;
	}
}