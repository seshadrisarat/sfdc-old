/*
*  ClassName  	  : SL_MemberLandingPageController
*  JIRATicket     : PURE-7
*  CreatedOn      : 12/31/2013
*  ModifiedBy     : Sandeep
*  Description    : A component which will use to display the logged in user information, all active policies and open claims related to the users with pure.  
*/

global without sharing class SL_MemberLandingPageController {
	
	public List<claimsWrapper> lstOpenClaims {get;set;}
	public List<policyWrapper> lstActivePolicyWrapper {get;set;}
	public List<policyWrapper> lstBillingPolicyWrapper {get;set;}
	
	public Account member {get;set;}
	private String policyId;
	private String policyDescription;
	private String strUserId = '';
	private String strAccountId = '';
	public String payMyBillLink {get;set;}
	public Boolean isError {get; set;}
	public String primaryEmail	{get;set;}
	public String primaryAddress	{get;set;}
	
	public String PrimaryMailingAddrs 										{get;set;}
	public String PrimaryBillingAddrs 										{get;set;}
	public String PrimaryPhone												{get;set;}
	
	public Decimal primaryTotalCharges										{get;set;}
	public Decimal primaryMinDue											{get;set;}
	public Decimal primaryBalance											{get;set;}
	public boolean isNotIndividuallyBilled                                  {get;set;}
	private String strProfileName = '';
	
	public SL_MemberLandingPageController()
	{
		isError = false;
		payMyBillLink = '';
		PortalURLMap__c oPayMyBillLink = new PortalURLMap__c();
		oPayMyBillLink = PortalURLMap__c.getInstance('PayBill');
		payMyBillLink = (oPayMyBillLink != null) ? oPayMyBillLink.URL__c : '#';
		PrimaryMailingAddrs = PrimaryBillingAddrs = primaryEmail = primaryAddress = PrimaryPhone = '';
		primaryTotalCharges = primaryMinDue = primaryBalance = 0;
		member = new Account();
		
		strProfileName = [SELECT Id,Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		
		//If it is not accessing from portal
		if(Apexpages.currentPage().getParameters().containsKey('cid'))
		{
			String strContactId = Apexpages.currentPage().getParameters().get('cid');
			if(strContactId != null && strContactId != '') 
			{
					List<Contact> lstContact = new List<Contact>([Select Id, AccountId From Contact Where Id = :strContactId]);
					if(!lstContact.isEmpty()) 
					{
						/*if(lstContact[0].AccountId != null)
						{*/
							strAccountId = lstContact[0].AccountId;
						/*}
						else
						{
							system.debug('-----------4-------------');
							ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 
							'Invalid Parameter');
							ApexPages.addMessage(msg);
							isError = true;
						}*/
							
					}
					else
					{
						// Invalid contact Id / no user found - show an error
						ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 
						'Invalid Parameter');
						ApexPages.addMessage(msg);
						isError = true;
					}
			}
			else
			{
				//please provide a contact id.
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 
				'Invalid Parameter');
				ApexPages.addMessage(msg);	
				isError = true;
			}
		}
		else
		{
			strUserId = Userinfo.getUserId();
		}
	}
	
	/*
        * MethodName        : pageAction
        * param             : None
        * Description       : This function will be called on load of member landing page to query all active policies and open claims related to loggedIn user.
    */
	public pageReference pageAction()
	{
		String strBrocker = ''; 

		// make guests login first.
		if(Userinfo.getUserType() == 'Guest' && strProfileName == 'Pure Customer Community Login User'){
			return new PageReference('/LoginPage');
		} 

		// If logged in as an Agent but there is no mId parameter, then we have logged 
		// in as a user from Salesforce so redirect to the agent home page
		//if(!Apexpages.currentPage().getParameters().containsKey('mId') 
		//	&& strProfileName != 'Pure Customer Community Login User'){
		//	return new PageReference('/AgentHomePage');
		//}
		
		List<SL_PolicyStatusValues__c> lstSLPolicyStatusValues = new List<SL_PolicyStatusValues__c>();
		lstSLPolicyStatusValues = SL_PolicyStatusValues__c.getall().values();
		
		Set<String> setSLPolicyStatusValuesName = new Set<String>();
		
		for(SL_PolicyStatusValues__c obj : lstSLPolicyStatusValues) {
			
			setSLPolicyStatusValuesName.add(obj.Name);
		}
		
		//instantiate some variables.
		lstActivePolicyWrapper = new List<policyWrapper>();
		lstBillingPolicyWrapper = new list<policyWrapper>();
		lstOpenClaims = new List<claimsWrapper>();
		String userAccountId;
		//member = new Account();
		
		/* Added regarding PURE-63 */
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();
		
		/* If it is accessed from Agent home page */ 
		if(Apexpages.currentPage().getParameters().containsKey('mId') && strProfileName != 'Pure Customer Community Login User')
		{
			// Member Id
			userAccountId = Apexpages.currentPage().getParameters().get('mId');
			
			for(User objUser : [SELECT Id, User_s_Email__c, Contact.AccountId, ContactId
			 					  FROM User 
			 					 WHERE Id =: Userinfo.getUserId()
			 					 LIMIT 1])
			{
				strContactId = objUser.ContactId; 
				primaryEmail = objUser.User_s_Email__c;
			}
			
			for(Agency_Contact__c obj : [SELECT Agency__c 
										 FROM Agency_Contact__c 
										 WHERE Contact__c =: strContactId 
										   AND User_Status__c = 'Active'
										   AND (Agency__r.Broker_Status__c = 'Active' 
										   OR Agency__r.Broker_Status__c = 'Suspended with Access')])
				setAgencyContactId.add(obj.Agency__c);
			
			if(!setAgencyContactId.isEmpty() && setAgencyContactId != null)
				strBrocker =  'Broker__c IN: setAgencyContactId';
			else {
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		
		else if(strAccountId == '')
		{
			// get the account id for the currently logge din user;
			for(User objUser : [Select Id, User_s_Email__c, Contact.AccountId, Contact.Account.RecordTypeId,Contact.Account.IsOverdue__c
			 					FROM User 
			 					WHERE Id=:strUserId
			 					LIMIT 1])
			{
				primaryEmail = objUser.User_s_Email__c;
				userAccountId = objUser.Contact.AccountId;
			}
			
		}
		else
		{
			userAccountId = strAccountId;
		}

		String strQuery = 'SELECT Id, RecordTypeId, Last_Payment_Received__c,Member_Key_EDW__c, Name, Five_Year_Service_Date__c,IsOverdue__c, In_Force_Flood_Policy__c,'
						  +	'SSA_Balance__c, Phone,Primary_Email__c , BillingPostalCode, Billing_Document_Delivery_Method__c,Total_Charges__c, Balance__c, Min_Due__c,' 
						  + 'Last_Payment_Date__c, billingAddress__c, shippingAddress__c';	
		
		
		List<Account> lstAccount = new List<Account>();
		
		String strMember = 'Member';

		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			lstAccount = Database.query(strQuery);
			
			if(lstAccount.isEmpty() || lstAccount == null )
			{
				System.debug('~~~~ Redirecting to exception, this Broker doesn\'t have access to this member');
				PageReference pageRef = new PageReference('/Exception');
				return pageRef;
			}
		}
		else
		{
			strQuery +=	' FROM Account WHERE Id=' + '\'' + userAccountId +'\' LIMIT 1';
			lstAccount = Database.query(strQuery);
		}

		// get all the account information to be displayed on the page.
		if(!lstAccount.isEmpty() && lstAccount != null)
		{
			for(Account memberAccount : lstAccount)
			{
				member = memberAccount;
				System.debug('~~~~~ member: ' + member);
				PrimaryPhone = memberAccount.Phone;
				primaryEmail = memberAccount.Primary_Email__c;
				PrimaryBillingAddrs = memberAccount.billingAddress__c;
				PrimaryMailingAddrs = memberAccount.shippingAddress__c;
			}
		
			for(Contact_Info__c objContInfo : [	SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
													Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,	Receive_PURE_Prevention__c,
													Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
													Type__c,Zip__c,Zip_Old__c,Account__c
												FROM Contact_Info__c 
												WHERE Account__c =: userAccountId ])
			{
				if( objContInfo.Type__c == 'Mailing')
			    {
			    	if(objContInfo.Is_Primary__c)
						PrimaryMailingAddrs = (objContInfo.Street__c != null ? (objContInfo.Street_2__c != null ? objContInfo.Street__c+' ' : objContInfo.Street__c+', ') : '') + (objContInfo.Street_2__c != null ? objContInfo.Street_2__c + ', ' : '') + ' <br/> '+ (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c : '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c : '');
			    } 	
			    if( objContInfo.Type__c == 'Billing')
			    {
			    	if(objContInfo.Is_Primary__c)							 
						PrimaryBillingAddrs = (objContInfo.Street__c != null ? (objContInfo.Street_2__c != null ? objContInfo.Street__c+' ' : objContInfo.Street__c+', ') : '') + (objContInfo.Street_2__c != null ? objContInfo.Street_2__c + ', ' : '') + ' <br/> '+ (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c : '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c : '');
			    }	
			    if( objContInfo.Type__c == 'Email' )
			    {
			    	if(objContInfo.Is_Primary__c) {
			    		if(objContInfo.Email__c != null && objContInfo.Email__c != '')
			    			primaryEmail = objContInfo.Email__c;
			    	}
			    }
			    if( objContInfo.Type__c == 'Phone-Home' || objContInfo.Type__c == 'Phone-Work' || objContInfo.Type__c == 'Phone-Mobile')
			    {
			    	if(objContInfo.Phone__c != null && objContInfo.Phone__c != '') {
			    		PrimaryPhone = objContInfo.Phone__c;
			    	}
			    }
			}
			Integer I = 0;
			// Get a list of policies for this member;
			for(Policy__c objPolicy : [Select Integration_Description__c, IsOverdue__c,IsIndividuallyBilled__c, 	Balance__c, Total_Charges__c, Min_Due__c, User_Description__c, Id, Policy_Number__c, LatestPolicyDocURL__c,Policy_Status__c, Policy_Term_Dates__c, Effective_Date__c, Expiration_Date__c, Description__c, Line_of_Business__c from Policy__c where Member__c = :userAccountId AND (Policy_Status__c IN : setSLPolicyStatusValuesName)])
			{
				
				
				String strDesc = (String.isEmpty(objPolicy.User_Description__c) ? objPolicy.Integration_Description__c : objPolicy.User_Description__c);
	
					lstActivePolicyWrapper.add(new policyWrapper( (objPolicy.Line_of_Business__c).trim().toLowerCase(),
																objPolicy.Policy_Number__c,
																strDesc, 
																objPolicy.Effective_Date__c,
																objPolicy.Expiration_Date__c,
																objPolicy.LatestPolicyDocURL__c,
																objPolicy.Id));
	
				
				if(objPolicy.IsIndividuallyBilled__c == true)
				lstBillingPolicyWrapper.add(new policyWrapper(strDesc, objPolicy.Total_Charges__c, objPolicy.Balance__c, objPolicy.Min_Due__c, objPolicy.Policy_Number__c,objPolicy.IsOverdue__c));	
				
				else
					isNotIndividuallyBilled = true;											
																
				I++;
			}
			
			for(AggregateResult objAggPolicy : [Select SUM(Balance__c), SUM(Total_Charges__c), SUM(Min_Due__c) from Policy__c where Member__c = :userAccountId AND (Policy_Status__c IN : setSLPolicyStatusValuesName) AND IsIndividuallyBilled__c =:false])
			{
				if(objAggPolicy.get('expr1') != null)
					primaryTotalCharges = Integer.valueOf(objAggPolicy.get('expr1'));
				if(objAggPolicy.get('expr2') != null)
					primaryMinDue = Integer.valueOf(objAggPolicy.get('expr2'));
				if(objAggPolicy.get('expr0') != null)
					primaryBalance = Integer.valueOf(objAggPolicy.get('expr0'));
			}
			
			
			list<Claim__c> lstClaimsToUpdate = new list<Claim__c>();
			
			// Get a list of claims for this member;
			for(Claim__c objClaim : [Select Id, Member__c, CanShowDetails__c, Line_of_Business__c, Policy__c, Date_of_Loss__c, Total_Paid__c, Loss_Location__c, Claim_Number__c, Claim_Status__c , IsNewActivity__c from Claim__c  where Claim_Status__c = 'In Progress' AND Member__c=:userAccountId order by createdDate DESC LIMIT 5])
			{
				
				
				lstOpenClaims.add(new claimsWrapper((objClaim.Line_of_Business__c).trim().toLowerCase(),
													objClaim.Claim_Number__c,
													objClaim.Total_Paid__c,
													objClaim.Loss_Location__c,
													objClaim.Date_of_Loss__c,
													objClaim.IsNewActivity__c,
													objClaim.CanShowDetails__c));
				objClaim.IsNewActivity__c = false;									
					lstClaimsToUpdate.add(objClaim);
			}
			
			if(lstClaimsToUpdate.size() > 0)
				update lstClaimsToUpdate;

			return null;
		}
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

	/* Inner class to store active policies related to loggedin member. */
	public class policyWrapper
	{
		public String policyType		{get;set;}
		public String policyNumber		{get;set;}
		public String policyDescription	{get;set;}
		public String policyPeriod		{get;set;}
		public Date policyEffectiveDate	{get;set;}
		public Date policyExpirationDate{get;set;}
		public String policyDownloadLink{get;set;}
		public String policyId			{get;set;}
		public boolean isOverDue        {get;set;}
		
		public Decimal policyTotalCharges	{get;set;}
		public Decimal policyBalance		{get;set;}
		public Decimal policyMinDue			{get;set;}
		
		/* Inner class parametric constructor */
		public 	policyWrapper(String policyType, String policyNumber, String policyDescription, Date policyEffectiveDate, Date policyExpirationDate, String policyDownloadLink, String policyId)
		{
			this.policyType = policyType;
			this.policyNumber = policyNumber;
			this.policyDescription = policyDescription;
			this.policyExpirationDate = policyExpirationDate;
			this.policyDownloadLink = policyDownloadLink;
			this.policyId = policyId;
			this.policyEffectiveDate = policyEffectiveDate;
		}
		
		public 	policyWrapper(String policyDescription, Decimal policyTotalCharges, Decimal policyBalance, Decimal policyMinDue, String policyNumber,Boolean isOverDue)
		{
			this.policyDescription = policyDescription;
			this.policyTotalCharges = policyTotalCharges;
			this.policyBalance = policyBalance;
			this.policyMinDue = policyMinDue;
			this.policyNumber = policyNumber;
			this.isOverDue = isOverDue;
		}
		
	}
	
	/*Inner Class to store all claims related to loggedin member . */
	public class claimsWrapper
	{
		public String 	policyType 		{get;set;}
		public String 	claimNumber   	{get;set;}
		public Decimal 	totalPaid		{get;set;}
		public String 	lossLocation	{get;set;}
		public Date   	dateOfLoss 		{get;set;}
		public Boolean 	isNewActivity	{get;set;} 
		public Boolean canShowDetails	{get;set;}
		
		/* Inner class  parametric constructor */
		public claimsWrapper(String policyType, String claimNumber, Decimal totalPaid, String lossLocation, Date dateOfLoss,Boolean isNewActivity, Boolean canShowDetails)
		{
			this.policyType = policyType;
			this.claimNumber = claimNumber;
			this.totalPaid = totalPaid;
			this.lossLocation = lossLocation;
			this.dateOfLoss = dateOfLoss;
			this.isNewActivity = isNewActivity;
			this.canShowDetails = canShowDetails;
		}
	}
}