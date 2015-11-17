/*
*  ClassName  	  : ProfileSettingPageController
*  JIRATicket     : PURE-8
*  CreatedOn      : 1/27/2013
*  ModifiedBy     : Sandeep
*  Description    : Controller which will get the all data related to profile setting page.  
*/
public without sharing class SL_ProfileSettingPageController 
{
	public Account objAccount						                        {get;set;}
	public list<Contact_Info__c>  lstMailingTypeContactInfo                 {get;set;}
	public list<Contact_Info__c>  lstBillingTypeContactInfo                 {get;set;}
	public list<Contact_Info__c>  lstEmailTypeContactInfo                   {get;set;}
	public list<Contact_Info__c>  lstPhoneTypeContactInfo                   {get;set;}
	public list<Contact_Info__c>  lstStandardEmailContactInfo               {get;set;}
	public list<Contact_Info__c>  lstEmailAndStndEmailContactInfo           {get;set;}
	public list<Contact_Info__c>  lstEmailTypeContInfoForSSA                {get;set;}
	public list<Contact_Info__c>  lstMailingTypeContInfoForSSA              {get;set;}
	
	
	private list<Contact_Info__c>  lstEmailTypeContInfoToDelete ;
    private list<Contact_Info__c>  lstMailingTypeContInfoToDelete ;
    private list<Contact_Info__c>  lstBillingTypeContInfoToDelete ;
    private list<Contact_Info__c>  lstPhoneTypeContInfoToDelete ;
	private map<string,Contact_Info__c> mapOfNewBillingTypeContInfo ;
	private map<string,Contact_Info__c> mapOfNewMailingTypeContInfo ;
	private map<string,Contact_Info__c> mapOfNewEmailTypeContInfo ;
	private map<string,Contact_Info__c> mapOfNewPhoneTypeContInfo ;
	private map<Id,Contact_Info__c> mapNonPrimaryContInfo ;
	private map<Id,Contact_Info__c> mapContactInfosToUpdate ;
	
	public String strNewlyCreatedContactInfoId                              {get;set;}
	public string strSelectedCommPreferences                                {get;set;}
	public string strUnSelectedCommPreferences                              {get;set;}
	public String PrimaryMailingAddrs 										{get;set;}
	public String PrimaryBillingAddrs 										{get;set;}
	public String strupdatedPassword										{get;set;}
	public string strOldPassword                                            {get;set;}
	
	public String strNewStreet 												{get;set;}
	public String strNewStreet1 											{get;set;}
	public String strNewCity 												{get;set;}
	public String strNewState 												{get;set;}
	public String strNewZipcode 											{get;set;}
	public String strNewEmail 												{get;set;}
	public String strNewPhone 												{get;set;}
	public String strConfirmNewEmail 										{get;set;}
	public String strAddresType 											{get;set;}
	public String contInfoId 												{get;set;}
	public string strPrimaryMailingAddId                                    {get;set;}
	public string strPrimaryBillingAddId                                    {get;set;}
	public string strPrimaryMailAddId                                       {get;set;}
	public string strPrimaryPhoneAddId                                      {get;set;}
	public string strAcctDeliverPreference                                  {get;set;}
	public string strSelectedDelvryPref                                     {get;set;}
	public string strMemberServicesUserEmail                                {get;set;}
	public string strPrimaryPhone                                           {get;set;}
	public string strPrimaryEmail                                           {get;set;}
	private Id idMemberServiceUser ;                                         
	private String userAccountId ;											
	private Id userId    ;    												
	private boolean isMailNeedToBeSend ;                                   
	public string strOrgnalPrimaryMailing ;                               
	private string strOrgnalPrimaryBilling                                  {get;set;}
	public string strOrgnalPrimaryEmail                                     {get;set;}
	private string strOrgnalPrimaryPhone ;
	private string strPrmaryAddrUpdationEmailBody;
	public string strDeletedEmailAddress						            {get;set;}
	public string strDeletedMailingAddress						            {get;set;}
	public string strDeletedBillingAddress						            {get;set;}
	public string strDeletedPhoneAddress						            {get;set;}
	private boolean isEMailToBeSendForContactInfoUpdates ;                    
	private string strMemberServicesName;
	public string isRegistered                                             {get;set;}
	
	public SL_ProfileSettingPageController()
	{
		initialize();
	}
	
	private void initialize()
	{
		strNewStreet = '';
		strNewStreet1 = '';
		strNewCity = '';
		strNewState = '';
		strNewZipcode = '';
		strNewEmail ='';
		strNewPhone='';
		strAddresType= '';
		strConfirmNewEmail = '';
		strPrimaryPhone = '';
		strPrimaryEmail = '';
		userAccountId = '';
		lstMailingTypeContactInfo = new list<Contact_Info__c>();
		lstBillingTypeContactInfo = new list<Contact_Info__c>();
		lstEmailTypeContactInfo = new list<Contact_Info__c>();
		lstPhoneTypeContactInfo = new list<Contact_Info__c>();
		lstEmailTypeContInfoToDelete = new list<Contact_Info__c>();
		lstMailingTypeContInfoToDelete = new list<Contact_Info__c>();
		lstBillingTypeContInfoToDelete = new list<Contact_Info__c>();
		lstPhoneTypeContInfoToDelete = new list<Contact_Info__c>();
		mapOfNewBillingTypeContInfo = new map<string,Contact_Info__c>();
		mapOfNewMailingTypeContInfo = new map<string,Contact_Info__c>();
		mapOfNewEmailTypeContInfo = new map<string,Contact_Info__c>();
		mapOfNewPhoneTypeContInfo = new map<string,Contact_Info__c>();
		mapNonPrimaryContInfo = new map<Id,Contact_Info__c>();
		lstStandardEmailContactInfo = new list<Contact_Info__c>();
		lstEmailAndStndEmailContactInfo = new list<Contact_Info__c>();
		lstMailingTypeContInfoForSSA = new list<Contact_Info__c>();
		lstEmailTypeContInfoForSSA = new list<Contact_Info__c>(); 
		
		strSelectedCommPreferences = ''; 
		strUnSelectedCommPreferences = '';
		mapContactInfosToUpdate = new map<Id,Contact_Info__c>();
		strDeletedEmailAddress = '';
		strDeletedMailingAddress = '';
		strDeletedBillingAddress = '';
		strDeletedPhoneAddress = '';
		strPrimaryMailingAddId = '';
		strPrimaryBillingAddId ='';
		strPrimaryMailAddId = '';
		strPrimaryPhoneAddId = '';
		strMemberServicesName ='';
		isMailNeedToBeSend = false;
		isEMailToBeSendForContactInfoUpdates = false;
	}
	
	/* */
	public Pagereference pageAction()
	{
		if(Userinfo.getUserType() == 'Guest') return new Pagereference('/LoginPage');//If logged in user type is 'Guest' then redirect to login page.
			
		String userRecordTypeId = '';//To store LoggedIn member record type.
		
		if(ApexPages.currentPage().getParameters().containsKey('isRegistered'))
		{
			isRegistered = ApexPages.currentPage().getParameters().get('isRegistered');
		}
		
		/* Added regarding PURE-63*/
		
		String strBrocker = ''; 
		String strContactId = '';
		Set<Id> setAgencyContactId = new Set<Id>();		
		String strProfileName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()].Name;
		
		/* This is to query member record type id.*/
		for(RecordType objRecordType : [Select Id, SobjectType, Name from RecordType where Name =:'Member' AND SobjectType =: 'Account' limit 1])
		{
			userRecordTypeId = objRecordType.Id;
		}
		
		/* If accessed from Agent home page */ 
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
				userId = objUser.Id; 
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
		else
		{
			/* This is to query logged in user account id.*/
			for(User objUser : [	Select Id, MemberCommunityPassword__c, User_s_Email__c,Contact.AccountId, Contact.Account.RecordTypeId,	Contact.Account.Member_Key_EDW__c,
									Contact.Account.Name from User where Id=: Userinfo.getUserId() AND
									Contact.Account.RecordTypeId =: userRecordTypeId limit 1
			 						
			 					])
			{
				userAccountId = objUser.Contact.AccountId;
				userId = objUser.Id;
			}
		}
				
		list<User> lstMemberServiceUser = [SELECT Id,Email,ContactId,FirstName FROM User WHERE IsActive = true AND Default_MemberService_User__c = true limit 1];
		if(!lstMemberServiceUser.isEmpty())
		{
			strMemberServicesName = lstMemberServiceUser[0].FirstName;
			strMemberServicesUserEmail = lstMemberServiceUser[0].Email;
			idMemberServiceUser = lstMemberServiceUser[0].Id;
		}	
		
		String strQuery = 'SELECT Id, RecordTypeId, Last_Payment_Received__c,Mailing_County__c, Member_Key_EDW__c, Name, Five_Year_Service_Date__c,IsOverdue__c,'
						+ 'SSA_Balance__c, Phone,Primary_Email__c , BillingPostalCode, Billing_Document_Delivery_Method__c, Total_Charges__c, Balance__c, Min_Due__c,'
						+ 'Last_Payment_Date__c, billingAddress__c, shippingAddress__c';
		
		List<Account> lstAccount = new List<Account>();
		
				
		String strMember = 'Member';
		
		if(!String.isEmpty(strBrocker) && strBrocker != '')
		{
			strQuery += ' FROM Account WHERE Id=' + '\'' + userAccountId +'\' AND ' + strBrocker + ' AND RecordType.Name =: strMember LIMIT 1';
			lstAccount = Database.query(strQuery);
			
			if(!lstAccount.isEmpty() && lstAccount != null)
				objAccount = lstAccount[0];	
			
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
				objAccount = lstAccount[0];
		}
				
 		if(objAccount != null )
 		{				
	 		PrimaryMailingAddrs = objAccount.shippingAddress__c;				
	 		PrimaryBillingAddrs = objAccount.billingAddress__c;	
	 		strPrimaryPhone = objAccount.Phone;
	 		strPrimaryEmail = objAccount.Primary_Email__c;
	 		
	 						
	 		if( objAccount.Billing_Document_Delivery_Method__c == 'Electronic' || objAccount.Billing_Document_Delivery_Method__c == 'Both' )
	 			strAcctDeliverPreference = 'Email';		
	 			
	 		if( objAccount.Billing_Document_Delivery_Method__c == 'Paper')			
	 			strAcctDeliverPreference = 'Standard Email'; 
 		  	
 	    	getContactInfosInformationForAccount();			
 		}		
        return null;
	}
	
	// Method used to Query all ContactInfos related to logged in Member 
	public void getContactInfosInformationForAccount()
	{
		set<string> setContInfoAddr = new set<string>(); // Set Used to avoid duplicate addresses
		
    	for(Contact_Info__c objContInfo : [	SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
												Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,	Receive_PURE_Prevention__c,
												Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
												Type__c,Zip__c,Zip_Old__c,Account__c,Was_Last_Primary__c
											   FROM Contact_Info__c 
											   WHERE Account__c =: userAccountId])
		{
				
			if( objContInfo.Type__c == 'Mailing')
		    {
		    	String strAddress = objContInfo.Street__c + ' ' + objContInfo.Street_2__c + ' ' + objContInfo.City__c + ' ' + objContInfo.State__c + ' ' + objContInfo.Zip__c;
		    	setContInfoAddr.add(strAddress);
		    	
		    	if(objContInfo.Is_Primary__c)
		    	{
					PrimaryMailingAddrs = (objContInfo.Street__c != null ? objContInfo.Street__c : '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + ' <br/> '+ (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c : '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c : '');
					strOrgnalPrimaryMailing = objContInfo.Id;
		    	}	
					
				lstMailingTypeContactInfo.add(objContInfo);	
				lstStandardEmailContactInfo.add(objContInfo);		
				lstEmailAndStndEmailContactInfo.add(objContInfo);	    
		    }
		    	
		    if( objContInfo.Type__c == 'Billing')
		    {
		    	if(objContInfo.Is_Primary__c)	
		    	{						 
					PrimaryBillingAddrs = (objContInfo.Street__c != null ? objContInfo.Street__c : '') + (objContInfo.Street_2__c != null ? ' ' + objContInfo.Street_2__c + ', ' : '') + ' <br/> '+ (objContInfo.City__c != null ? objContInfo.City__c + ', ' : '') + (objContInfo.State__c != null ? objContInfo.State__c : '') + ' ' + (objContInfo.Zip__c != null ? objContInfo.Zip__c : '');
					strOrgnalPrimaryBilling = objContInfo.Id;
		    	}	
				
		    	lstBillingTypeContactInfo.add(objContInfo);
		    }	
		    	
		    if( objContInfo.Type__c == 'Phone-Home' || objContInfo.Type__c == 'Phone-Work' || objContInfo.Type__c == 'Phone-Mobile')
		    {
		    	if(objContInfo.Is_Primary__c)
		    		strOrgnalPrimaryPhone = objContInfo.Id;
		    	
		    	lstPhoneTypeContactInfo.add(objContInfo);
		    }				
		}
		
		// Query used for sorting Emails By Primary in Situation room and Pure Prevention Section
		for(Contact_Info__c objContInfo : [	SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
												Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,	Receive_PURE_Prevention__c,
												Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
												Type__c,Zip__c,Zip_Old__c,Account__c,Was_Last_Primary__c
											   FROM Contact_Info__c 
											   WHERE Account__c =: userAccountId and Type__c = 'Email' order by Is_Primary__c DESC nulls last])
	   {
	   	
	   		if(objContInfo.Is_Primary__c)
	    	{
	    		strOrgnalPrimaryEmail = objContInfo.Id;
	    		strPrimaryEmail = objContInfo.Email__c;
	    		
	    	}	
		    	
	    	lstEmailTypeContactInfo.add(objContInfo);
	    	lstEmailAndStndEmailContactInfo.add(objContInfo);
	   }		
	   
	   // Query used to display im SSA section with SSA field as sorted
	   for(Contact_Info__c objContInfo : [	SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
												Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,	Receive_PURE_Prevention__c,
												Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
												Type__c,Zip__c,Zip_Old__c,Account__c,Was_Last_Primary__c
											   FROM Contact_Info__c 
											   WHERE Account__c =: userAccountId and (Type__c = 'Email' or Type__c = 'Mailing') order by Receive_SSA_Statements__c DESC nulls last])
	   {
	   	
	   		if(objContInfo.Type__c == 'Email')
	   		{
	   			lstEmailTypeContInfoForSSA.add(objContInfo);
	   		}
	   		
	   		if(objContInfo.Type__c == 'Mailing')
	   		{
	   			lstMailingTypeContInfoForSSA.add(objContInfo);
	   		}
	   }
	   								   
		
	   avoidDuplicateAddr(setContInfoAddr); 
	}
	
	
	// Method used to avoid displaying duplicate addresses when Mailing and Billing address are same for Member. We are displaying only Mailing Address when both Mailing and Billing address are same.
	private void avoidDuplicateAddr(set<string> setContInfoMailingAddr)
	{
		
    	for(Contact_Info__c objContInfo : [	SELECT Id,City__c,City_Old__c,Email__c,Email_Old__c,Is_Updated__c,Is_Primary__c,Phone__c,Phone_Old__c,Receive_Annual_Report__c,
												Receive_Company_Updates__c,Receive_Policy_Information__c,Receive_PURE_Events__c,Receive_PURE_Press__c,	Receive_PURE_Prevention__c,
												Receive_PURE_Situation_Room__c,Receive_SSA_Statements__c,State__c,State_Old__c,Street__c,Street_Old__c,Street_2__c,Street_2_Old__c,
												Type__c,Zip__c,Zip_Old__c,Account__c,Was_Last_Primary__c
											   FROM Contact_Info__c 
											   WHERE Account__c =: userAccountId and Type__c = 'Billing'])
		{
		
			String strAddress = objContInfo.Street__c + ' ' + objContInfo.Street_2__c + ' ' + objContInfo.City__c + ' ' + objContInfo.State__c + ' ' + objContInfo.Zip__c;
			
			if(!setContInfoMailingAddr.contains(strAddress))
			{
				lstStandardEmailContactInfo.add(objContInfo);
				lstEmailAndStndEmailContactInfo.add(objContInfo);
			}
		}
	}
	
	// Method used to add new Mailing,Billing,Email,Phone type ContactInfos when user adds any address through page.
	
	/* Start - Profile changes before save*/
	public void newAddresAdd()
	{
		try{
			   	if(!String.isBlank(contInfoId))
				{
					Contact_Info__c objContactInfo = new Contact_Info__c();
					
					if(strAddresType == 'Mailing')
					{
						if(mapOfNewMailingTypeContInfo.containsKey(contInfoId))
						{
							objContactInfo = mapOfNewMailingTypeContInfo.get(contInfoId);
							objContactInfo.Street__c = strNewStreet;
						 	objContactInfo.Street_2__c = strNewStreet1;
						 	objContactInfo.City__c = strNewCity;
						 	objContactInfo.State__c = strNewState;
						 	objContactInfo.Zip__c = strNewZipCode;
						 	objContactInfo.Is_Primary__c = false;
						 	mapOfNewMailingTypeContInfo.put(contInfoId,objContactInfo);
						}
						else
						{
							checkWithUpdatedContactInfo();	
						}
					}
					
					if(strAddresType == 'Billing')
					{
						if(mapOfNewBillingTypeContInfo.containsKey(contInfoId)) 
						{
							objContactInfo = mapOfNewBillingTypeContInfo.get(contInfoId);
							
							objContactInfo.Street__c = strNewStreet;
						 	objContactInfo.Street_2__c = strNewStreet1;
						 	objContactInfo.City__c = strNewCity;
						 	objContactInfo.State__c = strNewState;
						 	objContactInfo.Zip__c = strNewZipCode;
						 	objContactInfo.Is_Primary__c = false;
						 	mapOfNewBillingTypeContInfo.put(contInfoId,objContactInfo);
						 	
						}
						else
						{
							checkWithUpdatedContactInfo();	
						}
					}
					
					if(strAddresType == 'Email')
					{
						if(mapOfNewEmailTypeContInfo.containsKey(contInfoId))
						{
							objContactInfo = mapOfNewEmailTypeContInfo.get(contInfoId);
							objContactInfo.Email__c = strNewEmail;
							objContactInfo.Is_Primary__c = false;
							mapOfNewEmailTypeContInfo.put(contInfoId,objContactInfo);
						}
						else
						{
							objContactInfo = [ select Email__c,Email_Old__c,Type__c,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
												from Contact_Info__c
												where id=:contInfoId ];
												
							if(objContactInfo.Email__c != strNewEmail)	
							{
								objContactInfo.Email_Old__c = objContactInfo.Email__c;
								objContactInfo.Email__c = strNewEmail;
								objContactInfo.Is_Updated__c = true;
								mapNonPrimaryContInfo.put(objContactInfo.Id,objContactInfo);
							}	 					
						}	
					}
					
					if(strAddresType == 'Home' || strAddresType == 'Work' || strAddresType == 'Mobile')
					{
						if(mapOfNewPhoneTypeContInfo.containsKey(contInfoId))
						{
							objContactInfo = mapOfNewPhoneTypeContInfo.get(contInfoId);
							
							if( strAddresType == 'HOME')
								objContactInfo.Type__c = 'Phone-Home';
								
							if( strAddresType == 'Work')
								objContactInfo.Type__c = 'Phone-Work';
								
							if( strAddresType == 'Mobile')
								objContactInfo.Type__c = 'Phone-Mobile';		
							
							objContactInfo.Phone__c = strNewPhone;
							objContactInfo.Is_Primary__c = false;
							mapOfNewPhoneTypeContInfo.put(contInfoId,objContactInfo);
						}
						
						else
						{
							objContactInfo = [ select Phone__c,Phone_Old__c,Type__c,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
												from Contact_Info__c
												where id=:contInfoId ];
												
						    if(objContactInfo.Phone__c != strNewPhone)	
						    {
						    	 objContactInfo.Phone_Old__c = objContactInfo.Phone__c;
						    	 objContactInfo.Phone__c = strNewPhone;
						    }	
						    
						    if(strAddresType == 'Home')
						    {
							    if(objContactInfo.Type__c != 'Phone-Home') 
							    	objContactInfo.Type__c = 'Phone-Home';
						    }
						    
						    if(strAddresType == 'Work')
						    {
							    if(objContactInfo.Type__c != 'Phone-Work') 
							    	objContactInfo.Type__c = 'Phone-Work';
						    }
						    
						    if(strAddresType == 'Mobile')
						    {
							    if(objContactInfo.Type__c != 'Phone-Mobile') 
							    	objContactInfo.Type__c = 'Phone-Mobile';
						    }
						    
						    objContactInfo.Is_Updated__c = true;
						    mapNonPrimaryContInfo.put(objContactInfo.Id,objContactInfo);
						    
					     }    
				     }
				     contInfoId = null;
				}
				else
				{
					 Contact_Info__c objContInfoNewAddr = new Contact_Info__c();
					 if(strAddresType == 'Billing' || strAddresType == 'Mailing')
					 {
						 objContInfoNewAddr.Street__c = strNewStreet;
						 objContInfoNewAddr.Street_2__c = strNewStreet1;
						 objContInfoNewAddr.City__c = strNewCity;
						 objContInfoNewAddr.State__c = strNewState;
						 objContInfoNewAddr.Zip__c = strNewZipCode;
						 objContInfoNewAddr.Type__c = strAddresType; 
						 objContInfoNewAddr.Account__c = userAccountId;
						 
						 if(strAddresType == 'Billing')
						 	mapOfNewBillingTypeContInfo.put(strNewlyCreatedContactInfoId,objContInfoNewAddr);
						 	
						 if(strAddresType == 'Mailing')
						 	mapOfNewMailingTypeContInfo.put(strNewlyCreatedContactInfoId,objContInfoNewAddr);
					 }
					 
					 else if(strAddresType == 'Email')
					 {
					 	objContInfoNewAddr.Email__c = strNewEmail;
					 	objContInfoNewAddr.Type__c = strAddresType;
					 	objContInfoNewAddr.Account__c = userAccountId;
					 	mapOfNewEmailTypeContInfo.put(strNewlyCreatedContactInfoId,objContInfoNewAddr);
					 }
					 
					 else if(strAddresType == 'Home' || strAddresType == 'Work' || strAddresType == 'Mobile')
					 {
					 	objContInfoNewAddr.Phone__c = strNewPhone;
					 	
					 	if(strAddresType == 'Home')
				 			objContInfoNewAddr.Type__c = 'Phone-Home';
					 		
					 	else if(strAddresType == 'Work')	
					 		objContInfoNewAddr.Type__c = 'Phone-Work';
					 		
					 	else if(strAddresType == 'Mobile')
					 		objContInfoNewAddr.Type__c = 'Phone-Mobile';	
					 		
					    objContInfoNewAddr.Account__c = userAccountId;
					    mapOfNewPhoneTypeContInfo.put(strNewlyCreatedContactInfoId,objContInfoNewAddr);
					 
					 }
				}
				
		}
		catch(Exception ee)
		{
		}														 
	}
	
	
	// Method used to check Updated contactInfos and check if any field is updated then moving the oldvalues to oldfields and new values to newfields and making IsUpdated flag to true.
	private void checkWithUpdatedContactInfo()
	{
		Contact_Info__c objUpdatedContactInfo = new Contact_Info__c();
		
		Boolean isAnyFieldUpdated = false;
		
		objUpdatedContactInfo = [select Street__c,Street_2__c,City__c,State__c,Zip__c,Street_Old__c,Street_2_Old__c,City_Old__c,State_Old__c,Zip_Old__c,Type__c,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
											  from Contact_Info__c
											  where id=:contInfoId ];
											  
		if( objUpdatedContactInfo.Street__c != strNewStreet)
		{	
			objUpdatedContactInfo.Street_Old__c = objUpdatedContactInfo.Street__c;
			objUpdatedContactInfo.Street__c = strNewStreet;
			isAnyFieldUpdated = true;
		}
		
		if( objUpdatedContactInfo.Street_2__c != strNewStreet1)
		{	
			objUpdatedContactInfo.Street_2_Old__c = objUpdatedContactInfo.Street_2__c;
			objUpdatedContactInfo.Street_2__c = strNewStreet1;
			isAnyFieldUpdated = true;
		}
		
		if( objUpdatedContactInfo.City__c != strNewCity)
		{	
			objUpdatedContactInfo.City_Old__c = objUpdatedContactInfo.City__c;
			objUpdatedContactInfo.City__c = strNewCity;
			isAnyFieldUpdated = true;
		}
		
		if( objUpdatedContactInfo.State__c != strNewState)
		{	
			objUpdatedContactInfo.State_Old__c = objUpdatedContactInfo.State__c;
			objUpdatedContactInfo.State__c = strNewState;
			isAnyFieldUpdated = true;
		}
		
		if( objUpdatedContactInfo.Zip__c != strNewZipCode)
		{	
			objUpdatedContactInfo.Zip_Old__c = objUpdatedContactInfo.Zip__c;
			objUpdatedContactInfo.Zip__c = strNewZipCode;
			isAnyFieldUpdated = true;
		}
		
        if(isAnyFieldUpdated)
        {		
		    objUpdatedContactInfo.Is_Updated__c = true;	
			mapNonPrimaryContInfo.put(objUpdatedContactInfo.Id,objUpdatedContactInfo);
        }	 
        
							
	}
	/* End - Profile changes before save*/
	
	
	// Method called onclick of savechanges in MemberInformation section to Savechanges to database whatever user has updated and sending an email with old values and new values.
	/* Start - Profile changes save */
	public PageReference profileSaveChanges()
	{
	    try{
				Database.upsert(mapNonPrimaryContInfo.values(),false);    
				
				updatedContactInfoWithIsPrimary();
				
				Database.insert(mapOfNewBillingTypeContInfo.values(),false);
				Database.insert(mapOfNewMailingTypeContInfo.values(),false);
				Database.insert(mapOfNewEmailTypeContInfo.values(),false);
				Database.insert(mapOfNewPhoneTypeContInfo.values(),false);
				Database.delete(lstEmailTypeContInfoToDelete,false);
				Database.delete(lstMailingTypeContInfoToDelete,false);
				Database.delete(lstBillingTypeContInfoToDelete,false);
				Database.delete(lstPhoneTypeContInfoToDelete,false);
										  
				Boolean isEmailNeedstoSendToUSer = false;						  
				
				/*if( strPrimaryMailingAddId != strOrgnalPrimaryMailing || strPrimaryBillingAddId != strOrgnalPrimaryBilling || strPrimaryMailAddId != strOrgnalPrimaryEmail || strPrimaryPhoneAddId != strOrgnalPrimaryPhone)
				{
					isEmailNeedstoSendToUSer = true;
					EmailTemplate emailTemplate =   [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'ProfileSettingPrimaryAddressUpdation'];
				                                            
					if(emailTemplate != null)
					{
				        String htmlBody = emailTemplate.HtmlValue;
				        String plainBody = emailTemplate.Body ;
				        String strDeliveryPreference = emailHTMLBody();
						Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
					    mail.setTargetObjectId(idMemberServiceUser);   
					    //mail.setSubject('PURE Member Portal – Request to change profile information');  
				 	    mail.setSaveAsActivity(false);
				 	    if(!string.isBlank(strDeliveryPreference))
				 	    {
				 	    	mail.setPlainTextBody(plainBody.replace('PRIMARY_ADDRESS_TEXT_PLACEHOLDER', strDeliveryPreference));
				 	    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				 	    }	
					}
				} */
				
				if(!mapNonPrimaryContInfo.isEmpty() || isEMailToBeSendForContactInfoUpdates)
				{
					isEmailNeedstoSendToUSer = true;
					//Sending email to default member service User with Updated Contact Infos Information
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
			 		mail.setTemplateId([Select id From EmailTemplate Where DeveloperName  = 'Profile_Settings_Contact_Information' limit 1].Id);
			 		mail.setTargetObjectId(idMemberServiceUser);    
			 		mail.setSaveAsActivity(false);
			 		mail.setWhatId(userAccountId);
			 		
			 	    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
										     
			 	    list<Contact_Info__c> lstContactInfoToUpdateisupdateFlag =  new list<Contact_Info__c>();
			 	    
			 	    for(Contact_Info__c objUpdatedcontInfo : [select Is_Updated__c,Account__c
			 	    										  from Contact_Info__c
			 	    										  where Account__c =:objAccount.Id and (Is_Updated__c = true or Is_Primary_Changed__c = true)])
			 	    {
		 	    		objUpdatedcontInfo.Is_Updated__c = false;		
		 	    		objUpdatedcontInfo.Is_Primary_Changed__c = false;
		 	    		lstContactInfoToUpdateisupdateFlag.add(objUpdatedcontInfo); 	    		
			 	    }
			 	    
			 	    Database.upsert(lstContactInfoToUpdateisupdateFlag,false);
				}
				
				if(isEmailNeedstoSendToUSer)
				{
					 //Sending email to logged in user. 
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email.setTemplateId([select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Portal_Profile_Settings_Update_Contact_Info'].Id);
		 		    email.setTargetObjectId(UserInfo.getUserId());            //UserInfo.getUserId()
		 		    email.setSenderDisplayName('PURE Insurance');
		 		    email.setSaveAsActivity(false);
		 		    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
					
				}
				
				if(!String.isBlank(strupdatedPassword))
				{
					return site.changePassword(strupdatedPassword, strupdatedPassword,strOldPassword);
				}
		   }
		   
		   catch(Exception ee)
		   {
		   }
		   
		   PageReference pr = new PageReference('/ProfileSettingPage');
 	       pr.setRedirect(true);
           return pr;
	}
	
	// Method used to update IsPrimary and WasLastPrimary fields for all contactInfos when user changes their Primary Address.
	public void updatedContactInfoWithIsPrimary()
	{
		list<Contact_Info__c> lstContactInfo = new list<Contact_Info__c>();
		list<Contact_Info__c> lstPrimaryContInfo = new list<Contact_Info__c>();
		Contact_Info__c objPrimaryMailingContInfo;
		Contact_Info__c objPrimaryBillingContInfo;
		Contact_Info__c objPrimaryEmailContInfo;
		Contact_Info__c objPrimaryPhoneContInfo;
		
		if(!string.isBlank(strPrimaryMailingAddId))
		{
	 		if(mapOfNewMailingTypeContInfo.containsKey(strPrimaryMailingAddId))	
		 	{
	 			Contact_Info__c objContactInfo = mapOfNewMailingTypeContInfo.get(strPrimaryMailingAddId);
		 		objContactInfo.Is_Primary__c = true;
		 		
		 		if( strOrgnalPrimaryMailing != strPrimaryMailingAddId)
		 			objContactInfo.Is_Primary_Changed__c = true;
		 			
		 		isEMailToBeSendForContactInfoUpdates = true;
		 		objContactInfo.Was_Last_Primary__c = false;
		 		
		 		mapOfNewMailingTypeContInfo.put(strPrimaryMailingAddId,objContactInfo);
		 		
		 		list<Contact_Info__c> lstcontactInfo1 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 										                 from Contact_Info__c
 										                 where Account__c =:objAccount.Id and Type__c = 'Mailing' and Is_Primary__c = true];
 										                 
	 							             
	 			for( Contact_Info__c objContactInfo1 : lstcontactInfo1)
	 			{
	 				objcontactInfo1.Is_Primary__c = false;
	 				
	 				if( strOrgnalPrimaryMailing != strPrimaryMailingAddId)
	 				{
	 					objcontactInfo1.Is_Primary_Changed__c = true;
	 					objContactInfo1.Was_Last_Primary__c = true;
	 					isEMailToBeSendForContactInfoUpdates = true;
	 				}		
	 				lstPrimaryContInfo.add(objContactInfo1);
	 			}
	 			
	 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
			    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
 										     	     		    from Contact_Info__c
 										             		    where Account__c =:objAccount.Id and Type__c = 'Mailing'];
 										             
 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
 			    {
 					objContInfo.Was_Last_Primary__c = false;
 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
 			    }	
 			
 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
	 			
			 }	
				 	
		 	else
		 	{
		 		boolean isPrimary = false;
		 		for(Contact_Info__c objContactInfo : mapNonPrimaryContInfo.values())
		 		{
		 			if( objContactInfo.Type__c == 'Mailing')
		 			{
			 			if(objContactInfo.Id == strPrimaryMailingAddId)
			 			{
			 				objContactInfo.Is_Primary__c = true;
			 				
			 				if( strOrgnalPrimaryMailing != strPrimaryMailingAddId)
			 					objContactInfo.Is_Primary_Changed__c = true;
			 					
			 				isEMailToBeSendForContactInfoUpdates = true;
			 				objContactInfo.Was_Last_Primary__c = false;
			 				isPrimary = true;
			 			}	
			 				
			 			else 
			 			{
			 				objContactInfo.Is_Primary__c = false;
			 				objContactInfo.Was_Last_Primary__c = false;
			 			}	
			 				
			 			lstContactInfo.add(objContactInfo);
		 			}		
		 		}
		 		
		 		if(mapNonPrimaryContInfo.isEmpty() || isPrimary)
		 		{
		 			
		 			list<Contact_Info__c> lstcontactInfo1 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 										                     from Contact_Info__c
 										                     where Account__c =:objAccount.Id and Type__c = 'Mailing' and Is_Primary__c = true];
 					
 					for( Contact_Info__c objContactInfo2 : lstcontactInfo1)
		 			{
	 					objContactInfo2.Is_Primary__c = false;
	 					
	 					if( strOrgnalPrimaryMailing != strPrimaryMailingAddId)
	 					{
	 						objContactInfo2.Is_Primary_Changed__c = true;
	 						objContactInfo2.Was_Last_Primary__c = true;
	 						isEMailToBeSendForContactInfoUpdates = true;
	 					}
		 				lstPrimaryContInfo.add(objContactInfo2);	
		 			}
		 			
		 		    list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
				    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
	 										     	     		    from Contact_Info__c
	 										             		    where Account__c =:objAccount.Id and Type__c = 'Mailing'];
	 										             
	 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
	 			    {
	 					objContInfo.Was_Last_Primary__c = false;
	 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
	 			    }	
	 			
	 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
		 			
		 		    objPrimaryMailingContInfo = [ select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
	 											  from Contact_Info__c
	 											  where id=:strPrimaryMailingAddId];
	 														  
	 		    	objPrimaryMailingContInfo.Is_Primary__c = true;
	 		    	
	 		    	if( strOrgnalPrimaryMailing != strPrimaryMailingAddId)
	 		    	{
	 		    		objPrimaryMailingContInfo.Is_Primary_Changed__c = true;
	 		    		isEMailToBeSendForContactInfoUpdates = true;
		 		   		objPrimaryMailingContInfo.Was_Last_Primary__c = false;
	 		    	}	
		 		}
		 	}	
		 }
		 
		if(!string.isBlank(strPrimaryBillingAddId))
		{
	 		if(mapOfNewBillingTypeContInfo.containsKey(strPrimaryBillingAddId))	
		 	{
	 			Contact_Info__c objContactInfo = mapOfNewBillingTypeContInfo.get(strPrimaryBillingAddId);
		 		objContactInfo.Is_Primary__c = true;
		 		isEMailToBeSendForContactInfoUpdates = true;
		 		
		 		if(strOrgnalPrimaryBilling != strPrimaryBillingAddId)
		 			objContactInfo.Is_Primary_Changed__c = true;
		 			
		 		objContactInfo.Was_Last_Primary__c = false;
		 		
		 		mapOfNewBillingTypeContInfo.put(strPrimaryBillingAddId,objContactInfo);
		 		
		 		list<Contact_Info__c> lstcontactInfo2 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
	 										     	    from Contact_Info__c
	 										            where Account__c =:objAccount.Id and Type__c = 'Billing' and Is_Primary__c = true ];
	 		  								            
	 			for( Contact_Info__c objcontactInfo2 : lstcontactInfo2)
	 			{
	 				objcontactInfo2.Is_Primary__c = false;
	 				
	 				if(strOrgnalPrimaryBilling != strPrimaryBillingAddId)
	 				{
	 				    objcontactInfo2.Is_Primary_Changed__c = true;
	 					objcontactInfo2.Was_Last_Primary__c = true;
	 					isEMailToBeSendForContactInfoUpdates = true;
	 				}
	 					
	 		   	    lstPrimaryContInfo.add(objContactInfo2);		
	 			}   
	 			
	 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
			    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
 										     	     		    from Contact_Info__c
 										             		    where Account__c =:objAccount.Id and Type__c = 'Billing'];
 										             
 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
 			    {
 					objContInfo.Was_Last_Primary__c = false;
 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
 			    }	
 			
 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false); 	
		 	}	
				 	
		 	else
		 	{
		 		boolean isPrimary = false;
		 		for(Contact_Info__c objContactInfo : mapNonPrimaryContInfo.values())
		 		{
		 			if( objContactInfo.Type__c == 'Billing')
		 			{
			 			if(objContactInfo.Id == strPrimaryBillingAddId)
			 			{
			 				objContactInfo.Is_Primary__c = true;
			 				
			 				if(strOrgnalPrimaryBilling != strPrimaryBillingAddId)
			 				{
			 					objContactInfo.Is_Primary_Changed__c = true;
			 					isEMailToBeSendForContactInfoUpdates = true;
			 					objContactInfo.Was_Last_Primary__c = false;
			 				}	
			 				isPrimary = true;
			 			}	
			 				
			 			else 
			 			{
			 				objContactInfo.Is_Primary__c = false;
			 				objContactInfo.Was_Last_Primary__c = false;	
			 			}	
			 			
			 			lstContactInfo.add(objContactInfo);
		 			}		
		 		}
		 		
		 		if(mapNonPrimaryContInfo.isEmpty() || isPrimary)
		 		{
		 			list<Contact_Info__c> lstcontactInfo2 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
	 										     	         from Contact_Info__c
	 										                 where Account__c =:objAccount.Id and Type__c = 'Billing' and Is_Primary__c = true ];
	 										            
		 			for( Contact_Info__c objcontactInfo : lstcontactInfo2)
		 			{
		 				objcontactInfo.Is_Primary__c = false;
		 				
		 				if(strOrgnalPrimaryBilling != strPrimaryBillingAddId)
		 				{
		 					objcontactInfo.Is_Primary_Changed__c = true;
		 					objcontactInfo.Was_Last_Primary__c = true;
		 					isEMailToBeSendForContactInfoUpdates = true;
		 				}
		 					
		 		   	    lstPrimaryContInfo.add(objContactInfo);		
		 			}   
		 			
		 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
				    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
	 										     	     		    from Contact_Info__c
	 										             		    where Account__c =:objAccount.Id and Type__c = 'Billing'];
	 										             
	 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
	 			    {
	 					objContInfo.Was_Last_Primary__c = false;
	 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
	 			    }	
	 			
	 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
	 			    
	 			    objPrimaryBillingContInfo = [ select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
	 											  from Contact_Info__c
	 											  where id=:strPrimaryBillingAddId];
	 														  
	 		        objPrimaryBillingContInfo.Is_Primary__c = true;
	 		        
	 		        if(strOrgnalPrimaryBilling != strPrimaryBillingAddId)
	 		        {
	 		        	objPrimaryBillingContInfo.Is_Primary_Changed__c = true;
	 		        	isEMailToBeSendForContactInfoUpdates = true;
	 		        	objPrimaryBillingContInfo.Was_Last_Primary__c = false;
	 		        }	
		 		}
		 	}	
		 }
		 
		 if(!string.isBlank(strPrimaryMailAddId))
		 {
	 		if(mapOfNewEmailTypeContInfo.containsKey(strPrimaryMailAddId))	
		 	{
	 			Contact_Info__c objContactInfo = mapOfNewEmailTypeContInfo.get(strPrimaryMailAddId);
		 		objContactInfo.Is_Primary__c = true;
		 		
		 		if(strOrgnalPrimaryEmail != strPrimaryMailAddId)
		 			objContactInfo.Is_Primary_Changed__c = true;
		 			
		 		isEMailToBeSendForContactInfoUpdates = true;
		 		objContactInfo.Was_Last_Primary__c = false;
		 		
		 		mapOfNewEmailTypeContInfo.put(strPrimaryMailAddId,objContactInfo);
		 		list<Contact_Info__c> lstcontactInfo3 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 										      		     from Contact_Info__c
 										      		     where Account__c =:objAccount.Id and Type__c = 'Email' and Is_Primary__c = true];
 										      
	 			for( Contact_Info__c objcontactInfo3 : lstcontactInfo3)
	 			{
	 				objcontactInfo3.Is_Primary__c = false;
	 				
	 				if(strOrgnalPrimaryEmail != strPrimaryMailAddId)
	 				{
	 					objcontactInfo3.Is_Primary_Changed__c = true;
	 					objcontactInfo3.Was_Last_Primary__c = true;
	 					isEMailToBeSendForContactInfoUpdates = true;
	 				}
	 				
	 				lstPrimaryContInfo.add(objcontactInfo3);
	 			}
	 			
	 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
				list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
	 										     	     		    from Contact_Info__c
	 										             		    where Account__c =:objAccount.Id and Type__c = 'Email'];
	 										             
 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
 			    {
 					objContInfo.Was_Last_Primary__c = false;
 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
 			    }	
 			
 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
	 			    	
		 	}	
				 	
		 	else
		 	{
		 		boolean isPrimary = false;
		 		for(Contact_Info__c objContactInfo : mapNonPrimaryContInfo.values())
		 		{
		 			if( objContactInfo.Type__c == 'Email')
		 			{
			 			if(objContactInfo.Id == strPrimaryMailAddId)
			 			{
			 				objContactInfo.Is_Primary__c = true;
			 				
			 				if(strOrgnalPrimaryEmail != strPrimaryMailAddId)
			 				{
			 					objContactInfo.Is_Primary_Changed__c = true;
			 					isEMailToBeSendForContactInfoUpdates = true;
			 					objContactInfo.Was_Last_Primary__c = false;
			 				}	
			 				isPrimary = true;
			 			}	
			 				
			 			else 
		 			    {
			 				objContactInfo.Is_Primary__c = false;
			 				objContactInfo.Was_Last_Primary__c = false;
		 			    }	
			 				
			 			lstContactInfo.add(objContactInfo);	
		 			}		
		 		}
		 		
		 		if(mapNonPrimaryContInfo.isEmpty() || isPrimary)
		 		{
		 			list<Contact_Info__c> lstcontactInfo3 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 										      		         from Contact_Info__c
 										      		         where Account__c =:objAccount.Id and Type__c = 'Email' and Is_Primary__c = true];
 										      
		 			for( Contact_Info__c objcontactInfo : lstcontactInfo3)
		 			{
		 				objcontactInfo.Is_Primary__c = false;
		 				
		 				if(strOrgnalPrimaryEmail != strPrimaryMailAddId)
		 				{
		 					objcontactInfo.Is_Primary_Changed__c = true;
		 					objcontactInfo.Was_Last_Primary__c = true;
		 					isEMailToBeSendForContactInfoUpdates = true;
		 				}	
		 				lstPrimaryContInfo.add(objContactInfo);
		 			}
		 			
		 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
				    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
	 										     	     		    from Contact_Info__c
	 										             		    where Account__c =:objAccount.Id and Type__c = 'Email'];
	 										             
	 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
	 			    {
	 					objContInfo.Was_Last_Primary__c = false;
	 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
	 			    }	
	 			
	 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
	 			    
		 			objPrimaryEmailContInfo = [ select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
	 										    from Contact_Info__c
	 										    where id=:strPrimaryMailAddId];
	 														  
		 		    objPrimaryEmailContInfo.Is_Primary__c = true;
		 		    
		 		    if(strOrgnalPrimaryEmail != strPrimaryMailAddId)
		 		    {
		 		    	objPrimaryEmailContInfo.Is_Primary_Changed__c = true;
		 		    	isEMailToBeSendForContactInfoUpdates = true;
		 		    	objPrimaryEmailContInfo.Was_Last_Primary__c = false;
		 		    }	
		 		}
		 	}		
		 }
		 
		 if(!string.isBlank(strPrimaryPhoneAddId))
		 {
	 		if(mapOfNewPhoneTypeContInfo.containsKey(strPrimaryPhoneAddId))	
		 	{
	 			Contact_Info__c objContactInfo = mapOfNewPhoneTypeContInfo.get(strPrimaryPhoneAddId);
		 		objContactInfo.Is_Primary__c = true;
		 		
		 		if(strOrgnalPrimaryPhone != strPrimaryPhoneAddId)
		 			objContactInfo.Is_Primary_Changed__c = true;
		 			
		 		isEMailToBeSendForContactInfoUpdates = true;
		 		objContactInfo.Was_Last_Primary__c = false;
		 		mapOfNewPhoneTypeContInfo.put(strPrimaryPhoneAddId,objContactInfo);
		 		
		 		list<Contact_Info__c> lstcontactInfo4 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 										                 from Contact_Info__c
 										                 where Account__c =:objAccount.Id and (Type__c = 'Phone-Home' or Type__c = 'Phone-Work' or Type__c = 'Phone-Mobile' ) and Is_Primary__c = true];
 										      
	 			for( Contact_Info__c objcontactInfo4 : lstcontactInfo4)
	 			{
	 				objcontactInfo4.Is_Primary__c = false;
	 				
	 				if(strOrgnalPrimaryPhone != strPrimaryPhoneAddId)
	 				{
	 					objcontactInfo4.Is_Primary_Changed__c = true;
	 					objcontactInfo4.Was_Last_Primary__c = true;
	 					isEMailToBeSendForContactInfoUpdates = true;
	 				}	
 		   			lstPrimaryContInfo.add(objcontactInfo4);
 		   			
	 			}		
	 			
	 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
			    list<Contact_Info__c> lstMailingTypeContInfo = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
 										     	     		    from Contact_Info__c
 										             		    where Account__c =:objAccount.Id and  (Type__c = 'Phone-Home' or Type__c = 'Phone-Work' or Type__c = 'Phone-Mobile' )];
 										             
 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
 			    {
 					objContInfo.Was_Last_Primary__c = false;
 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
 			    }	
 			
 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
		 	}	
				 	
		 	else
		 	{
		 		boolean isPrimary = false;
		 		for(Contact_Info__c objContactInfo : mapNonPrimaryContInfo.values())
		 		{
		 			if(objContactInfo.Type__c == 'Phone-Home' || objContactInfo.Type__c == 'Phone-Work' || objContactInfo.Type__c == 'Phone-Mobile')
		 			{
			 			if(objContactInfo.Id == strPrimaryPhoneAddId)
			 			{
			 				objContactInfo.Is_Primary__c = true;
			 				
			 				if(strOrgnalPrimaryPhone != strPrimaryPhoneAddId)
			 				{
			 					objContactInfo.Is_Primary_Changed__c = true;
				 				isEMailToBeSendForContactInfoUpdates = true;
				 				objContactInfo.Was_Last_Primary__c = false;
			 				}
			 					
			 				isPrimary = true;
			 			}	
			 			
			 			else 
			 			{
			 				objContactInfo.Is_Primary__c = false;
			 				objContactInfo.Was_Last_Primary__c = false;
			 			}	
			 				
			 		    lstContactInfo.add(objContactInfo);		
		 			}		
		 		}
		 		
		 		if(mapNonPrimaryContInfo.isEmpty() || isPrimary || Test.isRunningTest())
		 		{
		 			list<Contact_Info__c> lstcontactInfo4 = new list<Contact_Info__c>();
		 			
		 			
		 			lstcontactInfo4 = [select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
 									   from Contact_Info__c
		 						       where Account__c =:objAccount.Id and (Type__c = 'Phone-Home' or Type__c = 'Phone-Work' or Type__c = 'Phone-Mobile' ) and Is_Primary__c = true];
	 										      
		 			for( Contact_Info__c objcontactInfo : lstcontactInfo4)
		 			{
		 				objcontactInfo.Is_Primary__c = false;
		 				
		 				if(strOrgnalPrimaryPhone != strPrimaryPhoneAddId)
		 				{
		 					objcontactInfo.Is_Primary_Changed__c = true;
			 				objcontactInfo.Was_Last_Primary__c = true;
			 				isEMailToBeSendForContactInfoUpdates = true;
		 				}	
		 		   		lstPrimaryContInfo.add(objContactInfo);
		 			}		
		 			
		 			list<Contact_Info__c> lstContInfosToUpdateWasLastPrimary = new list<Contact_Info__c>();
				
				    list<Contact_Info__c> lstMailingTypeContInfo = new list<Contact_Info__c>();
				    
				    lstMailingTypeContInfo  = [select Name,Is_Primary__c, Was_Last_Primary__c,Is_Updated__c
	 										   from Contact_Info__c
	 										   where Account__c =:objAccount.Id and  (Type__c = 'Phone-Home' or Type__c = 'Phone-Work' or Type__c = 'Phone-Mobile' )];
	 										             
	 			    for(Contact_Info__c objContInfo : lstMailingTypeContInfo)
	 			    {
	 					objContInfo.Was_Last_Primary__c = false;
	 				 	lstContInfosToUpdateWasLastPrimary.add(objContInfo);
	 			    }	
	 			
	 			    Database.upsert(lstContInfosToUpdateWasLastPrimary,false);
	 			
		 			objPrimaryPhoneContInfo = [ select Name,Is_Primary__c,Was_Last_Primary__c,Is_Updated__c
		 										from Contact_Info__c
		 										where id=:strPrimaryPhoneAddId];
		 														  
	 		        objPrimaryPhoneContInfo.Is_Primary__c = true;
	 		        
	 		        if(strOrgnalPrimaryPhone != strPrimaryPhoneAddId)
	 		        {
	 		        	objPrimaryPhoneContInfo.Is_Primary_Changed__c = true;
		 		        isEMailToBeSendForContactInfoUpdates = true;
		 		        objPrimaryPhoneContInfo.Was_Last_Primary__c = false;
	 		        }    
		 		}
		 	 }
		 }
		 
		 Database.upsert(lstPrimaryContInfo,false);
		 Database.upsert(lstContactInfo,false);
		 
		 if(!string.isBlank(strPrimaryMailingAddId))
		 {
		 	if(objPrimaryMailingContInfo != null)
		 		update objPrimaryMailingContInfo;
		 }
		 if(!string.isBlank(strPrimaryBillingAddId))
		 {
		 	if(objPrimaryBillingContInfo != null)
		 		update objPrimaryBillingContInfo;
		 }
		 
		 if(!string.isBlank(strPrimaryMailAddId))
		 {
		 	if(objPrimaryEmailContInfo != null)
		 		update objPrimaryEmailContInfo;
		 }
		 
		 if(!string.isBlank(strPrimaryPhoneAddId))
		 {
		 	if(objPrimaryPhoneContInfo != null)
		 		update objPrimaryPhoneContInfo;
		 }
	}
	
	
	// Method used to delete Email type ContactInfo records
	public void deleteEmailAddress()
	{
		if(!string.isBlank(strDeletedEmailAddress))
		{
			strDeletedEmailAddress = strDeletedEmailAddress.trim();
			string contInfoEmailId = strDeletedEmailAddress.substring(strDeletedEmailAddress.indexOf('_') + 1);
			contInfoEmailId = contInfoEmailId.trim();
			
			if(mapOfNewEmailTypeContInfo.containsKey(contInfoEmailId))
			{
				mapOfNewEmailTypeContInfo.remove(contInfoEmailId);
			}	
			
			else
			{
				Id contInfoId = Id.valueOf(contInfoEmailId);
				if(mapNonPrimaryContInfo.containsKey(contInfoId))
					mapNonPrimaryContInfo.remove(contInfoId);
					
				Contact_Info__c objDeletedContactInfo = new Contact_Info__c(Id = contInfoId);
				lstEmailTypeContInfoToDelete.add(objDeletedContactInfo);
			}
		}
	} 
	
	// Method used to delete Mailing type ContactInfo records
	public void deleteMailingAddress()
	{
		if(!string.isBlank(strDeletedMailingAddress))
		{
			strDeletedMailingAddress = strDeletedMailingAddress.trim();
			string contInfoMailingId = strDeletedMailingAddress.substring(strDeletedMailingAddress.indexOf('_') + 1);
			contInfoMailingId = contInfoMailingId.trim();
			
			if(mapOfNewMailingTypeContInfo.containsKey(contInfoMailingId))
			{
				mapOfNewMailingTypeContInfo.remove(contInfoMailingId);
			}	
			
			else
			{
				Id contInfoId = Id.valueOf(contInfoMailingId);
				if(mapNonPrimaryContInfo.containsKey(contInfoId))
					mapNonPrimaryContInfo.remove(contInfoId);
					
				Contact_Info__c objDeletedContactInfo = new Contact_Info__c(Id = contInfoId);
				lstMailingTypeContInfoToDelete.add(objDeletedContactInfo);
			}
		}
	}
	
	// Method used to delete Billing type ContactInfo records
	public void deleteBillingAddress()
	{
		if(!string.isBlank(strDeletedBillingAddress))
		{
	 		strDeletedBillingAddress = strDeletedBillingAddress.trim();
			string contInfoBillingId = strDeletedBillingAddress.substring(strDeletedBillingAddress.indexOf('_') + 1);
			contInfoBillingId = contInfoBillingId.trim();
			
			if(mapOfNewBillingTypeContInfo.containsKey(contInfoBillingId))
			{
				mapOfNewBillingTypeContInfo.remove(contInfoBillingId);
			}	
			
			else
			{
				Id contInfoId = Id.valueOf(contInfoBillingId);
				if(mapNonPrimaryContInfo.containsKey(contInfoId))
					mapNonPrimaryContInfo.remove(contInfoId);
					
				Contact_Info__c objDeletedContactInfo = new Contact_Info__c(Id = contInfoId);
				lstBillingTypeContInfoToDelete.add(objDeletedContactInfo);
			}
		}
	}	
	
	// Method used to delete Phone type ContactInfo records
	public void deletePhoneAddress()
	{
		if(!string.isBlank(strDeletedPhoneAddress))
		{
	 		strDeletedPhoneAddress = strDeletedPhoneAddress.trim();
			string contInfoPhoneId = strDeletedPhoneAddress.substring(strDeletedPhoneAddress.indexOf('_') + 1);
			contInfoPhoneId = contInfoPhoneId.trim();
			
			if(mapOfNewPhoneTypeContInfo.containsKey(contInfoPhoneId))
			{
				mapOfNewPhoneTypeContInfo.remove(contInfoPhoneId);
			}	
			
			else
			{
				Id contInfoId = Id.valueOf(contInfoPhoneId);
				if(mapNonPrimaryContInfo.containsKey(contInfoId))
					mapNonPrimaryContInfo.remove(contInfoId);
					
				Contact_Info__c objDeletedContactInfo = new Contact_Info__c(Id = contInfoId);
				lstPhoneTypeContInfoToDelete.add(objDeletedContactInfo);
			}
			
		}
	}	
	
	// method called onclick of savechanges in deliveryPreference section to update selected delivery preference and send an email to Member Service user if user has updated their delivery preference
	/* Start - Delivary preference save changes*/
	public PageReference delivaryPreferencesSaveChanges()
	{
		try
		{
			if(strAcctDeliverPreference == 'Email' || strAcctDeliverPreference == null)
			{
				objAccount.Billing_Document_Delivery_Method__c = 'Paper';
				update objAccount;
			}
				
			else if(strAcctDeliverPreference == 'Standard Email')
			{
				objAccount.Billing_Document_Delivery_Method__c = 'Electronic';
				update objAccount;
			}	
				
			EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where Name = 'ProfileSettingDeliveryPreference'];	
				
			if(emailTemplate != null)
		    {
				Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			    email.setSaveAsActivity(false);
			    email.setTargetObjectId(Userinfo.getUserId()); //idMemberServiceUser
			    email.setTemplateId(emailTemplate.Id);
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
		    }
		    
		    EmailTemplate emailTemplate1 = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Profile_Settings_Delivery_Preferences'];
		    
		    if(emailTemplate1 != null)
		    {
		        string strDeliveryPreference = '';
		        string strChangedfromdeliverypref = '';
		        string strChangedTodeliverypref = '';
		        
		        if(strAcctDeliverPreference == 'Email' || strAcctDeliverPreference == null)
		        {
		        	strChangedfromdeliverypref = 'eDelivery';
		        	strChangedTodeliverypref = 'Standard mail';
		        }	
		        	
		        else if(strAcctDeliverPreference == 'Standard Email')
		        {
		        	strChangedfromdeliverypref = 'Standard mail';
		        	strChangedTodeliverypref = 'eDelivery';
		        }	
		        
		        strDeliveryPreference = 'Change Request - Delivery Preference from  ' + strChangedfromdeliverypref + ' to ' + strChangedTodeliverypref;
		        
		        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		        
		        String htmlBody = emailTemplate1.HtmlValue;
		        String plainBody = emailTemplate1.Body ;
		        String subject = emailTemplate1.Subject;
		        subject = subject.replace('{!Account.Name}', objAccount.Name);
				subject = subject.replace('{!Account.Member_Key_EDW__c}',objAccount.Member_Key_EDW__c);
				
				htmlBody = htmlBody.replace('{!Receiving_User.FirstName}', strMemberServicesName);
				htmlBody = htmlBody.replace('MEMBER_SERVICES_TEXT_PLACEHOLDER', strDeliveryPreference);
				
				plainBody = plainBody.replace('{!Receiving_User.FirstName}', strMemberServicesName);
				plainBody = plainBody.replace('MEMBER_SERVICES_TEXT_PLACEHOLDER', strDeliveryPreference.stripHtmlTags());
				
				email.setHtmlBody(htmlBody);
			    email.setSaveAsActivity(false);
			    email.setSubject(subject);  
			    email.setPlainTextBody(plainBody);
			    email.setTargetObjectId(idMemberServiceUser);
			    //email.setTemplateId(emailTemplate1.Id);
			    //email.setPlainTextBody(plainBody.replace('PRIMARY_ADDRESS_TEXT_PLACEHOLDER',strDeliveryPreference ));
				List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.Email[] { email });
		    }
		    
		}
		
		catch(Exception e)
		{
			//
		}
		
		 PageReference pr = new PageReference('/ProfileSettingPage');
 	     pr.setRedirect(true);
         return pr;

	}
	/* End - Delivary preference save changes*/
	
	// Method called onclick of SaveChanges in communication Preferences section to update the selected communication Preferences for ContactInfos
	/* Start - Common preference save changes*/
	public PageReference commPreferencesSaveChanges()
	{
		try
		{
			list<string> lstSelectedPreferences;
		
			if(!string.isBlank(strSelectedCommPreferences))
			{
				lstSelectedPreferences = new list<string>();
				lstSelectedPreferences = strSelectedCommPreferences.split(',');
				updateContInfoCommPref(lstSelectedPreferences,true);
			}
			
			if(!string.isBlank(strUnSelectedCommPreferences))
		    {
		    	lstSelectedPreferences = new list<string>();
				lstSelectedPreferences = strUnSelectedCommPreferences.split(',');
				updateContInfoCommPref(lstSelectedPreferences,false);
		    }
		    
		    database.upsert(mapContactInfosToUpdate.values());
		     
		    if((!mapContactInfosToUpdate.isEmpty() && isMailNeedToBeSend))
			{
				/*EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Profile_Settings_Communication_Pref'];	
						
				if(emailTemplate != null)
			    {
			        //Sending email with Updated Contact Infos Information
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
					//String[] toAddresses = new String[] {strMemberServicesUserEmail}; 
			 		mail.setTemplateId(emailTemplate.Id);
			 		mail.setTargetObjectId(idMemberServiceUser);            //UserInfo.getUserId()
			 		mail.setSaveAsActivity(false);
			 		mail.setWhatId(userAccountId);
			 		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			     }*/
			     
			     Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				 email.setTemplateId([select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Portal_Profile_Settings_Update_Communication_Preference'].Id);
		 		 email.setTargetObjectId(UserInfo.getUserId());            //UserInfo.getUserId()
		 		 email.setSenderDisplayName('PURE Insurance');
		 		 email.setSaveAsActivity(false);
		 		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
			     
			     map<Id,Contact_Info__c> mapContInfoToUpdateIsUpdateFlag = new map<Id,Contact_Info__c>();
			     
			     for(Contact_Info__c objContInfo : mapContactInfosToUpdate.values())
			     {
			     	objContInfo.Is_Updated__c = false;
			     	mapContInfoToUpdateIsUpdateFlag.put(objContInfo.Id,objContInfo);
			     }
			     
			     Database.upsert(mapContInfoToUpdateIsUpdateFlag.values(),false);
			}
		}
		
		catch(Exception e)
		{
		}
		PageReference pr;
		pr = new PageReference('/ProfileSettingPage');
 	    pr.setRedirect(true);
		return pr;
	}
	
	    
	// Method used to update ContactInfo records based on selected communication preferences.
	private void updateContInfoCommPref(list<String> lstContInfoIds,Boolean isChecked)
	{
		map<Id,Contact_Info__c> mapExistingContactInfos = new map<Id,Contact_Info__c>();
		
		set<Id> setContInfoIds = new set<Id>();
		
		for(String strContInfoId : lstContInfoIds)	
		{
			String strContInfo = strContInfoId.trim();
			Id ContInfoId = strContInfo.substring(0,strContInfo.indexOf('_'));
			setContInfoIds.add(ContInfoId);
		}	
		
		for( Contact_Info__c objContactInfo : [Select Receive_Company_Updates__c,Is_Updated__c,
												Receive_PURE_Press__c,Receive_PURE_Situation_Room__c,Receive_PURE_Prevention__c,Receive_Annual_Report__c,Receive_SSA_Statements__c,Receive_PURE_Events__c
												from Contact_Info__c
												where id IN : setContInfoIds])
		{
			
			mapExistingContactInfos.put(objContactInfo.Id,objContactInfo);
		}										
					
		for( String strContInfoId : lstContInfoIds)
		{
			Contact_Info__c objContInfo = new Contact_Info__c();
			String strContInfo = strContInfoId.trim();
			Id ContInfoId = strContInfo.substring(0,strContInfo.indexOf('_'));
			objContInfo = mapExistingContactInfos.get(ContInfoId);
			
			String strContInfoCommPrefType = strContInfo.substring(strContInfo.indexOf('_') + 1);
			
			if( mapContactInfosToUpdate.containsKey(ContInfoId) )
				objContInfo = mapContactInfosToUpdate.get(ContInfoId);
		
				
			if(strContInfoCommPrefType == 'PureSituation')	
			{
				if(objContInfo.Receive_PURE_Situation_Room__c != isChecked)
				{
					objContInfo.Receive_PURE_Situation_Room__c = isChecked;
				    objContInfo.Is_Updated__c = true;
				}
				
				else
				{
					if(!objContInfo.Is_Updated__c)
						objContInfo.Is_Updated__c = false;
				}	
			}	
			
			else if(strContInfoCommPrefType == 'PurePrevention')
			{	
				if(objContInfo.Receive_PURE_Prevention__c != isChecked)
				{
					objContInfo.Is_Updated__c = true;	
					objContInfo.Receive_PURE_Prevention__c = isChecked;
				}
				
				else
				{
					if(!objContInfo.Is_Updated__c)
						objContInfo.Is_Updated__c = false;
				}
			}	
				
			else if(strContInfoCommPrefType == 'AnnualEmail' ||  strContInfoCommPrefType == 'AnnualStndMail' ||  strContInfoCommPrefType == 'AnnualBoth')	
			{
				if( objContInfo.Receive_Annual_Report__c != isChecked)
				{
					objContInfo.Receive_Annual_Report__c = isChecked;
					objContInfo.Is_Updated__c = true;
				}
				else
				{
					if(!objContInfo.Is_Updated__c)
						objContInfo.Is_Updated__c = false;
				}
						
			}	
				
			else if(strContInfoCommPrefType == 'SubscriberEmail' || strContInfoCommPrefType == 'SubscriberStndMail')	
			{
				if( objContInfo.Receive_SSA_Statements__c != isChecked)
				{
					objContInfo.Receive_SSA_Statements__c = isChecked;
					objContInfo.Is_Updated__c = true;
				}
				
				else
				{
					if(!objContInfo.Is_Updated__c)
						objContInfo.Is_Updated__c = false;
				}
					
			}	
			
			if(objContInfo.Is_Updated__c == true)
				isMailNeedToBeSend = true;
		    					
			mapContactInfosToUpdate.put(ContInfoId,objContInfo);
		}
	}
	
	public void dummy()
	{
		// do nothing
	}
	/* End - Common preference save changes*/
}