/*
*Class: SL_UserHandler
*Description: This class is used as handler for SL_User trigger.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_UserHandler
{
	/* Start - Variables */
	/* End - Variables */
	
	/* Start - Constructor */
	public SL_UserHandler()
	{ 
			//Do Nothing
	}
	/* End - Constructor */

	/* Start - Method
       Method Name: onBeforeInsert
       Arguments: lst of Users that are going to be inserted
       Access: public 
       Return Type: void
       Purpose: To show error message if count of used licenses are greater than or equal to allocated licenses
    */  
	public void onBeforeInsert(List<User> lstUser)
	{
		showErrorMessage(lstUser);//Calling function to validate the count of used licenses
	}
	
	/* Start - Method
       Method Name: onAfterInsert
       Arguments: map of inserted Users
       Access: public 
       Return Type: void
       Purpose: Calculating the number of licenses on Account object after insertion of User record
    */  
	public void onAfterInsert(Map<Id,User> mapIdToUser)
	{
		Map<Id,String> mapUserIdToStatus = new Map<Id,String>();
		//Iterating over newly created User records to create a map of user id to Insert status
		for(User objUser : mapIdToUser.values())
			mapUserIdToStatus.put(objUser.Id,'Insert');
		if(!mapUserIdToStatus.isEmpty())
			SL_UserHandler.updatePortalOrganization(mapUserIdToStatus);//Calling future handler
	}
	
	/* Start - Method
       Method Name: onAfterUpdate
       Arguments: old and new map of updated users
       Access: public 
       Return Type: void
       Purpose: Calculating the number of licenses on Account object after insertion of User record
    */  
	public void onAfterUpdate(Map<Id,User> mapNewIdToUser, Map<Id,User> mapOldIdToUser)
	{
		Map<Id,String> mapUserIdToStatus = new Map<Id,String>();
		//Iterating over newly update records to check the enability of Users
		for(User objUser : mapNewIdToUser.values())
		{
		   //If user has been disabled from Contact view page or has been deactivated by unchecking the Active checkbox
		   if((objUser.IsPortalEnabled == false 
		   	  && mapOldIdToUser.get(objUser.Id).IsPortalEnabled == true 
		   	  && objUser.IsActive == true && mapOldIdToUser.get(objUser.Id).IsActive == true)
		   	  ||
		   	  (objUser.IsActive == false && mapOldIdToUser.get(objUser.Id).IsActive == true))
		   {
				mapUserIdToStatus.put(objUser.Id,'Disabled');
		   }
		   //if user has been activated by checking the Active checkbox on user detail page
		   else if(objUser.IsPortalEnabled == true 
		   	  	   && mapOldIdToUser.get(objUser.Id).IsPortalEnabled == true 
		   	  	   && objUser.IsActive == true && mapOldIdToUser.get(objUser.Id).IsActive == false)
		   {
		   		mapUserIdToStatus.put(objUser.Id,'Enabled');
		   }
		}
		if(!mapUserIdToStatus.isEmpty())
			SL_UserHandler.updatePortalOrganization(mapUserIdToStatus);//Calling future handler
	}
	
	/* Start - Method
       Method Name: onBeforeUpdate
       Arguments: old and new map of updated users
       Access: public 
       Return Type: void
       Purpose: To show error message if count of used licenses are greater than or equal to allocated licenses
    */  
    public void onBeforeUpdate(Map<Id,User> mapNewIdToUser, Map<Id,User> mapOldIdToUser)
    {
		List<User> lstUser = new List<User>();
		Map<String,User> mapContactIdToUser = new Map<String,User>();//map of contact Id to corresponding User record
		//Iterating over new map of Users to fill the list with activated users
		for(User objUser : mapNewIdToUser.values())
		{
			//Checking if user has been activated
			if(objUser.IsActive)
			{
				lstUser.add(objUser);
			}
			mapContactIdToUser.put(objUser.ContactId,objUser);
		}
		//Checking if list is empty
		if(!lstUser.isEmpty())
			showErrorMessage(lstUser);
		//Checking if list is empty
		if(!mapContactIdToUser.isEmpty())
			showErrorMessageForRecordEdit(mapContactIdToUser);//calling function to validate the current user's access on contact record
    }

	/* Start - Method
       Method Name: showErrorMessage
       Arguments: void
       Access: private
       Return Type: list of users
       Purpose: To show an error message if allotted licenses are less than used licenses.
    */  
    private void showErrorMessage(List<User> lstUser)
    {
    	Map<Id,User> mapContactIdToUser = new Map<Id,User>();//Map to hold contact id to its corresponding user record
		Map<String,List<User>> mapAccountIdToLstOfUser = new Map<String,List<User>>();//Map to hold account id and its corresponding portal users
		Set<Id> setGMId = new Set<Id>();//Set of GroupMemberIds
		List<String> lstAccountIds = new List<String>();
		
		//Iterating over user object to create a map of contact id to corresponding user
		for(User objUser : lstUser)
		{
			mapContactIdToUser.put(objUser.ContactId, objUser);		
		}

		//Iterating over contact object to form a map of account id and corresponding list of Users
		for(Contact objContact : [SELECT Id, AccountId FROM Contact 
								  WHERE Id IN:mapContactIdToUser.keyset() 
								  AND Account.RecordType.DeveloperName = 'Provider_Organization'])
		  {
			  	 if(!mapAccountIdToLstOfUser.containskey(objContact.AccountId))
			  	 	mapAccountIdToLstOfUser.put(objContact.AccountId,new List<User>{mapContactIdToUser.get(objContact.Id)});
			  	 else
			  	 	mapAccountIdToLstOfUser.get(objContact.AccountId).add(mapContactIdToUser.get(objContact.Id));
		  }
		//for(Account objAccount : [SELECT Id, Portal_Licenses_Allocated__c, Portal_Licenses_Used__c, Population__c
		//						 FROM 	Account 
		//						 WHERE  Id IN:mapAccountIdTolstOfUser.keyset()])
		//{
			//if(objAccount.Population__c != null && objAccount.Population__c != '')
			//{
				//setRecordIds.add(objAccount.Population__c+'_Population_Admins');
				//setRecordIds.add(objAccount.id);
				//recordID = objAccount.id;
			//}
			
		//} 
		//Collecting all ids in a set
		lstAccountIds.addAll(mapAccountIdToLstOfUser.keySet());
		setGMId = getRecordIdWithEditAccess(lstAccountIds);//calling function to get record ids with edit access
		
	   //Iterating over Account object to fetch all the records whose ids are contained in the map collected above
   	   for(Account objAccount : [SELECT Id, Portal_Licenses_Allocated__c, Portal_Licenses_Used__c, Population__c
								 FROM 	Account 
								 WHERE  Id IN:mapAccountIdTolstOfUser.keyset()])
		{
			//Iterating over user object to validate it
			for(User objUser : mapAccountIdToLstOfUser.get(objAccount.Id))
			{
				//Checking if used licenses are greater than allocated licenses
				if(objAccount.Portal_Licenses_Used__c >= objAccount.Portal_Licenses_Allocated__c || objAccount.Portal_Licenses_Allocated__c == null)
					objUser.Username.addError(System.Label.SL_LicenseNumberExceeded);

				//for checking the corresponding user's contact account for authorization as per the requirement of MIHIN-84
				if(setGMId == null || (!setGMId.contains(objAccount.Id)))
					objUser.addError(System.Label.SL_UnauthorizedCreationError);
			}
		}
    }
    
    /* Start - Method
       Method Name: showErrorMessageForRecordEdit
       Arguments: map of Contact Id To User
       Access: private
       Return Type: void
       Purpose: To show an error message if allotted licenses are less than used licenses.
    */  
    /* As per the requirement of the MIHIN-93 */
    private void showErrorMessageForRecordEdit(Map<String,User> mapContactIdToUser)
    {
    	List<String> lstContactIds = new List<String>();
    	Set<Id> setContactIdswithEditAccess = new Set<Id>();
    	String strhpdpopulationadminprofileid = gethpdPopulationAdminProfileId();//Calling funtion to get the profile id
    	//collecting all ids in list
    	lstContactIds.addAll(mapContactIdToUser.keySet());
    	setContactIdswithEditAccess = getRecordIdWithEditAccess(lstContactIds);
    	//Iterating over map and check if the logged in user have edit access or not
    	for(String strContactId : mapContactIdToUser.keySet())
    	{
    		if(UserInfo.getProfileId()==strhpdpopulationadminprofileid && !setContactIdswithEditAccess.contains(strContactId))
    			mapContactIdToUser.get(strContactId).addError(Label.SL_UnauthorizedRecordEdit);
    	}
    }
    /* As per the requirement of the MIHIN-93 */

    /* Start - Method
       Method Name: getRecordIdWithEditAccess
       Arguments: list of record ids
       Access: private
       Return Type: map of Contact Id To User
       Purpose: To show an error message if allotted licenses are less than used licenses.
    */ 

    /* As per the requirement of the MIHIN-93 */ 
    private Set<Id> getRecordIdWithEditAccess(List<String> lstRecordIds)
    {
    	Set<Id> setRecordIds = new Set<Id>();
    	for(UserRecordAccess objGM : [SELECT RecordID 
      								FROM UserRecordAccess 
      								where RecordId IN :lstRecordIds
      								and UserID = :UserInfo.getUserId() and HasEditAccess = true])
		{
			setRecordIds.add(objGM.RecordID);
		}
		return setRecordIds;
    }
    /* As per the requirement of the MIHIN-93 */

    /* Start - Method
       Method Name: updatePortalOrganization
       Arguments: void
       Access: public
       Return Type: map of user id to status, map of user id to profile name and map of profile name to its user type
       Purpose: To update the related account records with actual licenses used 
    */  
    @future
    public static void updatePortalOrganization(Map<Id,String> mapUserIdToStatus)
    {
    	Map<Id,List<User>> mapAccountIdTolstOfUser = new Map<Id,List<User>>();//map to collect account ids and their corresponding user ids
    	List<Account> lstAccount = new List<Account>();// list of accounts for which we have to update the license parameters
    	
    	//Iterating over User to fill the map with Account Id and their corresponding users
    	for(User objUser : [SELECT Id, Contact.AccountId, IsActive, IsPortalEnabled, Profile.UserLicense.Name 
    						FROM   User 
							WHERE  Id IN:mapUserIdToStatus.keyset() 
							AND Contact.Account.RecordType.Name = 'Provider Organization'
							AND Profile.UserLicense.Name = 'Customer Portal Manager Custom'])
		{
			if(!mapAccountIdTolstOfUser.containsKey(objUser.Contact.AccountId))
				mapAccountIdTolstOfUser.put(objUser.Contact.AccountId, new List<User>{objUser});
			else
				mapAccountIdTolstOfUser.get(objUser.Contact.AccountId).add(objUser);
		}
		
		//Iterating over Account object to fetch all the records whose ids are contained in the map collected above
   	   for(Account objAccount : [SELECT Id, Portal_Licenses_Allocated__c, Portal_Licenses_Used__c
								 FROM 	Account 
								 WHERE  Id IN:mapAccountIdTolstOfUser.keyset()])
		{
			Integer intPortalUsedLicenses = 0;
			if(objAccount.Portal_Licenses_Used__c!=null)
				intPortalUsedLicenses = (objAccount.Portal_Licenses_Used__c).intValue();
			for(User objUser : mapAccountIdTolstOfUser.get(objAccount.Id))
			{
				//Checking if user is active
				if(objUser.IsActive)
				{
					//If user has been inserted or enabled from user detail page
					if(mapUserIdToStatus.get(objUser.Id) == 'Insert' || mapUserIdToStatus.get(objUser.Id) == 'Enabled')
						intPortalUsedLicenses++;// Do increament of used licenses by 1
					//If user has been disabled from Contact detail view and the license count is greater than 0
					else if(mapUserIdToStatus.get(objUser.Id) == 'Disabled' && objAccount.Portal_Licenses_Used__c > 0)
						intPortalUsedLicenses--;// Do decreament of used licenses by 1
				}
				else 
				{
					if(objAccount.Portal_Licenses_Used__c > 0)
						intPortalUsedLicenses--;
				}					
			}
			lstAccount.add(new Account(Id = objAccount.Id, Portal_Licenses_Used__c = intPortalUsedLicenses));
		}
		if(!lstAccount.isEmpty())
			update lstAccount;
    }
    
     /* Start - Method
       Method Name: updatePortalOrganization
       Arguments: void
       Access: public
       Return Type: map of user id to status, map of user id to profile name and map of profile name to its user type
       Purpose: To update the related account records with actual licenses used 
    */  
    private String gethpdPopulationAdminProfileId()
    {
    	return [SELECT Id FROM Profile WHERE Name =:'HPD - Population Admin'].Id;
    }    	
}