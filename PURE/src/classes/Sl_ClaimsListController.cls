/*
*  ClassName  	  : Sl_ClaimsListController
*  JIRATicket     : PURE-9
*  CreatedOn      : 12/31/2013
*  ModifiedBy     : Hemant
*  Description    :   
*/
public without sharing class Sl_ClaimsListController 
{
	/* Start of variables */
	public list<Sl_ClaimsWrapper> lstOpenClaims {get;set;}
	public list<Sl_ClaimsWrapper> lstClosedClaims {get;set;}
	public String currentURL {get;set;}
	public string memberName {get; set;}
	public string memberNumber {get; set;}
	/* End of Variables */
	
	/*
		Constructor
	*/
	public Sl_ClaimsListController()
	{
		lstOpenClaims = new list<Sl_ClaimsWrapper>();
		lstClosedClaims = new list<Sl_ClaimsWrapper>();
	}
	
	/*Wrapper Class*/
	public class Sl_ClaimsWrapper
	{
		public String policyType 			{	get;set;	}
		public String claimNumber   		{	get;set;	}
		public Decimal totalPaid			{	get;set;	}
		public String lossLocation			{	get;set;	}
		public Date   dateOfLoss 			{	get;set;	}
		public Boolean canShowDetail		{	get;set;	}
		public String claimStatus			{	get;set;	} 
		
		public Sl_ClaimsWrapper(String policyType, String claimNumber, Decimal totalPaid, String lossLocation, Date dateOfLoss,Boolean canShowDetail,String claimStatus)
		{
			this.policyType 	= 	policyType.trim().toLowerCase();
			this.claimNumber 	= 	claimNumber;
			this.totalPaid 		= 	totalPaid;
			this.lossLocation 	= 	lossLocation;
			this.dateOfLoss 	= 	dateOfLoss;
			this.canShowDetail 	= 	canShowDetail;
			this.claimStatus	=	claimStatus;	
		}
	}
	
	/*
		Name: pageAction
		Param: None
		Description: This page action method will ensure that non authenicated user can't see the page content
	*/
	public pageReference pageAction()
	{
		
		if(Userinfo.getUserType() == 'Guest') return new Pagereference('/LoginPage');//If logged in user type is 'Guest' then redirect to login page.

		String userAccountId;	//This is to store logged in user account id.
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		String strQuery = 'SELECT Name,Member_Key_EDW__c';
		String strMember = 'Member';
		List<Account> lstAccount = new List<Account>();
		
		/* If it is accessed from AgentHomepage // Added regarding PURE-63   */
		if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
		{
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');
			
			for(User objUser : [SELECT Id, Contact.AccountId, ContactId FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1])
				strContactId = objUser.ContactId;
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active' 
										   AND (Agency__r.Broker_Status__c = 'Active' 
										    OR Agency__r.Broker_Status__c = 'Suspended with Access')])
				setAgencyContactId.add(obj.Agency__c);
			
			if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
				strBrocker =  'Broker__c IN: setAgencyContactId';
			else{
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			/* This is to query logged in user account id.*/
			for(User objUser : [Select Id, Contact.AccountId from User where Id=: Userinfo.getUserId() limit 1])
			{
				userAccountId = objUser.Contact.AccountId;
			}
		}
		
		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			lstAccount = Database.query(strQuery);
			
			if(lstAccount.isEmpty() || lstAccount == null )
			{
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			strQuery +=	' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
			lstAccount = Database.query(strQuery);
		}
		
		// setting the Member Id
		if(!lstAccount.isEmpty() && lstAccount != null)
		{
			for(Account objAccount : lstAccount)
			{
				memberNumber = objAccount.Member_Key_EDW__c;
				memberName = objAccount.Name;
			}
		}	
		
		//Prepare a list of open and closed claims to display them on page	
		for(Claim__c objClaim : [Select Id, RecordType.Name, Loss_Location__c, Claim_Number__c, Total_Paid__c, Date_of_Loss__c, Claim_Status__c, CanShowDetails__c, Description__c, Line_of_Business__c, Member__r.Name, Portal_Closed_Date__c   
								 from Claim__c where Member__c = :userAccountId order by Date_of_Loss__c])
		{	
			if(objClaim.Claim_Status__c != null && objClaim.Claim_Status__c != ''  && objClaim.Claim_Status__c.trim().toLowerCase() == 'in progress')
			{
				lstOpenClaims.add(new Sl_ClaimsWrapper(objClaim.Line_of_Business__c,objClaim.Claim_Number__c,objClaim.Total_Paid__c,objClaim.Loss_Location__c,objClaim.Date_of_Loss__c,objClaim.CanShowDetails__c,objClaim.Claim_Status__c));
			}
			else if(objClaim.Claim_Status__c != null && objClaim.Claim_Status__c != ''  && (objClaim.Claim_Status__c.trim().toLowerCase() == 'closed' || objClaim.Claim_Status__c.trim().toLowerCase() == 'in subrogation') &&  objClaim.Portal_Closed_Date__c!= null && objClaim.Portal_Closed_Date__c.daysBetween(date.today()) < 60)  
			{
				lstClosedClaims.add(new Sl_ClaimsWrapper(objClaim.Line_of_Business__c,objClaim.Claim_Number__c,objClaim.Total_Paid__c,objClaim.Loss_Location__c,objClaim.Date_of_Loss__c,objClaim.CanShowDetails__c,objClaim.Claim_Status__c));
			}
		}
		return null;
	}
	
}