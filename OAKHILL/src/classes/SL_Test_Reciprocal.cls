/**
 
* \author Volodymyr Babin
 
* \date 08/20/2014
 
* \see http://silverline.jira.com/browse/LIB-227
 
* \brief Tests reciprocal triggers logic.
 
*/
@isTest
private class SL_Test_Reciprocal {

    static testMethod void testAffiliations() {
        Account acc1 = new Account(Name='Test 1');
        insert acc1;
        Map<Id, Account> accs = new MAp<Id,Account>();
        accs.put(acc1.id, acc1);
        
        acc1.Name = 'Test 2';
        Map<Id, Account> accsNew = new MAp<Id,Account>();
        accsNew.put(acc1.id, acc1);
        
        Account acc2 = new Account(Name='Test 3');
        insert acc2;
        
        Test.startTest();
        Acount_To_Account_Affiliation__c a2a = new Acount_To_Account_Affiliation__c(
           From_Account__c = acc1.id, 
           To_Account__c = acc2.id, 
           Type__c = 'Spouse'
        );
        
        // CHECK INSERT
        insert a2a;
        Map<ID, Acount_To_Account_Affiliation__c> a2aMap = new Map<ID, Acount_To_Account_Affiliation__c> ([select id, Related_Affiliation__c from Acount_To_Account_Affiliation__c]);
        // Check there are two objects and their IDs correspond to each other.
        a2a = a2aMap.get(a2a.Id);
        System.assertEquals(2, a2aMap.size());
        System.assertEquals(a2a.id, a2aMap.get(a2aMap.get(a2a.id).Related_Affiliation__c).Related_Affiliation__c);
        System.assertEquals(a2a.id, a2aMap.get(a2a.Related_Affiliation__c).Related_Affiliation__c);
        
        // CHECK UPDATE
        a2a.Type__c = '';
        update a2a;
        System.assertEquals(null, ([select Type__c from Acount_To_Account_Affiliation__c where id = :a2a.Related_Affiliation__c limit 1]).Type__c);
        
        // CHECK DELETE
        delete a2a;
        System.assertEquals(true, ([select Type__c from Acount_To_Account_Affiliation__c where id = :a2a.Related_Affiliation__c]).isEmpty());
        
        // CHECK UNDELETE
        undelete a2a;
        a2aMap = new Map<ID, Acount_To_Account_Affiliation__c> ([select id, Related_Affiliation__c from Acount_To_Account_Affiliation__c]);
        System.assertEquals(2, a2aMap.size());
        Test.stopTest();
    }
}