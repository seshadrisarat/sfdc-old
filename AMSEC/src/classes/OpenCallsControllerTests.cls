@isTest
private class OpenCallsControllerTests {
	static testMethod void testControllerGoodData() {
		Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
		
		User u = new User(
			FirstName = 'Unit',
			LastName = 'Test',
			Alias = 'UnitTest',
			CommunityNickname = 'UnitTest',
			Email = 'unittest@unittest.com',
			Username = 'unittest@unittest.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1',
			ProfileId = prof.Id
		);
		insert u;
		
		Account acct = new Account(
			Name = 'Test Account'
		);
		insert acct;
		
		Contact cont = new Contact(
			FirstName = 'Unit',
			LastName = 'Test',
			Email = 'unittest@unittest.com',
			AccountId = acct.Id
		);
		insert cont;
		
		Event evnt = new Event(
			OwnerId = u.Id,
			Subject = 'Call',
			Event_Type__c = 'Phone Call',
			Event_Status__c = 'Not Started',
			StartDateTime = System.now().addDays(-1),
			DurationInMinutes = 30
		);
		insert evnt;
		
		System.runAs(u) {
			OpenCallsController controller = new OpenCallsController();
			controller.init();
			System.assertNotEquals(null, controller.calls);
			System.assertEquals(1, controller.calls.size());
		}
	}
}