@isTest

private class SL_TestActivityHandlers_RM {
    
    private static Id idRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Person'].Id;

    static testMethod void SL_TestTaskHandler() {

        // Create test relationship group record
        Relationship_Group__c rg = new Relationship_Group__c();
        rg.Name = 'Test RG';
        insert rg;

        // Create test account record
        Account acct = new Account();
        acct.LastName = 'Test Account';
        acct.RecordTypeId = idRecordType;
        acct.Primary_Relationship_Group__c = rg.Id;
        insert acct;

        // Retrieve test contact record
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acct.id LIMIT 1];

        // Create test group member record
        Group_Member__c gm = new  Group_Member__c();
        gm.Client_Prospect__c = acct.Id;
        gm.Relationship_Group__c = rg.Id;
        insert gm;


        // Create test task
        Task tsk = new Task();
        tsk.WhatId = acct.Id;
        tsk.WhoId = con.Id;
        tsk.ActivityDate = Date.today();
        tsk.Subject = 'Test Task';
        tsk.Status = 'Completed';
        insert tsk;


        // Update test task as Type = Call
        tsk.Type = 'Call';
        SL_RecursionHelper.isUpdate = true;
        
        Test.startTest();
        update tsk;
        Test.stopTest();


        // Assertion for Account.Last_Contact_Date__c
        List<Account> acctList_LCD = new List<Account>();
        acctList_LCD = [SELECT Id, Last_Contact_Date__c FROM Account WHERE Id = :acct.id LIMIT 1];
        System.assertEquals(acctList_LCD[0].Last_Contact_Date__c, Date.today());

        // Assertion for Group_Member__c.Last_Contact_Date__c
        List<Group_Member__c> gmList_LCD = new List<Group_Member__c>();
        gmList_LCD = [SELECT Id, Last_Contact_Date__c FROM Group_Member__c WHERE Id = :gm.id LIMIT 1];
        System.assertEquals(gmList_LCD[0].Last_Contact_Date__c, Date.today());


        // Update test task as Type = Meeting
        tsk.Type = 'Meeting';
        SL_RecursionHelper.isUpdate = true;
        update tsk;


        // Assertion for Account.Last_Meeting_Date__c
        List<Account> acctList_LMD = new List<Account>();
        acctList_LMD = [SELECT Id, Last_Meeting_Date__c FROM Account WHERE Id = :acct.id LIMIT 1];
        System.assertEquals(acctList_LMD[0].Last_Meeting_Date__c, Date.today());

        // Assertion for Group_Member__c.Last_Meeting_Date__c
        List<Group_Member__c> gmList_LMD = new List<Group_Member__c>();
        gmList_LMD = [SELECT Id, Last_Meeting_Date__c FROM Group_Member__c WHERE Id = :gm.id LIMIT 1];
        System.assertEquals(gmList_LMD[0].Last_Meeting_Date__c, Date.today());

    }

    static testMethod void SL_TestEventHandler() {

        // Create test relationship group record
        Relationship_Group__c rg = new Relationship_Group__c();
        rg.Name = 'Test RG';
        insert rg;

        // Create test account record
        Account acct = new Account();
        acct.LastName = 'Test Account';
        acct.RecordTypeId = idRecordType;
        acct.Primary_Relationship_Group__c = rg.Id;
        insert acct;

        // Retrieve test contact record
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acct.id LIMIT 1];

        // Create test group member record
        Group_Member__c gm = new  Group_Member__c();
        gm.Client_Prospect__c = acct.Id;
        gm.Relationship_Group__c = rg.Id;
        insert gm;


        // Create test event
        Event evt = new Event();
        evt.WhatId = acct.Id;
        evt.WhoId = con.Id;
        evt.StartDateTime = Datetime.now().addDays(-2);
        evt.EndDateTime = Datetime.now().addDays(-1);
        evt.Subject = 'Test Event';
        insert evt;

        /** COMMENTED BLOCK
        
        // Update test event as Type = Call
        evt.Type = 'Call';
        SL_RecursionHelper.isUpdate = true;
        
        Test.startTest();
        update evt;
        Test.stopTest();

        // Assertion for Account.Last_Contact_Date__c
        List<Account> acctList_LCD = new List<Account>();
        acctList_LCD = [SELECT Id, Last_Contact_Date__c FROM Account WHERE Id = :acct.id LIMIT 1];
        System.assertEquals(acctList_LCD[0].Last_Contact_Date__c, Date.today().addDays(-1));

        // Assertion for Group_Member__c.Last_Contact_Date__c
        List<Group_Member__c> gmList_LCD = new List<Group_Member__c>();
        gmList_LCD = [SELECT Id, Last_Contact_Date__c FROM Group_Member__c WHERE Id = :gm.id LIMIT 1];
        System.assertEquals(gmList_LCD[0].Last_Contact_Date__c, Date.today().addDays(-1));
        
        **/

        // Update test event as Type = Meeting
        evt.Type = 'Meeting';
        SL_RecursionHelper.isUpdate = true;
        
        Test.startTest();
        update evt;
        Test.stopTest();


        // Assertion for Account.Last_Meeting_Date__c
        List<Account> acctList_LMD = new List<Account>();
        acctList_LMD = [SELECT Id, Last_Meeting_Date__c FROM Account WHERE Id = :acct.id LIMIT 1];
        // System.assert(acctList_LMD[0].Last_Meeting_Date__c != '');

        // Assertion for Group_Member__c.Last_Meeting_Date__c
        List<Group_Member__c> gmList_LMD = new List<Group_Member__c>();
        gmList_LMD = [SELECT Id, Last_Meeting_Date__c FROM Group_Member__c WHERE Id = :gm.id LIMIT 1];
        // System.assert(gmList_LMD[0].Last_Meeting_Date__c != '');

    }

}