/*************************************************************************
Name : BatchSetTieredStatusTest 
Author : Jyoti Singh
Usage : test Class for BatchSetTieredStatusOfAccount  
**************************************************************************/
@isTest
private class BatchSetTieredStatusTest {
    private static testMethod void testBatch() {
        List<Account> accList = new List<Account>();

        Account acc1 = Test_Utility.createAccount('TestAcc1', null, 'Company');
        acc1.Status__c = 'Early Investigation';
        acc1.Tiered_Status__c = '';
        accList.add(acc1);

        Account acc2 = Test_Utility.createAccount('TestAcc2', null, 'Company');
        acc2.Status__c = 'Monitor';
        acc2.Tiered_Status__c = '';
        accList.add(acc2);

        Account acc3 = Test_Utility.createAccount('TestAcc3', null, 'Company');
        acc3.Status__c = 'Top Prospect';
        acc3.Tiered_Status__c = '';
        accList.add(acc3);

        Account acc4 = Test_Utility.createAccount('TestAcc4', null, 'Company');
        acc4.Status__c = 'Primary Target';
        acc4.Tiered_Status__c = '';
        accList.add(acc4);

        Account acc5 = Test_Utility.createAccount('TestAcc5', null, 'Company');
        acc5.Status__c = 'Live Deal';
        acc5.Tiered_Status__c = '';
        accList.add(acc5);

        Account acc6 = Test_Utility.createAccount('TestAcc6', null, 'Company');
        acc6.Status__c = 'Pass';
        acc6.Tiered_Status__c = '';
        accList.add(acc6);

        insert accList;      

        Test.startTest();
        BatchSetTieredStatusOfAccount batch = new BatchSetTieredStatusOfAccount();    
        Database.executeBatch(batch, 200);     
        Test.stopTest();
       
        //12/12/13 - jfavors - add assertions
        accList = [SELECT Status__c, Tiered_Status__c
                   FROM Account
                   WHERE Id in :accList];

        System.assertEquals(6, accList.size());
        System.assertEquals('Tier 0 - Early Investigation', accList[0].Tiered_Status__c);
        System.assertEquals('Tier 1 - Monitor', accList[1].Tiered_Status__c);
        System.assertEquals('Tier 2 - Top Prospect', accList[2].Tiered_Status__c);
        System.assertEquals('Tier 3 - Primary Target', accList[3].Tiered_Status__c);
        System.assertEquals('Tier 4 - Live Deal', accList[4].Tiered_Status__c);
        System.assertEquals('Pass', accList[5].Tiered_Status__c);
        // end jfavors
    }
    
    // 12/12/13 - jfavors - test SetAccountFields trigger
    private static testMethod void testStatusSync() {
        Account acc1, acc2, acc3, acc4, acc5, acc6;
        List<Account> accList = new List<Account>();

        acc1 = Test_Utility.createAccount('TestAcc1', null, 'Company');
        acc1.Tiered_Status__c = 'Tier 0 - Early Investigation';
        accList.add(acc1);

        acc2 = Test_Utility.createAccount('TestAcc2', null, 'Company');
        acc2.Tiered_Status__c = 'Tier 1 - Monitor';
        accList.add(acc2);

        acc3 = Test_Utility.createAccount('TestAcc3', null, 'Company');
        acc3.Tiered_Status__c = 'Tier 2 - Top Prospect';
        accList.add(acc3);

        acc4 = Test_Utility.createAccount('TestAcc4', null, 'Company');
        acc4.Tiered_Status__c = 'Tier 3 - Primary Target';
        accList.add(acc4);

        acc5 = Test_Utility.createAccount('TestAcc5', null, 'Company');
        acc5.Tiered_Status__c = 'Tier 4 - Live Deal';
        accList.add(acc5);

        acc6 = Test_Utility.createAccount('TestAcc6', null, 'Company');
        acc6.Tiered_Status__c = 'Pass';
        accList.add(acc6);

        insert accList;
        
        accList = [SELECT Status__c, Tiered_Status__c
                   FROM Account
                   WHERE Id in :accList];
        
        System.assertEquals(6, accList.size());
        System.assertEquals('Early Investigation', accList[0].Status__c);
        System.assertEquals('Monitor', accList[1].Status__c);
        System.assertEquals('Top Prospect', accList[2].Status__c);
        System.assertEquals('Primary Target', accList[3].Status__c);
        System.assertEquals('Live Deal', accList[4].Status__c);
        System.assertEquals('Pass', accList[5].Status__c);
    }

}