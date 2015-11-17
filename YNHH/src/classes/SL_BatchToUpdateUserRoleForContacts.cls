/**
* \arg ClassName        : SL_BatchToUpdateUserRoleForContacts
* \arg JIRATicket     	: YNHH-162
* \arg CreatedOn      	: 25/AUG/2015
* \arg LastModifiedOn	: 
* \arg CreatededBy    	: Harsh 
* \arg ModifiedBy     	: 
* \arg Description      : Batch class for Updating the RoleId of the User
*/
global class SL_BatchToUpdateUserRoleForContacts implements Database.Batchable<sObject> {
	
	String query;
	public static Id ROLEYNHHEMPId = [Select Id From UserRole Where DeveloperName = 'YNHH_Employee' limit 1].Id;
	 
    /* Start - Constructor */
	global SL_BatchToUpdateUserRoleForContacts() {
		// Intialize whatever you want to initialize at the Load od the class.
	}
	/* End - Constructor */ 
	
	/**
	    @MethodName : start
	    @Param 		: Database.BatchableContext BC  
	    @Description: This method is used to collect the Contact records whose Portal_User__r.UserRoleId Equals to NULL
    **/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'Select Id, Name, Portal_User__r.userRoleId From Contact Where Portal_User__c != NULL AND Portal_User__r.userRoleId = NULL';
		return Database.getQueryLocator(query);
	}

	/**
	    @MethodName : execute
	    @Param 		: Database.BatchableContext BC, List<Contact> lstContact
	    @Description: This method is used update the RoleId of the Users that are related to Contact.
    **/
   	global void execute(Database.BatchableContext BC, List<Contact> lstContact) {
		List<User> lstUserToUpdateRole = new List<User>();
		Set<Id> setofUniqueUserIds = new Set<Id>();

		// collecting the Portal_User__c from the contact..
		for(Contact objCon : lstContact) {
			setofUniqueUserIds.add(objCon.Portal_User__c);
		}
		// updating the User's RoleIds 
		for(User objUser : [Select UserRoleId, Id From User Where Id IN : setofUniqueUserIds]) {
			objUser.UserRoleId = ROLEYNHHEMPId;
			lstUserToUpdateRole.add(objUser);
		}

		update lstUserToUpdateRole;
	}
	
	/**
	    @MethodName : finish
	    @Param 		: Database.BatchableContext BC
	    @Description: This method for doing anything after finishing of every chunk records in the batch..
    **/
	global void finish(Database.BatchableContext BC) {
		// Do whatever you want after finishing all the work with the records got in start method
	}
	
}