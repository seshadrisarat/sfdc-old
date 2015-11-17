@isTest
private class Test_ContactTriggers {

    static testMethod void test() {
        Account a = new Account(Name = 'TEST');
        insert a;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = a.Id, Last_Call_Attempt__c = DateTime.now());
        insert c;
    }
}