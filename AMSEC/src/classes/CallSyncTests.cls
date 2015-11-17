@isTest
private class CallSyncTests {
	private static Account a;
	private static User u;
	private static Contact c;
	private static Task t;
	private static Industry_Group__c g;
	private static Industry_Group_Coverage__c coverage;
	private static void setup() {
		a = new Account(
			Name = 'Test'
		);
		insert a;
		
		u = new User(
			FirstName = 'Unit',
			LastName = 'Test1',
			Alias = 'UT1',
			CommunityNickname = 'UnitTest1',
			Email = 'unittest1@unittest.com',
			Username = 'unittest1@unittest.com',
			TimeZoneSidKey = 'America/Los_Angeles',
			LocaleSidKey = 'en_US',
			LanguageLocaleKey = 'en_US',
			EmailEncodingKey = 'ISO-8859-1'
		);
		
		c = new Contact(
			LastName = 'Test',
			AccountId = a.Id
		);
		insert c;

		g = new Industry_Group__c (
			Name = 'TestG'
		);
		insert g;		
		
		coverage = new Industry_Group_Coverage__c(
			Primary_For_Group__c = false,
			Industry_Group__c = g.Id,
			Company__c  = a.Id,
			Inactive__c = false,
			Company_Contact__c = c.Id
		); 
		insert coverage;
		
		t = new Task(
			Subject = 'Test',
			Description = 'Test',
			CallObject = 'Test' + Crypto.getRandomInteger(),
			CallDurationInSeconds = 600,
			WhoId = c.Id,
			WhatId = a.Id
		);
	}
	
	static testMethod void testTaskInsert() {
		setup();
		
		Test.startTest();
		insert t;
		Test.stopTest();
		
		t = loadTask(t.Id);
		System.assertNotEquals(null, t.Call_Sync_Id__c);
		Event e = loadEvent(t.Call_Sync_Id__c);
		System.assertEquals(t.Id, e.Call_Sync_Id__c);
		System.assertEquals(t.Last_Sync__c, e.Last_Sync__c);
		System.assertEquals(t.Subject, e.Subject);
		System.assertEquals(t.Description, e.Description);
		System.assertEquals(t.WhoId, e.WhoId);
		System.assertEquals(t.WhatId, e.WhatId);
		System.assertEquals(600000, e.EndDateTime.getTime() - e.StartDateTime.getTime()); // difference should be 600 seconds, getTime returns milliseconds
	}
	
	static testMethod void testTaskUpdate() {
		setup();
		insert t;
		
		t.Subject = 'Test Edited';
		t.Description = 'Test Edited';
		t.CallDurationInSeconds = 300;
		Test.startTest();
		update t;
		Test.stopTest();
		
		t = loadTask(t.Id);
		Event e = loadEvent(t.Call_Sync_Id__c);
		System.assertEquals(t.Last_Sync__c, e.Last_Sync__c);
		System.assertEquals(t.Subject, e.Subject);
		System.assertEquals(t.Description, e.Description);
		System.assertEquals(t.WhoId, e.WhoId);
		System.assertEquals(t.WhatId, e.WhatId);
		System.assertEquals(300000, e.EndDateTime.getTime() - e.StartDateTime.getTime()); // difference should be 300 seconds, getTime returns milliseconds
	}
	
	static testMethod void testEventUpdate() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		Event e = loadEvent(t.Call_Sync_Id__c);
		
		e.Subject = 'Test Edited';
		e.Description = 'Test Edited';
		Test.startTest();
		update e;
		Test.stopTest();
		
		t = loadTask(t.Id);
		e = loadEvent(e.Id);
		System.assertEquals(e.Last_Sync__c, t.Last_Sync__c);
		System.assertEquals(e.Subject, t.Subject);
		System.assertEquals(e.Description, t.Description);
	}
	
	static testMethod void testTaskDelete() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		Test.startTest();
		delete t;
		Test.stopTest();
		
		Event e = [SELECT Id, IsDeleted FROM Event WHERE Id = :t.Call_Sync_Id__c ALL ROWS];
		System.assert(e.IsDeleted);
	}
	
	static testMethod void testEventDelete() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		Event e = loadEvent(t.Call_Sync_Id__c);
		Test.startTest();
		delete e;
		Test.stopTest();
		
		t = [SELECT Id, IsDeleted FROM Task WHERE Id = :e.Call_Sync_Id__c ALL ROWS];
		System.assert(t.IsDeleted);
	}
	
	static testMethod void testTaskUndelete() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		delete t;
		Test.startTest();
		undelete t;
		Test.stopTest();
		
		Event e = loadEvent(t.Call_Sync_Id__c); // If the event wasn't undeleted this will thrown an exception causing the test to fail
	}
	
	static testMethod void testEventUndelete() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		Event e = loadEvent(t.Call_Sync_Id__c);
		delete e;
		Test.startTest();
		undelete e;
		Test.stopTest();
		
		t = loadTask(t.Id); // If the task wasn't undeleted this will thrown an exception causing the test to fail
	}
	
	static testMethod void testViewTaskExtensionController() {
		setup();
		insert t;
		
		t = loadTask(t.Id);
		Event e = loadEvent(t.Call_Sync_Id__c);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(t);
		ViewTaskExtensionController vtec = new ViewTaskExtensionController(sc);
		PageReference pr = vtec.initPage();
		System.assert(pr.getUrl().contains(e.Id));
	}
	
	static testMethod void testTaskDeleteExcludingEvent() {
		setup();
		insert t;
		t = loadTask(t.Id);
		CallSyncUtility.DoNotProcessTaskDelete = true;
		delete t;
		Event e = [SELECT Id, IsDeleted FROM Event WHERE Id = :t.Call_Sync_Id__c ALL ROWS];
		System.assert(!e.IsDeleted);
		e.Subject = 'Test Edited';
		e.Description = 'Test Edited';
		update e;
		Task t1 = [SELECT Id, IsDeleted FROM Task WHERE Call_Sync_Id__c = :e.Id ALL ROWS];
	 	System.assert(t1.IsDeleted);
		e = loadEvent(e.Id);
		System.assertEquals(e.Subject, 'Test Edited');
		System.assertEquals(e.Description, 'Test Edited');
	}
	

	static testMethod void syncScheduledCleanUp() {
		CallSyncUtility.ScheduledCleanUpDebugMode = true;
		test.startTest();
		setup();
		CallSyncScheduledCleanUp nightlyClean = new CallSyncScheduledCleanUp();
		String schedule = '0 0 23 * * ?';
		system.schedule('Nightly Clean', schedule, nightlyClean);
		test.stopTest();
		CallSyncUtility.ScheduledCleanUpDebugMode = false;
	}
	
	private static Task loadTask(Id taskId) {
		return [SELECT Id, Call_Sync_Id__c, Last_Sync__c, Subject, Description, WhoId, WhatId, CallObject, CallDurationInSeconds FROM Task WHERE Id = :taskId];
	}
	
	private static Event loadEvent(Id eventId) {
		return [SELECT Id, Call_Sync_Id__c, Last_Sync__c, Subject, Description, WhoId, WhatId, StartDateTime, EndDateTime FROM Event WHERE Id = :eventId];
	}
}