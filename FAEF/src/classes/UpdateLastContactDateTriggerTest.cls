@isTest
private class UpdateLastContactDateTriggerTest        
{
    static testMethod void testTriggers()
    {
     //Insert Account
     Account testAccount = new Account();
     testAccount.Name = 'Test';
     insert testAccount;

     //Insert your Test Data
     Contact testContact = new Contact();
     testContact.FirstName = 'UnitTestXYZABC99123ZZBB';
     testContact.LastName = 'TestXYZABC99123ZZBB';
     testContact.AccountId = testAccount.id;
     insert testContact;

     //Insert Account Event
     Event testEvent = new Event();
     testEvent.Subject = 'Test Event';
     testEvent.DurationInMinutes = 10;
     testEvent.ActivityDateTime = datetime.newInstance(2008, 12, 1, 12, 30, 2);
     testEvent.WhatId = testAccount.id;
     testEvent.WhoId = testContact.id;
     testEvent.New_Last_Valid_Contact_Date__c = date.newinstance(2012, 2, 7);
     insert testEvent;
     testEvent.Subject = 'Test Event (Modified)';
     update testEvent;
     
     //Insert Account Task
     Task testTask = new Task();
     testTask.Subject = 'Test Task';
     testTask.WhatId = testAccount.id;
     testTask.WhoId = testContact.id;
     testTask.New_Last_Valid_Contact_Date__c = date.newinstance(2012, 2, 7);
     insert testTask;
     testTask.Subject = 'Test Task (Modified)';
     update testTask;
     
     
    }
}