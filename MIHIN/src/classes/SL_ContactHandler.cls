/*
*Class: SL_ContactHandler
*Description: This is handler class for the Contact to update the Latitude, Longitude and Geocoding_Required__c fields on change of the other contact address.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ContactHandler 
{
	/* Start - Variables */
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    /* End - Variables */
    
	/* Start - Contructor */
	public SL_ContactHandler(boolean isExecuting, integer size) 
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
	/* End - Contructor*/
	
	 /*  
    @MethodName   : onBeforeUpdate
    @param        : Map<Id, Contact> mapOldContact and Map<Id, Contact> mapNewContact
    @Description  : Method called on event: Before Update
    */
    public void onBeforeUpdate(Map<Id, Contact> mapOldContact, Map<Id, Contact> mapNewContact)
    {
    	List<Contact> lstContact = new List<Contact>();//list of contacts that are to be passed to function
    	set<Id> setRecordIds = new set<Id>();//To store the contacts where ownerId is changed.
    	set<Id> setErrorRecordIds = new set<Id>();
    	
    	//Iteration on contact to check if the other address is blank or not.
    	for(Contact objContact : mapNewContact.values())
    	{    	
      		if(mapOldContact.get(objContact.Id).AccountId!=mapNewContact.get(objContact.Id).AccountId)
      				lstContact.add(objContact);
    		
    		//Added by Sandeep regarding MIHIN-92: To check if ownerId is changed.
    		if(mapOldContact.get(objContact.Id).OwnerId != mapNewContact.get(objContact.Id).OwnerId)
    				setRecordIds.add(objContact.Id);	
    		
    		//Checking if the contact address is blank or not and compare with old value as well.
    		if((objContact.OtherStreet == '' ||  objContact.OtherStreet == null || objContact.OtherCity == '' || objContact.OtherCity == null
    		   || objContact.OtherState == ''|| objContact.OtherState == null || objContact.OtherPostalCode == '' || objContact.OtherPostalCode == null
    		   || objContact.OtherCountry == '' || objContact.OtherCountry == null) && 
    		   !(mapOldContact.get(objContact.Id).OtherStreet == '' ||  mapOldContact.get(objContact.Id).OtherStreet == null 
    		   && mapOldContact.get(objContact.Id).OtherCity == '' || mapOldContact.get(objContact.Id).OtherCity == null
    		   && mapOldContact.get(objContact.Id).OtherState == ''|| mapOldContact.get(objContact.Id).OtherState == null 
    		   && mapOldContact.get(objContact.Id).OtherPostalCode == '' || mapOldContact.get(objContact.Id).OtherPostalCode == null
    		   && mapOldContact.get(objContact.Id).OtherCountry == '' || mapOldContact.get(objContact.Id).OtherCountry == null))
    		{
    			objContact.Location__Latitude__s = null;
    			objContact.Location__Longitude__s = null;
    		}
    		//Checking if other address of the contact is changed or not.
    		else if(mapOldContact.get(objContact.Id).OtherStreet != objContact.OtherStreet|| mapOldContact.get(objContact.Id).OtherCity != objContact.OtherCity
    		       || mapOldContact.get(objContact.Id).OtherState != objContact.OtherState|| mapOldContact.get(objContact.Id).OtherPostalCode != objContact.OtherPostalCode
    		       || mapOldContact.get(objContact.Id).OtherCountry != objContact.OtherCountry)
    		{
    			objContact.Geocoding_Required__c = true;
    		}
    	}
    	
    	if(!lstContact.isEmpty())
    		updatePortalId(lstContact);//Calling function to update the portal ids
    	
    	//Added by Sandeep MIHIN-92
    	if(!setRecordIds.isEmpty()) {
    		
    		SL_ValidateRecordTransfer objSL_ValidateRecordTransfer = new SL_ValidateRecordTransfer();
    		setErrorRecordIds = objSL_ValidateRecordTransfer.validateUpdatedRecords(setRecordIds); 
    		
    		
    		if(!setErrorRecordIds.isEmpty()) {
	    		//Iterating the records and throwing error on records those not satisfied the required conditions.
		    	for(Contact objContact : mapNewContact.values())
		    	{
		    		if(setErrorRecordIds.contains(objContact.Id))
		    		{
		    			objContact.addError(Label.SL_UnauthorizedRecordTransferError);
		    		}
		    	}
    		}
    	}
    	
    }
    
    /* End */
    
      public void onBeforeInsert(List<Contact> lstContact)
      {
    		updatePortalId(lstContact);//Calling function to update the portal ids
      }
      
      private void updatePortalId(List<Contact> lstContact)
      {
      		Set<Id> setAccountId = new Set<Id>();//Set to contain all Account ids corresponding to the contact
    		Map<String,String> mapOrganizationIdToPortalId = new Map<String,String>();// this is a map of organization id to portal id
    		Map<Id,Id> mapAccountIdToParentId = new Map<Id,Id>();// this is a map of account id to its parent id
    		String strDefaultPortalURL = '';//Default portal id in case no portal record is found
    		
    		//Iterating over Contact object to get all Account ids
    		for(Contact objContact : lstContact)
    		{
    			setAccountId.add(objContact.AccountId);
    		}
    		
    		//Iterating over account object to create a map of account id to its parent id
    		for(Account objAccount : [SELECT Id, ParentId FROM Account WHERE Id IN:setAccountId])
    		{
    			mapAccountIdToParentId.put(objAccount.Id,objAccount.ParentId);
    			setAccountId.add(objAccount.ParentId);
    		}
    		
    		//Iterating over organization portal to get portal ids corresponding to the accounts collected in above set
    		for(Organization_Portal__c objOrganizationPortal : [SELECT Portal__r.Portal_Id__c, Organization__c, Portal__r.Website_URL__c														 
																FROM   Organization_Portal__c 
																WHERE  Organization__c IN:setAccountId])
			{
					mapOrganizationIdToPortalId.put(objOrganizationPortal.Organization__c, objOrganizationPortal.Portal__r.Website_URL__c);					
			}
			
			//Fetching default portal id from Portal Branding object to associate with default portal if no portal is found
			List<Portal__c> lstPortalBranding = [SELECT Website_URL__c 
								  		   		 FROM   Portal__c 
							      		   		 WHERE  Name=:'DEFAULT_PORTAL_UI' LIMIT 1];
							      		   		 
			if(lstPortalBranding!=null && !lstPortalBranding.isEmpty())
				strDefaultPortalURL = lstPortalBranding[0].Website_URL__c;
							      
			//Iterating over Contact to assign the portal id corresponding to the account id
			for(Contact objContact : lstContact)
			{
				//Checking if there is a portal associated with the account then simply get that value from map
				if(mapOrganizationIdToPortalId.containskey(objContact.AccountId) 
					&& mapOrganizationIdToPortalId.get(objContact.AccountId) != null)
				{
					objContact.Portal_URL__c = mapOrganizationIdToPortalId.get(objContact.AccountId);
				}
				
				//Checking if there is portal associated with the parent account of the current account then get the value 
				//from map assign this to contact
				else if(mapAccountIdToParentId.get(objContact.AccountId)!=null 
						&& mapOrganizationIdToPortalId.containskey(mapAccountIdToParentId.get(objContact.AccountId))
						&& mapOrganizationIdToPortalId.get(mapAccountIdToParentId.get(objContact.AccountId))!= null)
				{
					objContact.Portal_URL__c = mapOrganizationIdToPortalId.get(mapAccountIdToParentId.get(objContact.AccountId));
				}
				
				//otherwise assign the value of default portal id
				else
				{
					objContact.Portal_URL__c = strDefaultPortalURL;
				}
			}
      }
    
    /* Start - Added By Pankaj Ganwani on 16th JUNE 2015 as per the requirements of MIHIN-109*/
    /*  
    @MethodName : onAfterInsert
    @param      : List<Contact> lstContact
    @Description: method is called on after insertion of contact record to insert the related provider identifier record.
    */
    public void onAfterInsert(List<Contact> lstContact)
    {
    	List<Provider_Identifier__c> lstProviderIdentifier = new List<Provider_Identifier__c>();// list of the provider identifier records that need to be inserted.
    	
    	for(Contact objContact : lstContact)
    	{
    		if(String.isNotEmpty(objContact.NPI__c))
    			lstProviderIdentifier.add(new Provider_Identifier__c(Type__c = 'NPI', Data_Source_ID__c = String.format('{0}-{1}',new List<String>{'NPI',objContact.NPI__c}), Name = objContact.NPI__c, Data_Source__c = objContact.Data_Source__c, Provider__c = objContact.Id));
    	}    	
    	Database.insert(lstProviderIdentifier,false);
    }
    /* End - Added By Pankaj Ganwani on 16th JUNE 2015 as per the requirements of MIHIN-109*/
    
   /* public void onAfterInsert(List<Contact> lstNewContact)
    {
        try
        {
            List<Id> lstAccountId = new List<Id>();
            List<Id> lstContactId = new List<Id>();
            List<AccountShare> lstAccountShare  = new List<AccountShare>();
            List<ContactShare> lstContactShare  = new List<ContactShare>();
            Map<Id, List<Id>> mapAccountIdToUserId  = new Map<Id, List<Id>>();
            
            // Collect AccountIds of inserted Contact records
            for(Contact objContact : lstNewContact)
            {
                if(objContact.AccountId != null)
                {
                    lstAccountId.add(objContact.AccountId);
                }
            }
            
            if(lstAccountId.isEmpty())  return;
            
            // Query users with lookups to these Account Ids 
            List<User> lstUsers = new List<User>();
            // Fetch the UserLicenseId of Gold Partner User
            UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
            
            lstUsers = [Select Id, AccountId FROM User Where AccountId IN : lstAccountId AND 
                        Profile.UserLicenseId =: objUserLicense.Id AND IsActive = true];
            
            for(User objUser : lstUsers)
            {
                if(mapAccountIdToUserId.containsKey(objUser.AccountId))
                {
                    mapAccountIdToUserId.get(objUser.AccountId).add(objUser.Id);
                }
                else
                {
                    mapAccountIdToUserId.put(objUser.AccountId, new List<Id>{objUser.Id});
                }
            }
            
            for(Id accountId : mapAccountIdToUserId.keyset())
            {
                for(Id userId : mapAccountIdToUserId.get(accountId))
                {
                    AccountShare objAS = new AccountShare(AccountId = accountId,
                                                          UserOrGroupId = userId,
                                                          OpportunityAccessLevel = 'Read',
                                                          AccountAccessLevel = 'Edit');
                    lstAccountShare.add(objAS);
                }
            }
            
            for(Contact objContact : [Select Id, AccountId FROM Contact Where AccountId IN : lstAccountId])
            {
                if(mapAccountIdToUserId.containsKey(objContact.AccountId))
                {
                    for(Id userId : mapAccountIdToUserId.get(objContact.AccountId))
                    {
                        ContactShare objCS = new ContactShare( ContactId  = objContact.Id,
                                                               UserOrGroupId = userId,
                                                               ContactAccessLevel = 'Edit');
                        lstContactShare.add(objCS);
                    }
                    
                }
            }
            
            if(!lstAccountShare.isEmpty())  upsert lstAccountShare;
            if(!lstContactShare.isEmpty())  upsert lstContactShare;
        }
        catch(Exception e)
        {
        }
        
    }*/
    
    public void onAfterUpdate(Map<Id, Contact> mapOldContact, Map<Id, Contact> mapNewContact){
        SL_ScriptPrecedenceUtil precedenceUtil = new SL_ScriptPrecedenceUtil('Contact');
        precedenceUtil.getNewMap(mapOldContact, mapNewContact);
    }




    /*  
    @MethodName : onBeforeUpdate
    @param      : List<Contact> lstNewContact, Map<Id, Contact> mapOldContact
    @Description: Method called on event: Before Update
    */
   /* public void onAfterUpdate(List<Contact> lstNewContact, Map<Id, Contact> mapOldContact)
    {
        try
        {
            List<Id> lstNewAccountIdToEnableSharing = new List<Id>();
            List<Id> lstOldAccountIdToRemoveSharing = new List<Id>();
            Set<Id> setContactIds = new Set<Id>();
            
            for(Contact objContact : lstNewContact)
            {
                setContactIds.add(objContact.Id);
                if(objContact.AccountId !=  mapOldContact.get(objContact.Id).AccountId)
                {
                    lstOldAccountIdToRemoveSharing.add(mapOldContact.get(objContact.Id).AccountId);
                    lstNewAccountIdToEnableSharing.add(objContact.AccountId);
                }
            }
            
            UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
            
            if(!lstNewAccountIdToEnableSharing.isEmpty())
            {
                List<AccountShare> lstAccountShare  = new List<AccountShare>();
                List<ContactShare> lstContactShare  = new List<ContactShare>();
                Map<Id, List<Id>> mapAccountIdToUserId  = new Map<Id, List<Id>>();
            
                // Query users with lookups to these Account Ids 
                List<User> lstUsers = new List<User>();
                
                // Fetch the UserLicenseId of Gold Partner User
                lstUsers = [Select Id, AccountId FROM User Where ContactId IN : setContactIds AND 
                            Profile.UserLicenseId =: objUserLicense.Id AND isActive = true];
                            
                for(User objUser : lstUsers)
                {
                    if(mapAccountIdToUserId.containsKey(objUser.AccountId))
                    {
                        mapAccountIdToUserId.get(objUser.AccountId).add(objUser.Id);
                    }
                    else
                    {
                        mapAccountIdToUserId.put(objUser.AccountId, new List<Id>{objUser.Id});
                    }
                }
                
                for(Id accountId : mapAccountIdToUserId.keyset())
                {
                    for(Id userId : mapAccountIdToUserId.get(accountId))
                    {
                        AccountShare objAS = new AccountShare(AccountId = accountId,
                                                              UserOrGroupId = userId,
                                                              OpportunityAccessLevel = 'Read',
                                                              AccountAccessLevel = 'Edit');
                        lstAccountShare.add(objAS);
                    }
                }
                
                for(Contact objContact : [Select Id, AccountId FROM Contact Where AccountId IN : lstNewAccountIdToEnableSharing])
                {
                    if(mapAccountIdToUserId.containsKey(objContact.AccountId))
                    {
                        for(Id userId : mapAccountIdToUserId.get(objContact.AccountId))
                        {
                            ContactShare objCS = new ContactShare( ContactId  = objContact.Id,
                                                                   UserOrGroupId = userId,
                                                                   ContactAccessLevel = 'Edit');
                            lstContactShare.add(objCS);
                        }
                    }
                }
                
                if(!lstAccountShare.isEmpty())  upsert lstAccountShare;
                if(!lstContactShare.isEmpty())  upsert lstContactShare;
            }
        }
        catch(Exception e)
        {
        }
    }*/
  
  /*
    @isTest(seeAllData = true)
    private static void test_SL_EnableAccessToPartnerUsersHandler()
    {
        UserLicense objUserLicense = [Select Id From UserLicense Where Name = 'Gold Partner' LIMIT 1];
        
        List<User> lstTestUsers = [ Select AccountId FROM User 
                                    Where Profile.UserLicenseId =: objUserLicense.Id AND 
                                    isActive=true AND 
                                    AccountId != null LIMIT 2];
        
        Contact objContact = new Contact(AccountId = lstTestUsers[0].AccountId, LastName = 'Test Name');
        insert objContact;
        
        Contact objNewContact = new Contact(Id = objContact.Id, AccountId =lstTestUsers[1].AccountId);
        update objNewContact;
        
    }*/
}