/**
*   TestDataFactory - This is a test utility class that can create test records for test classes
*/
@isTest
public class TestDataFactory {
    public static list<Inverse_Relationship__c> createTestInverseRelationships(){
        list<Inverse_Relationship__c> retList = new list<Inverse_Relationship__c>();
        
        retList.add(new Inverse_Relationship__c(Name='Referred', Relationship__c='Referred', Relationship_Inverse__c='Referred By'));
        retList.add(new Inverse_Relationship__c(Name='Referred By', Relationship__c='Referred By', Relationship_Inverse__c='Referred'));

        return retList;
    }
    
    public static Account createTestAccount(){
        return new Account(Name='Test Account');
    }

    public static Contact createTestContact(Account testAccount){
        return new Contact(FirstName='Test', LastName='Contact', AccountId = testAccount.Id);
    }
}