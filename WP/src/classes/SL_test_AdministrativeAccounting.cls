/**
 * This class contains unit tests for validating the behavior off trigger on Administrative_Accounting__c
 * author Vlad Gumenyuk 
 * date 11/20/2012
 * see https://silverline.jira.com/browse/WP-36
 * Test for Trigger on Administrative_Accounting__c
 */
@isTest(SeeAllData=true)
private class SL_test_AdministrativeAccounting {

    static testMethod void test_SL_handler_AdministrativeAccounting () {
      
       RecordType AccRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Operating_Company' and sObjectType = 'Account' limit 1];
      
        // Create dummy account
        Account testAccount = new Account(
          Name='Test 201502 Account 001',
          RecordTypeId = AccRecTypeId.Id
        );
        insert testAccount;

        RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
        Contact objContact = new Contact(LastName = 'Test 201502 Contact 24', RecordTypeId = ContRecTypeId.Id,  User_ID__c = UserInfo.getUserId() );
        insert objContact;
      
        Deal__c testDeal = new Deal__c(
             Name = 'Test 201502 Deal 001'
           , Company__c = testAccount.Id
           , WP_Investment__c = 10
           , WP_Ownership__c = 10
           , Description__c = 'TestDescription'
           /*, Target_Sectors__c = 'Energy'*/
           , ISOPENSTAGE__c = 1
           , Stage__c = 'Early-Prospect' 
           , Is_Energy_Opportunity__c = 'No'
        );
        insert testDeal;

        Fund__c testFund = new Fund__c (
             Name = 'Test Fund 001'
        ); 
        insert testFund;

      Test.startTest();

        Administrative_Accounting__c testAdministrativeAccounting = new Administrative_Accounting__c(
           Deal__c = testDeal.Id
           , Grills_Value__c = 100.0
           , Grills_Rank__c = '1'
           , Date_of_Record__c = Date.today()
           , Cost__c = 29.9
           , Carrying_Value__c = 3.0
           , Fund__c = testFund.Id
        );
        
        insert testAdministrativeAccounting;

        testAdministrativeAccounting.Grills_Value__c = 150.0;
        testAdministrativeAccounting.Grills_Rank__c = '2';
        testAdministrativeAccounting.Cost__c = 19.9;
        testAdministrativeAccounting.Carrying_Value__c = 2.0;

        update testAdministrativeAccounting;

       /*
		Account testAccount2 = [SELECT a.Id, a.Grills_Value__c, a.Grills_Rank__c, a.Date_of_Record__c, a.Cost__c, a.Carrying_Value__c FROM Account a WHERE a.Id = :testAccount.Id];

        System.assert(testAccount2.Cost__c == 19.9);
        System.assert(testAccount2.Grills_Value__c == 150.0);
        System.assert(testAccount2.Date_of_Record__c == Date.today());
        */

        delete testAdministrativeAccounting;

      Test.stopTest();
    }
    
}