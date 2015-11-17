/*
*  ComponentName  : SL_SiteHeaderComponentController
*  JIRATicket     : PURE-1
*  CreatedOn      : 1/7/2014
*  ModifiedBy     : Sandeep
*  Description    : A controller which will contain the Info regarding past due amount of user.  
*/

public with sharing class SL_SiteHeaderComponentController {
	
	public Boolean isOverdue {get;set;}//To check whether user account is having past due amount or not.
	public String strNavClicked{get;set;}//To store pageName to identify which page is clicked from nav link.
	public String showLinks{get;set;}//Hides header links if on agent home page, otherwise shows them
	public String strMemberId{get;set;} // MemberId 
	public String brokerFirstName {get;set;}
	public String brokerLastName {get;set;}
	public String bId {get;set;}
	
	/* Main Constructor */
	public SL_SiteHeaderComponentController()
	{
		String path = Url.getCurrentRequestUrl().getPath();
		showLinks = path.contains('BrokerHomePage') ? 'none' : '';

		isOverdue = false;
		strNavClicked = '';
		String currentURL = Apexpages.currentPage().getUrl();

		if(ApexPages.currentPage().getParameters().containsKey('bid')){
			bId = ApexPages.currentPage().getParameters().get('bid');

			List<Contact> broker = [SELECT firstName, lastName FROM Contact WHERE Id = :bId];
			if(broker.size() > 0){
				brokerFirstName = broker[0].firstName;
				brokerLastName = broker[0].lastName;
			} else {
				bId = null;
			}
		}
		
		/* If clicked nav link is profilelink*/
		if(currentURL != null && currentURL.contains('MemberHomePage'))
		{
			strNavClicked = 'MemberHomePage';
		}
		else if(currentURL != null && currentURL.contains('ProfileSettingPage'))
		{
			strNavClicked = 'ProfileSettingPage';
		}
		/* If clicked nav link is your policy link */
		else if(currentURL!= null && currentURL.contains('AllActivePolicies'))
		{
			strNavClicked = 'AllActivePolicies';
		}
		else if(currentURL!= null && currentURL.contains('PolicyDetailPage'))
		{
			strNavClicked = 'AllActivePolicies';
		}
		/* If clicked nav link is Billing summary link*/
		else if(currentURL!= null && currentURL.contains('BillingSummary'))
		{
			strNavClicked = 'BillingSummary';
		}
		/* If clicked nav link is claimstracker link*/
		else if(currentURL!= null && currentURL.contains('claimsList'))
		{
			strNavClicked = 'claimsList';
		}
		/* If clicked nav link is Discounts link*/
		else if(currentURL!= null && currentURL.contains('Discounts'))
		{
			strNavClicked = 'Discounts';
		}
		else if(currentURL!= null && currentURL.contains('MemberLandingPage'))
		{
			strNavClicked = 'HomePage';
		}
		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;

		strMemberId = ApexPages.currentPage().getParameters().get('mId');
		if(strMemberId != null)
		{
			List<Account> currMember = [SELECT IsOverdue__c FROM Account WHERE Id =:strMemberId LIMIT 1];
			for(Account a : currMember)
			{
				if(a.IsOverdue__c != null && a.IsOverdue__c > 0)
				{
					isOverdue = true;
				}
			}
		} else {
			List<User> lstCurrentUser = [SELECT Id, Contact.AccountId, Contact.Account.IsOverdue__c 
										 FROM User 
										 WHERE Id=: Userinfo.getUserId() LIMIT 1];

			/* This is to query account isOverdue amount related to logged in user.*/
			for(User objUser : lstCurrentUser)
			{
				/* If isOverdue field on account is not null then check if isOverdue is greater than 0.*/
				if (objUser.Contact.Account.IsOverdue__c != null && objUser.Contact.Account.IsOverdue__c > 0)
				{
					isOverdue = true;
				}
			}
		}
	}
}