@isTest
private class ConvertTaskToNoteService_TEST {
	
	@isTest static void test_ConvertTaskToNoteService() {
		
		list<Account> accounts = new list<Account>();
		accounts.add(new Account(Name = 'Cain Brothers', Sector__c = 'Pharmacy'));
		accounts.add(new Account(Name = 'Cain Brothers 2', Sector__c = 'Pharmacy'));
    	insert accounts;

    	list<Contact> contacts = new list<Contact>();
    	contacts.add(new Contact(FirstName = 'Court',LastName = 'Houseworth', AccountId = accounts[0].Id, Status__c='Active'));
    	contacts.add(new Contact(FirstName = 'Court',LastName = 'Houseworth 2', AccountId = accounts[1].Id, Status__c='Active'));
    	insert contacts;

    	Task t = new Task(Subject='Test', Description='Test', WhoId=contacts[0].Id, WhatId=Accounts[0].Id);
    	insert t;

    	list<cpnp__Folder__c> folders = [select id from cpnp__Folder__c where cpnp__Default__c = true and OwnerId=:UserInfo.getUserId()];
    	if (!folders.isEmpty()) delete folders;

    	Test.startTest();

    	ConvertTaskToNoteService svc = new ConvertTaskToNoteService();

    	Database.QueryLocator ql = svc.start(null);
    	svc.execute(null, [select id, Subject, Description, WhoId, WhatId, OwnerId from Task where Task_To_Note_Processed__c = false limit 1]);

    	Test.stopTest();
	}
	
}