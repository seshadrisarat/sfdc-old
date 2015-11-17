@isTest
private class OpportunityTriggerTest {

    static testMethod void TestOpportunityTriggers() 
    {
        Account a = new Account(Name = 'Test Name');
        insert a;
        
        Opportunity o1 = new Opportunity
        (
            Name = 'New Opportunity',
            AccountId = a.id,
            StageName = 'Approved',
            Amount = 500,
            CloseDate = Date.today(),
            Opp_is_approved__c = true
        );
        insert o1;
        
        Opportunity o2 = new Opportunity
        (
            Name = 'New Opportunity',
            AccountId = a.id,
            StageName = 'Closed',
            Amount = 500,
            CloseDate = Date.today(),
            Opp_is_approved__c = true
        );
        insert o2;
        
        o2.StageName = 'Approved';
        update o2;
        
        
    }
    
    @isTest(SeeAllData=true)
    static void TestChatterAlert(){
        Test.startTest();
        User u = [SELECT id, Default_Chatter_Group__c FROM User LIMIT 1];
        u.Default_Chatter_Group__c = 'Test Group';
        update u;
        
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Opportunity o = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = a.id,
            StageName = 'Pre-Opportunity',
            Amount = 500,
            Chatter_Created__c = false,
            CloseDate = Date.today(),
            OwnerId = u.id
        );
        insert o;

        Opportunity o2 = new Opportunity(
            Name = 'Test Opportunity 2',
            AccountId = a.id,
            StageName = 'Information Gathering',
            Amount = 500,
            Chatter_Created__c = false,
            CloseDate = Date.today(),
            OwnerId = u.id
        );
        insert o2;

        CollaborationGroup cgs = new CollaborationGroup( name = u.Default_Chatter_Group__c, CollaborationType = 'Public' );
        insert cgs;

        Opportunity opp = [SELECT id, StageName FROM Opportunity WHERE Id = :o.id LIMIT 1];
        opp.StageName = 'Information Gathering';
        opp.Chatter_Created__c = false;
        update opp;
        Test.stopTest();
    }
}