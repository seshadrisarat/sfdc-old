//S-179419 - Created by Aditya Paliwal 
//Created to cover DealsWorkedRollupBatchable
@isTest
private class DealsWorkedRollupBatchabletest {
    static testMethod void DealsWorkedRollupBatchable_Test() {
    Test.startTest();
    DealsWorkedRollupBatchable batchObject = new DealsWorkedRollupBatchable(NULL);
        
    Account acc = new Account(Name = 'Test Name', Source__c = 'LinkedIn', Description = 'abc@123qwerty');  
    String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Intermediary'].Id;
    system.debug('strRecordTypeId ' + strRecordTypeId );
    acc.recordtypeid= strRecordTypeId;
    insert acc;
        
    Contact cont= new Contact (FirstName='Test', LastName='Contact',Accountid=acc.id,Email='abcd@vmail.com', Phone='12345678');
    insert cont;
        
    Deal__c deal=new Deal__c(Name='Test Deal', Related_Company__c=acc.id, CurrencyIsoCode='INR', Status__c='Evaluating', Source__c='Other');
    insert deal;
        
    Deal_Contact__c Dcont=  new Deal_Contact__c(Deal__c=deal.Id, Contact_Name__c=cont.id, CurrencyIsoCode='INR');
    insert Dcont;
    Database.executeBatch(batchObject);
    Test.stopTest();
    }
}