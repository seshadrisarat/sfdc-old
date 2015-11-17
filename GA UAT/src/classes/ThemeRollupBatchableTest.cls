/*S-179420 - Created by Kanchan Palhora on 1/15/2014
Created to cover class ThemeRollupBatchable */
@isTest
private class ThemeRollupBatchableTest {

    static testMethod void myUnitTest() {
        Test.startTest();
        ThemeRollupBatchable batchObject = new ThemeRollupBatchable(NULL);
            
        Account acc = new Account(Name = 'Test Name', Source__c = 'LinkedIn', Description = 'abc@123qwerty');  
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Account' and Name = 'Intermediary'].Id;
        system.debug('strRecordTypeId ' + strRecordTypeId );
        acc.recordtypeid= strRecordTypeId;
        insert acc;
     
        Deal__c deal=new Deal__c(Name='Test Deal', Related_Company__c=acc.id, CurrencyIsoCode='INR', Status__c='Closed', Source__c='Other');
        insert deal;
        
        Theme__c theme = new Theme__c(Name='Test theme', Group__c = 'Mumbai', Active__c = 'Map');
        insert theme;
        
        Deal_Theme__c dealTheme = new Deal_Theme__c (Deal__c = deal.Id, Theme__c = theme.Id);
        insert dealTheme;
        
        Database.executeBatch(batchObject);
        Test.stopTest();
    }
}