@isTest
public class ReferralTriggerHandlerTest {
     static testMethod void testReferralInverses(){
        list<Inverse_Relationship__c> retList = TestDataFactory.createTestInverseRelationships();
        insert retList;
        
        Account referredAcct = TestDataFactory.createTestAccount();
        referredAcct.Name = 'Referred Account';
        insert referredAcct;

       

        Account referredByAcct = TestDataFactory.createTestAccount();
        referredByAcct.Name = 'Referred By Account';
        insert referredByAcct;

       
        
        
        
        Agency_Company__c testReferral = new Agency_Company__c( Agency__c = referredAcct.Id, Company_Brand__c = referredbyAcct.id, Type__c = 'Referred');
        insert testReferral;
        
        testReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Id];
        Agency_Company__c testInvReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Inverse_Referral__c];
        
        // test Account fill in 
        System.assertEquals(referredByAcct.Id, testReferral.Company_Brand__c);
        
        System.assertEquals('Referred By', testInvReferral.Type__c);
        System.assertEquals(referredByAcct.Id, testInvReferral.Agency__c);
        
        
        
        testReferral.Type__c = 'Referred By';
        update testReferral;
        
        testReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Id];
        testInvReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Inverse_Referral__c];
            
        System.assertEquals('Referred', testInvReferral.Type__c);
        
        
        delete testReferral;
        list<Agency_Company__c> referralList = [select id from Agency_Company__c where id =: testReferral.Id or id =: testInvReferral.Id ];
        System.assertEquals(0, referralList.size());
        
        
        undelete testReferral;
        testReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Id];
        testInvReferral = [select id,  Company_Brand__c, Type__c,  Agency__c, Inverse_Referral__c 
            from Agency_Company__c where id = :testReferral.Inverse_Referral__c];
        
        System.assertEquals('Referred', testInvReferral.Type__c);
              System.assertEquals(referredByAcct.Id, testInvReferral.Agency__c);
        
    }

}