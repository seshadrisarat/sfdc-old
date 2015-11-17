//S-179419 - Created by Aditya Paliwal 
//Created to cover InitializeEmployeeBatchable

@isTest(seeAlldata= true)
private class InitializeEmployeeBatchabletest {
    static testMethod void InitializeEmployeeBatchable_Test() {
    Test.startTest();
    InitializeEmployeeBatchable batchObject = new InitializeEmployeeBatchable(NULL);
   
    Account a = new Account(name='Test Deal Company');
    insert a;

        Contact c = new Contact(FirstName='Test',LastName='Contact',AccountID=a.id);
        insert c;

        Deal__c d = new Deal__c(Related_Company__c=a.Id,Source_Name__c=c.id,Source_Company__c=a.id,Deal_Size_MM__c=5,Status__c='Early Investigation');
        insert d;

        Employee__c e = new Employee__c(Initials__c='!TL');
        insert e;

        Theme__c thm = new Theme__c(Name='Test Theme',Assigned_To_v2__c=e.Id,Active__c='Active');
        insert thm;

    
    Database.executeBatch(batchObject);
    Test.stopTest();
    }
    }