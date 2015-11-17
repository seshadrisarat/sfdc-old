/**
 * This class contains unit tests for validating the behavior off trigger on Contact
 * author Vlad Gumenyuk 
 * date 10/09/2012
 * see https://silverline.jira.com/browse/WP-2
 * Test for Trigger on Contact after update to create Former Employee record
 */
@isTest
private class SL_test_handler_Contact {

    //@isTest(SeeAllData=true)
    static testMethod void test_SL_handler_Contact () {
      Test.startTest();

	RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];

        // Create dummy accounts
        Account testAccount = new Account(
          Name='Test Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;
        Account testAccount2 = new Account(
          Name='Test Account 002',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount2;

        Contact testContact = new Contact(
          AccountId = testAccount.Id
         ,LastName = 'Test Contact Name'
         ,Title = 'Test Title Contact'
        );
        insert testContact;

        List<Former_Employee__c> list_Former_Employee = [Select f.Id,f.Title__c, f.End_Date__c, f.Contact__c,f.Company__c From Former_Employee__c f WHERE f.Contact__c = :testContact.Id LIMIT 1];
        System.assert(list_Former_Employee.size()==0);

        testContact.AccountId = testAccount2.Id;
        update testContact;

        List<Contact> list_Contact = [SELECT Id,AccountId,Title FROM Contact WHERE id = :testContact.Id LIMIT 1];

        list_Former_Employee = [Select f.Id,f.Title__c, f.End_Date__c, f.Contact__c,f.Company__c From Former_Employee__c f WHERE f.Contact__c = :testContact.Id LIMIT 1];
        System.assert(list_Former_Employee.size()==1);
        System.assert(list_Former_Employee[0].Company__c==testAccount.Id);
        System.assert(list_Former_Employee[0].Title__c==list_Contact[0].Title);
        System.assert(list_Former_Employee[0].Contact__c==testContact.Id);
        System.assert(list_Former_Employee[0].End_Date__c==Date.today());

        delete list_Former_Employee;
        delete testContact;
        undelete testContact; 
        delete testContact;
        delete testAccount;
        delete testAccount2;

      Test.stopTest();
    }

}