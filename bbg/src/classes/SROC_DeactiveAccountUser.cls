public with sharing class SROC_DeactiveAccountUser {


	public static void checkUserDeactivationCriteria( map<Id,Account> oldMap , map<Id,Account> newMap ) {

		set<Id> setAccountId =  new set<Id>();  //To store Id of the account,to deactivate the corresponding users linked to it
		
		//Fetching the RecordType Id of Account having name 'Owner'
		Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Owner').getRecordTypeId();
		for(Account objAccount : newMap.values()) {

			if(objAccount.of_Active_SROC_Boats__c < 1 && objAccount.of_Active_SROC_Boats__c != oldMap.get(objAccount.Id).of_Active_SROC_Boats__c) {

				setAccountId.add(objAccount.id);
			}
		}

		if(!setAccountId.IsEmpty()) {

			deactivateAccountUsers(setAccountId);
		}
	}

	@future
	public static void deactivateAccountUsers(set<Id> setAccountId) {

		 List<User> lstUserToDeactivate =  new List<User>();  //To store Users linked to corresponding account
		 List<User> lstUserToUpdate =  new List<User>();

		 lstUserToDeactivate = [SELECT IsActive 
						     	FROM User 
						     	WHERE AccountId =: setAccountId AND
						     	IsActive = true];

		 if(!lstUserToDeactivate.isEmpty()) {

			for(User objUser :  lstUserToDeactivate) {

				objUser.IsActive = false;
				lstUserToUpdate.add(objUser);
		 	}

			update lstUserToUpdate;
		}
	}
}