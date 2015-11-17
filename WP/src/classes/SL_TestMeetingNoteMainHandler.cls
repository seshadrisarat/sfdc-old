@isTest
private class SL_TestMeetingNoteMainHandler {
    
    @isTest static void test_MeetingNoteMain() {

        Contact objContact = new Contact(FirstName='Test', LastName='Contact', Email='praful.gadge@silverlinecrm.com');
        insert objContact; 

        Task objTask = new Task(isParent__c=true);
        insert objTask;
        
        Task objTask2 = new Task(ParentId__c=objTask.Id, OwnerId=UserInfo.getUserId());
        insert objTask2; 

        Task objTask3 = new Task(isParent__c=true);
        insert objTask3;

        Task objTask4 = new Task(isParent__c=true); 
        insert objTask4;

        TaskRelation objTaskRelation1 = new TaskRelation(TaskId=objTask4.Id,RelationId=objContact.Id);
        insert objTaskRelation1;

        Event objEvent1 = new Event(isParent__c=true,Type='Email',StartDateTime=Date.Today(),EndDateTime=Date.Today());
        insert objEvent1;

        Event objEvent2 = new Event(Subject='TestEvent', isParent__c=true, Type='Email', StartDateTime=Date.Today(), EndDateTime=Date.Today());
        insert objEvent2;

        EventRelation objEventRelation1 = new EventRelation(EventId=objEvent2.Id, RelationId=objContact.Id, IsInvitee=true);
        insert objEventRelation1;

        Account objAccount = new Account(Name='Test');
        insert objAccount;

        Attachment objAttachment = new Attachment(Name='Test Attachment', Body=Blob.valueOf('Test Data'), ParentId=objTask2.Id);
        insert objAttachment;

        PageReference PageRefTask = Page.SL_MeetingNoteTask;

        Test.setCurrentPage(PageRefTask);

        ApexPages.currentPage().getParameters().put('SL_MeetingNoteTask', 'theValue');

        ApexPages.currentPage().getParameters().put('id', objTask.Id);

        ApexPages.currentPage().getParameters().put('what_id', objAccount.Id);
        
        SL_MeetingNoteMainHandler objMeetingNoteMainTaskHandler = new SL_MeetingNoteMainHandler();

        PageReference PageRefEvent = Page.SL_MeetingNoteEvent; 

        Test.setCurrentPage(PageRefEvent);

        ApexPages.currentPage().getParameters().put('SL_MeetingNoteEvent', 'theValue');

        ApexPages.currentPage().getParameters().put('id', objEvent1.Id);

        ApexPages.currentPage().getParameters().put('who_id', objContact.Id);

        SL_MeetingNoteMainHandler objMeetingNoteMainEventHandler = new SL_MeetingNoteMainHandler();

        SL_MeetingNoteMainHandler.ActivitySobjectInnerClass objActivitySobjectInnerClass = new SL_MeetingNoteMainHandler.ActivitySobjectInnerClass(objTask, objTask);

        String jsonResult; 

        jsonResult = SL_MeetingNoteMainHandler.customDescribeFieldSet('Task', 'SL_TaskDescription', '');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.customDescribeFieldSet returned null');

        jsonResult = SL_MeetingNoteMainHandler.customDescribeFieldSet('Test', 'SL_TaskDescription', '');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.customDescribeFieldSet returned null');

        jsonResult = SL_MeetingNoteMainHandler.getExistingRecords('Select Id,WhatId, What.Type from Task', 'Task', '', '', 'Id', 'Account', true, 'LastModifiedBy');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getExistingRecords returned null');

        jsonResult = SL_MeetingNoteMainHandler.getExistingRecords('Select Id,TaskId,RelationId from TaskRelation', 'TaskRelation', '', 'External', 'Id', 'Contact', false, 'LastModifiedBy');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getExistingRecords returned null');

        jsonResult = SL_MeetingNoteMainHandler.getExistingRecords('Select Id,WhatId, What.Type from Test', 'Test', '', '', 'Id', 'Test', true, 'LastModifiedBy');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getExistingRecords returned null');

        jsonResult = SL_MeetingNoteMainHandler.getEmail('xyz');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getEmail returned null');

        List<String> tos = new List<String>();
        tos.add('praful.gadge@silverlinecrm.com');
        tos.add('nishant@silverlinecrm.com');

        List<String> ccs = new List<String>();
        tos.add('hemant@silverlinecrm.com');   

        List<Id> lstContactAndUserIDs = new List<Id>();
        lstContactAndUserIDs.add(objContact.Id);
        lstContactAndUserIDs.add(UserInfo.getUserId());

        jsonResult = SL_MeetingNoteMainHandler.sendEmail(UserInfo.getUserId(),'Test Email','Test email Body',tos,ccs,new List<Id>(),false,objAccount.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.sendEmail returned null');

        jsonResult = SL_MeetingNoteMainHandler.sendEmail(UserInfo.getUserId(),'Test Email','Test email Body',tos,ccs,lstContactAndUserIDs,true,objAccount.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.sendEmail returned null');

        List<Id> lstAccountIDs = new List<Id>();
        lstAccountIDs.add(objAccount.Id);

        jsonResult = SL_MeetingNoteMainHandler.sendEmail(UserInfo.getUserId(),'Test Email','Test email Body',tos,ccs,lstAccountIDs,true,objAccount.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.sendEmail returned null');

        List<String> lstFields = new List<String>{'Subject', 'CallType', 'CallResult', 'Status', 'Type'};
        jsonResult = SL_MeetingNoteMainHandler.describeSearchFields('Task', lstFields);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.describeSearchFields returned null');

        jsonResult = SL_MeetingNoteMainHandler.describeSearchFields('Test', lstFields);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.describeSearchFields returned null');
        
        jsonResult = SL_MeetingNoteMainHandler.insertWithDMLOption('[{"Id":"'+objEventRelation1.Id+'"}]', '[{"RelationId":"'+objEventRelation1.RelationId+'","EventId":"'+objEventRelation1.EventId+'","IsInvitee":true,"IsParent":false,"Status":"Declined"}]');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.insertWithDMLOption returned null');

        jsonResult = SL_MeetingNoteMainHandler.insertWithDMLOption('testExistingInvitees', 'testAddedInvitees');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.insertWithDMLOption returned null');

    } 
}