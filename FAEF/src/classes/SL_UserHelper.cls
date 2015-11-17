public without sharing class SL_UserHelper {
	
	/*BEGIN PROPERTIES*/

	/*END PROPERTIES*/

	/***************************************************
	*	SHARED METHODS    					   		   *
	***************************************************/

	/***************************************************
	*	BEFORE INSERT METHODS    					   *
	***************************************************/

	/***************************************************
	*	BEFORE UPDATE METHODS    					   *
	***************************************************/

	public static void updateFrequency(SL_TriggerParameters tp){
		if(!System.isBatch())
		{		
			Map<Id, User> newIdtoUser = new Map<Id, User>(); 
			for (User user : (List<User>)tp.newList){
				if(user.contactId != null){
					newIdtoUser.put(user.Id, user);
				}
			}
            
            System.debug(LoggingLevel.ERROR, 'newIdToUser in before update' + newIdtoUser);
            
			List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id IN : newIdtoUser.keySet())];
			Set<Id> accountIds = new Set<Id>();
			for(Contact c : contacts){
				accountIds.add(c.AccountId);
			}
            System.debug(LoggingLevel.ERROR, 'contacts in before update' + contacts);

			List<Account_Portal__c> portals = [SELECT Id, Chatter_Group_Id__c, Account_Portal__c FROM Account_Portal__c WHERE Account_Portal__c IN : accountIds]; 
			Map<Id, Account_Portal__c> acctToAcctPortals = new Map<Id, Account_Portal__c>();
			Map<Id, Id> acctPortalToGroupId = new Map<Id, Id>();
			for(Account_Portal__c ap : portals){
				acctToAcctPortals.put(ap.Account_Portal__c, ap);
				acctPortalToGroupId.put(ap.Id, ap.Chatter_Group_Id__c);
			}
            System.debug(LoggingLevel.ERROR, 'portals in before update' + portals);
            System.debug(LoggingLevel.ERROR, 'acctToAcctPortals in before update' + acctToAcctPortals);
            System.debug(LoggingLevel.ERROR, 'acctPortalToGroupId in before update' + acctPortalToGroupId);
            
			Map<Id, CollaborationGroupMember> cGroupMembers = new Map<Id, CollaborationGroupMember>([SELECT Id, NotificationFrequency, MemberId FROM CollaborationGroupMember 
			WHERE MemberId IN : newIdtoUser.keySet() AND CollaborationGroupId IN : acctPortalToGroupId.values()]);
			System.debug(LoggingLevel.ERROR, 'group members ' +  cGroupMembers);
			
			Map<Id, String> memberToFreq = new Map<Id, String>();
			for(CollaborationGroupMember member : cGroupMembers.values()){
				User user = newIdtoUser.get(member.MemberId);
				if(user.Community_Email_Frequency__c == 'On Each Post'){
					memberToFreq.put(member.Id, 'P');
				}
				else if(user.Community_Email_Frequency__c == 'Daily'){
					memberToFreq.put(member.Id, 'D');
				}
				else if(user.Community_Email_Frequency__c == 'Weekly'){
					memberToFreq.put(member.Id, 'W');
				}
				else{
					memberToFreq.put(member.Id, 'N');
				}
			}
      System.debug(LoggingLevel.ERROR, 'memberToFreq in before update' + memberToFreq);
			SL_ChatterGroupHelper.updateGroupMembers(memberToFreq);				
		}
	}

	/***************************************************
	*	BEFORE DELETE METHODS    					   *
	***************************************************/

	/***************************************************
	*	AFTER INSERT METHODS    					   *
	***************************************************/
	
	public static void creatGroupMembers(SL_TriggerParameters tp){
		if(!System.isBatch())
		{
			Map<Id, User> newIdtoUser = new Map<Id, User>(); 
			for (User user : (List<User>)tp.newList){
				if(user.contactId != null){
					newIdtoUser.put(user.Id, user);
				}
			}
			Map<Id, User> newIdtoNewUser = new Map<Id, User>([SELECT Id, ContactId, Email FROM User WHERE Id IN : newIdtoUser.keySet()]);
			Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id IN : newIdtoUser.keySet())]);
			Set<Id> accountIds = new Set<Id>();
			for(Contact c : contacts.values()){
				accountIds.add(c.AccountId);
			}

			List<Account_Portal__c> portals = [SELECT Id, Chatter_Group_Id__c, Account_Portal__c 
											   FROM Account_Portal__c 
											   WHERE Account_Portal__c IN : accountIds]; 
			Map<Id, Account_Portal__c> acctToAcctPortals = new Map<Id, Account_Portal__c>();
			for(Account_Portal__c pc : portals){
				acctToAcctPortals.put(pc.Account_Portal__c, pc);
			}

			Map<Id,String> userToGroup = new Map<Id,String>();
	   		for(User u : newIdtoNewUser.values()){
					Contact contact = contacts.get(u.ContactId);
					if(acctToAcctPortals.get(contact.AccountId) != null){		
						userToGroup.put(u.Id, acctToAcctPortals.get(contact.AccountId).Chatter_Group_Id__c);
					}
	   		}
	   		if(userToGroup.keySet().size() > 0){
		   		SL_ChatterGroupHelper.createStandardGroupMembers(userToGroup);
	   		}
	   	}
	}

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