@isTest
private class SL_TestMeetingNoteMainHandler {
    
    @isTest static void test_MeetingNoteMain() {

        SL_MeetingNoteMainHandler objMeetingNoteMainHandler = new SL_MeetingNoteMainHandler();

        //SL_MeetingNoteMainHandler.ActivitySobjectInnerClass objActivitySobjectInnerClass = new SL_MeetingNoteMainHandler.ActivitySobjectInnerClass();

        Contact objContact = new Contact(LastName='Test Contact');
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

        Account objAccount = new Account(Name='Test');
        insert objAccount;

        Attachment objAttachment = new Attachment(Name='Test Attachment', Body=Blob.valueOf('Test Data'), ParentId=objTask2.Id);
        insert objAttachment;

        String jsonResult = SL_MeetingNoteMainHandler.getPicklistValuesCustom('Task','Status'); 
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getPicklistValuesCustom returned null');
        
        jsonResult = SL_MeetingNoteMainHandler.uploadAttachment(objTask2.ParentId__c, objAttachment.Body.toString(), objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.uploadAttachment returned null');
    
        jsonResult = SL_MeetingNoteMainHandler.uploadAttachment(objTask2.ParentId__c, objAttachment.Body.toString(), objAttachment.Name, (String) UserInfo.getUserId(), null);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.uploadAttachment returned null');

        jsonResult = SL_MeetingNoteMainHandler.uploadAttachment(objTask2.ParentId__c, null, objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.uploadAttachment returned null');

        jsonResult = SL_MeetingNoteMainHandler.uploadAttachment(null, null, objAttachment.Name, (String) UserInfo.getUserId(), objAttachment.Id);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.uploadAttachment returned null');
        
        jsonResult = SL_MeetingNoteMainHandler.getDefaultRecordType('Account');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getDefaultRecordType returned null');

        jsonResult = SL_MeetingNoteMainHandler.getExistingRecords('Select Id,WhatId, What.Type from Task', 'Task', '', 'Id', 'Account');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getExistingRecords returned null');

        jsonResult = SL_MeetingNoteMainHandler.getExistingRecords('Select Id,TaskId,RelationId from TaskRelation', 'TaskRelation', 'External', 'Id', 'Contact');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getExistingRecords returned null');

        jsonResult = SL_MeetingNoteMainHandler.getCreatableFieldsSOQL('Event');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getCreatableFieldsSOQL returned null');

        jsonResult = SL_MeetingNoteMainHandler.getEmail('xyz');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getEmail returned null');

        List<String> tos = new List<String>();
        tos.add('praful.gadge@silverlinecrm.com');
        tos.add('nishant@silverlinecrm.com');

        List<String> ccs = new List<String>();
        tos.add('hemant@silverlinecrm.com');        

        jsonResult = SL_MeetingNoteMainHandler.sendEmail(UserInfo.getUserId(),'Test Email','Test email Body',tos,ccs);
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getEmail returned null');

        jsonResult = SL_MeetingNoteMainHandler.mnQuery('Task','SL_TaskDescription','where IsParent__c=true');
        System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.mnQuery returned null');

        List<Contact> lstContact = new List<Contact>{
                                                        new Contact(FirstName = 'Test1', LastName = 'Test Contact 1', Email = 'praful.gadge@silverlinecrm.com'),
                                                        new Contact(FirstName = 'Test1', LastName = 'Test Contact 2', Email = 'nishant@silverlinecrm.com')
                                                    };
        insert lstContact; 
        //jsonResult = SL_MeetingNoteMainHandler.getCurrencySymbol();
        //System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getCurrencySymbol returned null');

        //jsonResult = SL_MeetingNoteMainHandler.getDateFormat();  
        //System.assertNotEquals(null, jsonResult, 'SL_MeetingNoteMainHandler.getDateFormat returned null');
    }
}