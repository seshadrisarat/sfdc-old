@isTest
private class Test_TaskTriggers {

	/*
	static testMethod void test() {
		Account a = new Account(Name = 'Test');
		insert a;
		Contact c = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = a.Id);
		insert c;
		Task t = new Task(
			WhoId = c.Id,
			Subject = 'Test',
			Status = 'Not Started',
			Priority = 'Normal'
		);
		insert t;
		
		Task t2 = new Task(
			WhatId = a.Id,
			Subject = 'Test',
			Status = 'Completed',
			Priority = 'Normal',
			Result__c = 'Spoke to DM'
		);
		insert t2;
		
		a = [select Id, Last_Valid_Contact_Date__c from Account where Id = :a.Id];
		system.assertEquals(a.Last_Valid_Contact_Date__c, Date.today());
		
	}
	*/

}