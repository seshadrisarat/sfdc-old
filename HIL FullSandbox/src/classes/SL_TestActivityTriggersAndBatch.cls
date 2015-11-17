@isTest
private class SL_TestActivityTriggersAndBatch {
//Test save method
    Private Static Id idRecordTypePerson = [Select Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Person'].Id;
    Private Static Id idRecordTypeBusiness = [Select Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Business'].Id;

    static testMethod void SL_TestTaskInsert_PersonAccount() 
    {
        // Create test relationship group record
        Relationship_Group__c rg = new Relationship_Group__c(Name = 'Test RG');
        insert rg;

        Account objAccount = new Account(LastName = 'Test', RecordTypeId = idRecordTypePerson);
        insert objAccount;

        // Create test group member record
        Group_Member__c gm = new  Group_Member__c(Client_Prospect__c = objAccount.Id, Relationship_Group__c = rg.Id);
        insert gm;

        objAccount.Primary_Relationship_Group__c = rg.Id;
        update objAccount;

        Contact objContact = [Select Id From Contact Where AccountId = :objAccount.Id LIMIT 1];
        
        Test.startTest();

        Task objTask = new Task(WhoId = objContact.Id, Subject = 'Test Subject', Type = 'Call', ActivityDate = Date.Today(), Count_Towards_SLA__c = true, Status = 'Completed');
        insert objTask;
            
        objTask.Type = 'Meeting';
        objTask.ActivityDate = Date.Today();
        SL_RecursionHelper.isUpdate = true;
        objTask.WhatId = objAccount.Id;

        update objTask;

        SL_RecursionHelper.isUpdate = true;

        delete objTask;

        undelete objTask;

         
        SL_RecursionHelper.setisDelete(true);
        SL_RecursionHelper.getisDelete();

        SL_RecursionHelper.setisUpdate(true);
        SL_RecursionHelper.getisUpdate();

        Test.stopTest();
        system.assertEquals([Select Last_Meeting_Date__c From Account Limit 1].Last_Meeting_Date__c, Date.Today());
    }
    
    static testMethod void SL_TestActivityDetail_cancelEvent() 
    {
        
        Account objAccount = new Account();
        objAccount.LastName = 'Test -1';
        objAccount.RecordTypeId = idRecordTypePerson;
        insert objAccount;
        
        
        Contact objContact = [Select Id From Contact Where AccountId = :objAccount.Id LIMIT 1];

        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhoId = objContact.Id;
        objEvent.WhatId = objAccount.Id;
        objEvent.StartDateTime = Datetime.now().addDays(-2);
        objEvent.EndDateTime = Datetime.now().addDays(-1);
        insert objEvent;

        Test.startTest();
        objEvent.Type = 'Meeting';
        SL_RecursionHelper.isUpdate = true;
        update objEvent;
        delete objEvent;
        SL_RecursionHelper.isUpdate = true;
        undelete objEvent;
        Test.stopTest();
        
        //system.assertEquals([Select Last_Meeting_Date__c From Account Limit 1].Last_Meeting_Date__c, Date.Today().addDays(-1));
    }

    static testMethod void test_Batch()
    {
        Test.startTest();
        
        // Create test relationship group record
        Relationship_Group__c rg = new Relationship_Group__c(Name = 'Test RG');
        insert rg;

        Account objAccount = new Account(LastName = 'Test');
        insert objAccount;

        // Create test group member record
        Group_Member__c gm = new  Group_Member__c(Client_Prospect__c = objAccount.Id, Relationship_Group__c = rg.Id);
        insert gm;

        objAccount.Primary_Relationship_Group__c = rg.Id;
        update objAccount;

        Contact objContact = [Select Id From Contact Where AccountId = :objAccount.Id LIMIT 1];


        List<Event> lstEvent = new List<Event>{new Event(Subject = 'Test Subject', Type = 'Meeting',  WhatId = objAccount.Id, StartDateTime = Datetime.now().addDays(-2), EndDateTime = Datetime.now().addDays(-1)),
                                               new Event(Subject = 'Test Subject', Type = 'Meeting',  WhoId = objContact.Id, StartDateTime = Datetime.now().addDays(-2), EndDateTime = Datetime.now().addDays(-1)),
                                               new Event(Subject = 'Test Subject', Type = 'Meeting',  WhoId = objContact.Id, StartDateTime = Datetime.now().addDays(-2), EndDateTime = Datetime.now().addDays(+3))
                                              };

        insert lstEvent;

        Database.executeBatch(new Sl_BatchUpdateLastMeetingDate());

        Test.stopTest();
        
        system.assertNotEquals([Select Last_Meeting_Date__c From Account Limit 1].Last_Meeting_Date__c, Date.Today().addDays(-1));
        system.assertEquals([Select Last_Meeting_Date__c From Account Limit 1].Last_Meeting_Date__c, Date.Today().addDays(3));
     
    }
    
    static testMethod void SL_TestBatchScheduler_LastMeetingDate() 
    {
        Test.startTest();

        SL_BatchScheduler_LastMeetingDate batchSchedule = new SL_BatchScheduler_LastMeetingDate();
        String scheduleBatch = '0 0 * * * ?';
        System.schedule('Update meeting Date', scheduleBatch, batchSchedule);

        Test.stopTest();
    }
    static testMethod void SL_TestBatchScheduler() 
    {
        Test.startTest();

        SL_Schedule_BatchUpdateLastMeetingDate batchSchedule = new SL_Schedule_BatchUpdateLastMeetingDate();
        
        Test.stopTest();
    }
    
    static testMethod void checkForNoteCreationFromEvent()
    {
        Account objAccount = new Account();
        objAccount.LastName = 'Test -1';
        objAccount.RecordTypeId = idRecordTypePerson;
        insert objAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User objUser = new User(Alias = 'User111', Email='user1@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='user1kj1kj.212@user.com');
        insert objUser;
        
        Rep_Code__c objRepcode = new Rep_Code__c(Name = 'Test1', Rep_Code__c = '112');
        insert objRepcode;
        
        Rep_Code_User__c objRepUser = new Rep_Code_User__c(Name = 'Test', Rep_Code__c = objRepcode.Id, User__c = objUser.Id);
        insert objRepUser;
        
        Relationship_Group__c rg = new Relationship_Group__c(Name = 'Test RG', Rep_Code__c = objRepcode.Id);
        insert rg;
        
        Group_Member__c gm = new  Group_Member__c(Client_Prospect__c = objAccount.Id, Relationship_Group__c = rg.Id);
        insert gm;
        
        Event objEvent = new Event();
        objEvent.Subject = 'Test Subject';
        objEvent.WhatId = objAccount.Id;
        objEvent.StartDateTime = Datetime.now().addDays(-2);
        objEvent.EndDateTime = Datetime.now().addDays(-1);
        objEvent.OwnerId = objUser.Id;
        insert objEvent;
    }
    
    static testMethod void checkForNoteCreationFromTask()
    {
        
        Account objAccount = new Account();
        objAccount.LastName = 'Test -1';
        objAccount.RecordTypeId = idRecordTypePerson;
        insert objAccount;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User objUser = new User(Alias = 'User111', Email='user1@user.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='user1kj1kj.212@user.com');
        insert objUser;
        
        Rep_Code__c objRepcode = new Rep_Code__c(Name = 'Test1', Rep_Code__c = '112');
        insert objRepcode;
        
        Rep_Code_User__c objRepUser = new Rep_Code_User__c(Name = 'Test', Rep_Code__c = objRepcode.Id, User__c = objUser.Id);
        insert objRepUser;
        
        Relationship_Group__c rg = new Relationship_Group__c(Name = 'Test RG', Rep_Code__c = objRepcode.Id);
        insert rg;
        
        Group_Member__c gm = new  Group_Member__c(Client_Prospect__c = objAccount.Id, Relationship_Group__c = rg.Id);
        insert gm; 
                
        Task objTask = new Task(Subject = 'Test Subject', Type = 'Call', ActivityDate = Date.Today(), WhatId = objAccount.Id, Status = 'Completed', OwnerId = objUser.Id);
        insert objTask;
    }
}