@isTest
private class SL_Test_Handler_User {

	Static Account a;
	Static Contact c;
	Static Profile p;
	Static User u;
	Static Boolean isSetup = false;

	@testSetup
	static void userHandlerSetup(){
		if(!isSetup){
			a = new Account(Name='TestAccount');
			insert a;

			c = new Contact(LastName='TesterContact', AccountId=a.Id);
			insert c;

			p = [SELECT Id FROM Profile WHERE Name = 'PURE Broker View Partner Login User'];

			u = new User(Alias = 'zxytest',
							CommunityNickname = 'zxytestyxz',
							ContactId = c.Id,
							DefaultGroupNotificationFrequency = 'N',
							DigestFrequency = 'N',
							Email = 'test2@email.com',
							EmailEncodingKey = 'ISO-8859-1',
							FirstName = 'Test',
							LanguageLocaleKey = 'en_US',
							LastName = 'Tester',
							LocaleSidKey = 'en_US',
							ProfileId = p.Id, // Pure Broker View Partner Login User
							TimeZoneSidKey = 'GMT',
							Username = 'test2@zxcvbnm.com',
							IsActive = true,
							UserPermissionsChatterAnswersUser = false);
		}
	}

	static testMethod void SL_Test_Handler_User_Add_Contact() {
		userHandlerSetup();

		Test.startTest();

		insert u;

		Test.stopTest();

		List<Contact> cList = [SELECT Registered_For_Portal__c FROM Contact WHERE Id = :c.Id LIMIT 1];

		System.assertEquals(true, clist[0].Registered_For_Portal__c);
	}

	static testMethod void SL_Test_Handler_User_Remove_Contact() {

		userHandlerSetup();

		insert u;

		Test.startTest();
		// Update email because ContactId is not editable and we have a test flag in the code
		u.Email = 'test3@email.com';
		update u;

		Test.stopTest();

		List<Contact> cList2 = [SELECT Registered_For_Portal__c FROM Contact WHERE Id = :c.Id LIMIT 1];

		System.assertEquals(false, cList2[0].Registered_For_Portal__c);

	}
}