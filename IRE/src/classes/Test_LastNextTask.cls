@isTest
private class Test_LastNextTask {
    static testMethod void mytest() {
        
        Profile p = [select id from profile where name='Standard User']; 
        User us = new User();
        us.username = 'test@test113213.com';
        us.email = 'test@test113213.com';
        us.alias = 'test';
        us.CommunityNickname = 'test';
        us.TimeZoneSidKey = 'Europe/Paris';
        us.localesidkey='en_US';
        us.languagelocalekey='en_US';
        us.emailencodingkey='UTF-8';
        us.ProfileId = p.id;
        us.FirstName = 'Test';
        us.LastName = 'User';
        // add whatever other fields are required for user creation here
        insert us;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        // add whatever other fields are required for account creation here
        insert acc;
        
        territory_grouping_code__c tgc = new territory_grouping_code__c();
        tgc.City__c = 'lombard';
        tgc.state__c = 'IL';
        tgc.POSTAL_PREFIX__c = '60148';
        tgc.Wholesaler__c = 'Wholesaler1';
        tgc.Time_Zone_Name__c = 'Timezone1';
        tgc.Territory_Grouping_Code__c = 'IL-1';
		insert tgc;
        
        territory_grouping_code__c tgc2 = new territory_grouping_code__c();
        tgc2.City__c = 'Clarendon hills';
        tgc2.state__c = 'IL';
        tgc2.POSTAL_PREFIX__c = '60514';
        tgc2.Wholesaler__c = 'Wholesaler2';
        tgc2.Time_Zone_Name__c = 'Timezone2';
        tgc2.Territory_Grouping_Code__c = 'IL-2';
		insert tgc2;
        
        list<contact> ContactList = new list<contact>();
        Contact con = new Contact();
        con.FirstName = 'Test'; // this assumes firstname is a required field on your contact records
        con.LastName = 'Contact'; // this assumes lastname is a required field on your contact records
        con.AccountId = acc.Id; // this assumes account is a required field on your contact records
        con.Title = 'Test Title'; // this is to validate your trigger
        con.MailingCity = 'lombard';
        con.mailingstate = 'IL';
        con.MailingPostalCode = '60148';
        // add whatever other fields are required for contact creation here
        ContactList.add(con);
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test'; // this assumes firstname is a required field on your contact records
        con2.LastName = 'Contact'; // this assumes lastname is a required field on your contact records
        con2.AccountId = acc.Id; // this assumes account is a required field on your contact records
        con2.Title = 'Test Title'; // this is to validate your trigger
        con2.MailingCity = 'lombard';
        con2.mailingstate = 'IL';
        con2.MailingPostalCode = '60148';
        // add whatever other fields are required for contact creation here
        ContactList.add(con2);
        
        Contact con3 = new Contact();
        con3.FirstName = 'Test'; // this assumes firstname is a required field on your contact records
        con3.LastName = 'Contact'; // this assumes lastname is a required field on your contact records
        con3.AccountId = acc.Id; // this assumes account is a required field on your contact records
        con3.Title = 'Test Title'; // this is to validate your trigger
        con3.MailingCity = 'lombard';
        con3.mailingstate = 'IL';
        con3.MailingPostalCode = '60148';
        con3.Contact_Type__c = '3rd Party Research';
        // add whatever other fields are required for contact creation here
        ContactList.add(con3);
        insert contactlist;
        
        con2.MailingCity = 'Clarendon Hills';
        con2.MailingState = 'IL';
        con2.MailingPostalCode = '60148';
        update con2;
        
        pipeline_ticket__c pipeline = new pipeline_ticket__c();
        insert pipeline;
        
        date d = date.today();
        d.addDays(10);
        
        Task u = new Task();
        u.ownerId = us.Id; // you've now successfully created your test user, time to use it on your new task
        u.whoId = con.Id; // you've now successfully created your test contact, time to use it on your new task
        u.Subject = 'Run Test Trigger';
        u.Status = 'Not Started';
        u.Priority = 'Normal';
        u.ActivityDate = d;
        u.whatid =  pipeline.id;
        insert u;
        
        System.debug('started debug');
        task t1 = new task(subject = 'Call', Status = 'Not Started', whoid = con.Id, type__c = 'QU', ActivityDate=date.parse('04/02/2015'));
        task t2 = new task(subject = 'Call', Status = 'Not Started', whoid = con.Id, type__c = 'ES', ActivityDate=d);
        task[] TasksOut = new list<task>();
        TasksOut.add(t1);
        TasksOut.add(t2);
        TasksOut.add(new task(subject = 'Call', Status = 'Not Started', whoid = con.Id, type__c = 'ES', ActivityDate=date.parse('01/02/2015')));
        TasksOut.add(new task(subject = 'Call', Status = 'Completed', whoid =  con.Id, type__c = 'ES', ActivityDate=date.parse('01/03/2015')));
        insert(TasksOut);
        
        event e1 = new event(subject = 'Meeting', durationinminutes = 30, whoid = con.Id, type__c = 'Travel', ActivityDateTime=date.parse('04/02/2015'));
        event e2 = new event(subject = 'Meeting', durationinminutes = 30, whoid = con.Id, type__c = 'Office Visit', ActivityDateTime=d);
        event e3 = new event(subject = 'Meeting', whatid = pipeline.id, durationinminutes = 30, whoid = con.Id, type__c = 'Travel', ActivityDateTime=d);
        event[] EventsOut = new list<event>();
        EventsOut.add(e1);
        EventsOut.add(e2);
        EventsOut.add(e3);
        EventsOut.add(new event(subject = 'Meeting', durationinminutes = 30, whoid = con.Id, type__c = 'Office Visit', ActivityDateTime=date.parse('01/02/2015')));
        insert(EventsOut);
        
        set<id> idSet = new set<id>();
        idSet.add(con.id);
        LastNextActivityTask TestFunctions = new LastNextActivityTask();
        TestFunctions.ClearLastNextDates(idSet);
        TestFunctions.updateAllPipelines();
        
        Scheduled_Rating_TGC newtest = new Scheduled_Rating_TGC();
        String sch = '0  00 20 ? * 1';
		system.schedule('Test', sch, newtest);
        
        scheduledBatchableLastNextTaskEvent mytest = new scheduledBatchableLastNextTaskEvent();
        String bsch = '0 00 20 ? * 1';
        system.schedule('MyTest', bsch, mytest);
        
        //Test Batch and schedule for clearing Last/Next dates
        scheduledBatchClearLastNext ClearTest = new scheduledBatchClearLastNext();
        system.schedule('ClearTest', bsch, ClearTest);
        
        BatchClearLastNext myBatch2 = new BatchClearLastNext();
		database.executeBatch(myBatch2);

        BatchTGCUpdate BatchTGCUpdateTest = new BatchTGCUpdate();
        database.executeBatch(BatchTGCUpdateTest);
    }
}