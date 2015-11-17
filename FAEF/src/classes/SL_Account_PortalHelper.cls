public with sharing class SL_Account_PortalHelper {
	
	/*BEGIN PROPERTIES*/

	/*END PROPERTIES*/

	/***************************************************
	*	SHARED METHODS    					   		   *
	***************************************************/

	/***************************************************
	*	BEFORE INSERT METHODS    					   *
	***************************************************/

	public static void createChatterGroup(SL_TriggerParameters tp){
		Set<Id> acctIds = new Set<Id>();// list of accounts that need associated chatter groups
		Set<Id> portalBrandings = new Set<Id>();//map of account portal to associated portal branding id
		for (Account_Portal__c ap : (List<Account_Portal__c>)tp.newList){
			acctIds.add(ap.Account_Portal__c);
			portalBrandings.add(ap.Portal__c);
		}
		//create groups
		Map<Id, CollaborationGroup> acctIdToGroup = SL_ChatterGroupHelper.createChatterGroup([SELECT Id, Name, OwnerId FROM Account WHERE Id IN : acctIds]);
		for(Account_Portal__c ap : (List<Account_Portal__c>)tp.newList){
			ap.Chatter_Group_Id__c = acctIdToGroup.get(ap.Account_Portal__c).Id;
		}

		//get account external users
		Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE AccountId IN : acctIds]);
   		Map<Id, User> acctUsers = new Map<Id, User>([SELECT Id, ContactId FROM User WHERE ContactId IN : contacts.keySet() AND IsActive = true]);
   		Map<Id, Id> userToGroup = new Map<Id, Id>();
		for(User u : acctUsers.values()){
			Contact contact = contacts.get(u.ContactId);
			if(u.Id != acctIdToGroup.get(contact.AccountId).OwnerId) {
				userToGroup.put(u.Id, acctIdToGroup.get(contact.AccountId).Id);
	   			u.Community_Email_Frequency__c = 'On Each Post';
			}
   		}
   		update acctUsers.values();

		//create standard users
		SL_ChatterGroupHelper.createStandardGroupMembers(userToGroup);

		//get portal contacts
   		Map<Id, Portal_Contact__c> portalContacts = new Map<Id, Portal_Contact__c>([SELECT Id, User__c
   												  FROM Portal_Contact__c 
   												  WHERE Portal_Branding__c IN : portalBrandings
   												  AND Is_Chatter__c = true]);
   		Set<Id> userIds = new Set<Id>();
   		for(Portal_Contact__c pc : portalContacts.values()){
   			userIds.add(pc.User__c);
   		}
   		SL_ChatterGroupHelper.insertPermissionSet(userIds);
		SL_ChatterGroupHelper.createAdminGroupMembers(portalContacts.keySet());
	}

	/***************************************************
	*	BEFORE UPDATE METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE DELETE METHODS    					   *
	***************************************************/

	public static void removeChatterGroup(SL_TriggerParameters tp){
		List<Id> groupIds = new List<Id>();  
		for (Account_Portal__c ap : (List<Account_Portal__c>)tp.oldList){
			groupIds.add(ap.Chatter_Group_Id__c);
		}
		List<CollaborationGroup> cGroups = [SELECT Id FROM CollaborationGroup WHERE Id  IN : groupIds];
		delete cGroups;
	}

	/***************************************************
	*	AFTER INSERT METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER UPDATE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER DELETE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER UNDELETE METHODS    					   *
	***************************************************/

}