/**  
* \arg ClassName        : SL_Test_ContactTriggerHandler
* \arg JIRATicket       : NPD-212
* \arg CreatedOn        : 09/Oct/2015
* \arg LastModifiedOn   : 09/Oct/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Test class for SL_ContactTriggerHandler class.
*/
@isTest
private class SL_Test_ContactTriggerHandler 
{ 
    static testMethod void Test_ContactTriggerHandler()
    {
        Id practiceRTId = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Practice_Account' LIMIT 1].Id;
        Id parentRTId = [SELECT Id FROM RecordType WHERE SObjectType =: 'Account' AND DeveloperName =: 'Parent_Account' LIMIT 1].Id;
        
        Account objAccount = new Account(Name = 'Account-01', RecordTypeId = parentRTId, BillingCity = 'London');
        insert objAccount;
        
        List<Account> lstAccount = new List<Account>{
            new Account(Name = 'Account-02', RecordTypeId = practiceRTId, Company_Account__c = objAccount.Id, BillingCity = 'London'),
            new Account(Name = 'Account-03', RecordTypeId = practiceRTId, Company_Account__c = objAccount.Id, BillingCity = 'London')
        };
        insert lstAccount;
        
        List<Contact> lstContact = new List<Contact>{
            new Contact (LastName = 'Contact-01', AccountId = lstAccount[0].Id),
            new Contact (LastName = 'Contact-02', AccountId = lstAccount[0].Id),
            new Contact (LastName = 'Contact-03', AccountId = lstAccount[1].Id),
            new Contact (LastName = 'Contact-04', AccountId = lstAccount[1].Id)
        };
        insert lstContact;
        
        system.assertEquals([SELECT Id FROM Contact_Relationship__c WHERE Contact__c IN : lstContact].size(), 4);
        
        /* To cover trigger handler */
        update lstContact[0];
        delete lstContact[0];
        undelete lstContact[0];
        /* To cover trigger handler */
    }
}