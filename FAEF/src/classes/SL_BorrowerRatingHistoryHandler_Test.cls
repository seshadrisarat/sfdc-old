/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage. 
 */
@isTest
private class SL_BorrowerRatingHistoryHandler_Test 
{

    static testMethod void myUnitTest() 
    {
        String strRecordTypeId = [Select Id From RecordType Where Name = 'General' AND SobjectType = 'Account'].Id;
        List<Borrower_Rating_History__c> lstBorrowerRatingHistory = new List<Borrower_Rating_History__c>();
        Test.startTest();
        Account objAccount = new Account(Name = 'Test Account Sep27-01', RecordTypeId = strRecordTypeId);
        insert objAccount;
        
        Borrower_Rating_History__c objBorrowerRatingHistory = new Borrower_Rating_History__c(Account__c = objAccount.Id, 
        																					 New_Borrower_Rating__c = '1', 
        																					 Effective_Date__c = date.today());
        
        Borrower_Rating_History__c objBorrowerRatingHistory1 = new Borrower_Rating_History__c(Account__c = objAccount.Id, 
        																					 New_Borrower_Rating__c = '2', 
        																					 Effective_Date__c = date.today().addDays(1));
        
        Borrower_Rating_History__c objBorrowerRatingHistory2 = new Borrower_Rating_History__c(Account__c = objAccount.Id, 
        																					 New_Borrower_Rating__c = '3', 
        																					 Effective_Date__c = date.today());
        lstBorrowerRatingHistory.add(objBorrowerRatingHistory1);
        lstBorrowerRatingHistory.add(objBorrowerRatingHistory);
        insert lstBorrowerRatingHistory;
        system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == '2');
        
        lstBorrowerRatingHistory[0].New_Borrower_Rating__c = '5';
        update lstBorrowerRatingHistory[0];
        system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == '5');
        
        delete lstBorrowerRatingHistory[0];
        system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == '1');
        
        insert objBorrowerRatingHistory2;
        lstBorrowerRatingHistory.add(objBorrowerRatingHistory2);
        //system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == '3');
        
        delete lstBorrowerRatingHistory[1];
        delete lstBorrowerRatingHistory[2];
        //system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == null);
        
        undelete lstBorrowerRatingHistory[0];
        //system.assert([select Id, Borrower_Risk_Rating__c from Account limit 1].Borrower_Risk_Rating__c == '5');
        Test.stopTest();
        
        
    }
}