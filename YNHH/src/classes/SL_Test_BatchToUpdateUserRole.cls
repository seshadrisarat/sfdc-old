@isTest
private class SL_Test_BatchToUpdateUserRole {
	
	@isTest static void test_method_one() {
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> lstUsers = new List<User>{new User(Alias = 'stn1', Email='stnd01@testorg.com', 
											            EmailEncodingKey='UTF-8', LastName='test1', 
											            LanguageLocaleKey='en_US', ProfileId = p.Id,
											            LocaleSidKey='en_US',  
											            TimeZoneSidKey='America/Los_Angeles', UserName='stnd001@testorg.com'),
    										  new User(Alias = 'stn2', Email='stnd02@testorg.com', 
										            	EmailEncodingKey='UTF-8', LastName='test2', 
										            	LanguageLocaleKey='en_US', ProfileId = p.Id,
										            	LocaleSidKey='en_US',  
										            	TimeZoneSidKey='America/Los_Angeles', UserName='stnd002@testorg.com')
    										  };
        insert lstUsers;

        List<User> lstUsersRetrieved = [Select Id, UserRoleId From User Where Id IN : lstUsers];
        // Checking the UserRoleId is NULL on the Users..
        system.assert(lstUsersRetrieved[0].UserRoleId == NULL);
        system.assert(lstUsersRetrieved[1].UserRoleId == NULL);

        Test.startTest();

        system.runAs(new user(Id = UserInfo.getUserId())) {
        	// Inserting the Contacts..
	        List<Contact> lstContacts = new List<Contact>{new Contact (LastName = 'Test-01', Email = 'test01@test.com', Employee_Number__c = '001554', Portal_User__c = lstUsers[0].Id ),
	        											  new Contact (LastName = 'Test-02', Email = 'test02@test.com', Employee_Number__c = '001555', Portal_User__c = lstUsers[1].Id )};
			insert lstContacts;
	        
	        // calling the schedule caller...
	        SL_ScheudleCaller_UpdateUserRole obj = new SL_ScheudleCaller_UpdateUserRole();

	        // Calling the batch..
	        SL_BatchToUpdateUserRoleForContacts objBatch = new SL_BatchToUpdateUserRoleForContacts();
	        database.executebatch(objBatch);   
	        Test.stopTest();
        }

        lstUsersRetrieved = [Select Id, UserRoleId From User Where Id IN : lstUsers];
        // Checking the UserRoleId is UPDATED AND NOW NOT EQUALS TO NULL on the above Same Users..
        system.assert(lstUsersRetrieved[0].UserRoleId != NULL);
        system.assert(lstUsersRetrieved[1].UserRoleId != NULL);
	}	
}