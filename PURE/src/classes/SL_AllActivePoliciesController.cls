/*
*  ClassName  	  : SL_AllActivePoliciesController
*  JIRATicket     : PURE-12
*  CreatedOn      : 1/29/2013
*  ModifiedBy     : Sandeep
*  Description    : Controller which will handle the backend functionality for showing all active policies for logged in member.  
*/

global without sharing class SL_AllActivePoliciesController 
{
	public List<policyWrapper> policies	{get;set;}//To store all active policies related to logged in user.
	public Account member {get;set;}
	
	public String autoPolicyLink		{get;set;}
	public String excessPolicyLink		{get;set;}
	public String floodPolicyLink		{get;set;}
	public String homeownerPolicyLink		{get;set;}
	public String collectionPolicyLink		{get;set;}
	public String watercraftPolicyLink		{get;set;}
	public String strEmailSubject			{get;set;}
	
	/*
        * MethodName        : pageAction
        * param             : None
        * Description       : This function will be called on load of member landing page to query all active policies and open claims related to loggedIn user.
    */
	public pageReference pageAction()
	{
		List<SL_PolicyStatusValues__c> lstSLPolicyStatusValues = new List<SL_PolicyStatusValues__c>();
		lstSLPolicyStatusValues = SL_PolicyStatusValues__c.getall().values();
				
		Set<String> setSLPolicyStatusValuesName = new Set<String>();
		
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		
		for(SL_PolicyStatusValues__c obj : lstSLPolicyStatusValues) {
			
			setSLPolicyStatusValuesName.add(obj.Name);
		}
		
		if(Userinfo.getUserType() == 'Guest') return new Pagereference('/LoginPage');//If logged in user type is 'Guest' then redirect to login page.
		
		String userRecordTypeId = '';//To store LoggedIn member record type.
		String userAccountId = '';//To store LoggedIn member account id.
		
		policies = new List<policyWrapper>();
		member = new Account();	
		strEmailSubject = autoPolicyLink = excessPolicyLink = floodPolicyLink = homeownerPolicyLink = collectionPolicyLink = watercraftPolicyLink = '';
		
		PortalURLMap__c oAutoPolicyLink = new PortalURLMap__c();
		PortalURLMap__c oExcessPolicyLink = new PortalURLMap__c();
		PortalURLMap__c oFloodPolicyLink = new PortalURLMap__c();
		PortalURLMap__c oHomeownerPolicyLink = new PortalURLMap__c();
		PortalURLMap__c oCollectionPolicyLink = new PortalURLMap__c();
		PortalURLMap__c oWatercraftPolicylink = new PortalURLMap__c();
		
		oAutoPolicyLink    =	PortalURLMap__c.getInstance('ProductAuto');
		oExcessPolicyLink = 	PortalURLMap__c.getInstance('ProductExcess');
		oFloodPolicyLink = 		PortalURLMap__c.getInstance('ProductFlood');
		oHomeownerPolicyLink = 	PortalURLMap__c.getInstance('ProductHome');
		oCollectionPolicyLink = PortalURLMap__c.getInstance('ProductJewelry');
		oWatercraftPolicylink = PortalURLMap__c.getInstance('ProductWatercraft');
		
		
		autoPolicyLink = (oAutoPolicyLink != null) ? oAutoPolicyLink.URL__c : '#';
		excessPolicyLink = (oExcessPolicyLink != null) ? oExcessPolicyLink.URL__c : '#';
		floodPolicyLink = (oFloodPolicyLink != null) ? oFloodPolicyLink.URL__c : '#';
		homeownerPolicyLink = (oHomeownerPolicyLink != null) ? oHomeownerPolicyLink.URL__c : '#';
		collectionPolicyLink = (oCollectionPolicyLink != null) ? oCollectionPolicyLink.URL__c : '#';
		watercraftPolicyLink = (oWatercraftPolicylink != null) ? oWatercraftPolicylink.URL__c : '#';
		
		/* Added regarding PURE-63*/
		// If accessed from Agent home page 
		if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
		{
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');
			
			for(User objUser : [SELECT Id, ContactId FROM User WHERE Id =: Userinfo.getUserId() LIMIT 1])
			{
				strContactId = objUser.ContactId;
			}
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active'
										   AND (Agency__r.Broker_Status__c = 'Active' 
										   OR Agency__r.Broker_Status__c = 'Suspended with Access')])
			{
				setAgencyContactId.add(obj.Agency__c);
			}
			
			if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
			{
				strBrocker =  'Broker__c IN: setAgencyContactId';
			} else {
					PageReference pageRef = new PageReference('/Exception');
					return pageRef;
			}
		}
		else
		{	
		
			/* This is to query logged in user account id.*/
			for(User objUser : [Select Id, Contact.AccountId, Contact.Account.RecordTypeId
								FROM User 
								WHERE Id=: Userinfo.getUserId()
								LIMIT 1])
			{
				userAccountId = objUser.Contact.AccountId;
			}
		}
		
		String strQuery = 'SELECT Id, Name,  Member_Key_EDW__c,In_Force_Flood_Policy__c, In_Force_Homeowners_Policy__c, In_Force_Excess_Policy__c,'
						  +	'In_Force_Collections_Policy__c, In_Force_Auto_Policy__c, In_Force_Watercraft_Policy__c';
		List<Account> lstAccount = new List<Account>();
		
		String strMember = 'Member';
		
		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			lstAccount = Database.query(strQuery);
			
			if(!lstAccount.isEmpty() && lstAccount != null)
				member = lstAccount[0];	
			
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
			if(!lstAccount.isEmpty() && lstAccount != null)
				member = lstAccount[0];
		}
		
		if(member != null)
			strEmailSubject = 'Member Portal:'+member.Name +','+ member.Member_Key_EDW__c ;
		
		/* Start - Your active policy section */
		for(Policy__c objPolicy : [Select Integration_Description__c, User_Description__c, Id, Policy_Number__c, Policy_Status__c, Policy_Term_Dates__c, Effective_Date__c, Expiration_Date__c, Description__c, Line_of_Business__c, LatestPolicyDocURL__c from Policy__c where Member__c = :userAccountId AND (Policy_Status__c IN : setSLPolicyStatusValuesName)])
		{
			String strDesc = (String.isEmpty(objPolicy.User_Description__c) ? objPolicy.Integration_Description__c : objPolicy.User_Description__c);
			policies.add(new policyWrapper(objPolicy.Line_of_Business__c.trim().toLowerCase(), objPolicy.Policy_Number__c, strDesc, objPolicy.Effective_Date__c, objPolicy.Expiration_Date__c, objPolicy.LatestPolicyDocURL__c, objPolicy.Id));
		}		
		
		/* End - Your active policy section */
		
		return null;
	}
	@RemoteAction
	public static String updatePolicyDescription(String policyId, String policyDescription)
	{
		Policy__c objPolicy = new Policy__c(Id = policyId,
											User_Description__c = policyDescription);
		Database.SaveResult sr = Database.update(objPolicy);
		if (sr.isSuccess())
		{
			if(String.isEmpty(policyDescription))
			{
				Policy__c policy = [SELECT Id, Integration_Description__c FROM Policy__c WHERE ID = :policyId];

				if(String.isNotBlank(policy.Integration_Description__c))
					return policy.Integration_Description__c;
			}
		}
		return policyDescription;
	}
	/* Inner class to store active policies related to loggedin user*/
	public class policyWrapper
	{
		public String policyType		{get;set;}
		public String policyNumber		{get;set;}
		public String policyDescription	{get;set;}
		public Date policyEffectiveDate	{get;set;}
		public Date policyEndDate		{get;set;}
		public String policyDownloadLink{get;set;}
		public String policyId			{get;set;}
		
		/* Inner class constructor */
		public 	policyWrapper(String policyType, String policyNumber, String policyDescription, Date policyEffectiveDate, Date policyEndDate, String policyDownloadLink, String policyId)
		{
			this.policyType = policyType;
			this.policyNumber = policyNumber;
			this.policyDescription = policyDescription;
			this.policyEffectiveDate = policyEffectiveDate;
			this.policyEndDate = policyEndDate;
			this.policyDownloadLink = policyDownloadLink;
			this.policyId = policyId;
		}
	}
}