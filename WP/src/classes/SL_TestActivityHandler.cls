@isTest
public class SL_TestActivityHandler {

    static String strAccountRecordTypeId = [select id from recordtype where sObjectType = 'Account' AND DeveloperName = 'Intermediary'].Id;
    
    static testMethod void unitTestCode() {

        Fund__c objFund = new Fund__c(Name = 'Test Fund 1');
        insert objFund;
        
        Fundraising_Opportunity__c objFundRaisingOpportunity = new Fundraising_Opportunity__c(Name = 'Test FundRaisingOpportunity 1', Fund__c = objFund.Id);
        insert objFundRaisingOpportunity;
        
        Account objAccount = new Account(Name = 'Test Account', RecordTypeId = strAccountRecordTypeId);
        insert objAccount;
        
        Event objEvent = new Event();
        objEvent.IsParent__c = true;
        objEvent.StartDateTime = date.today();
        objEvent.EndDateTime = date.today();
        objEvent.WhatId = objAccount.Id;
        insert objEvent;

        Event objEvent1 = new Event();
        objEvent1.StartDateTime = date.today();
        objEvent1.EndDateTime = date.today();
        objEvent1.ParentId__c = objEvent.Id;
        objEvent1.WhatId = objAccount.Id;
        insert objEvent1;
		
		Event objEvent2 = new Event();
        objEvent2.IsParent__c = true;
        objEvent2.StartDateTime = date.today();
        objEvent2.EndDateTime = date.today();
        objEvent2.WhatId = objFundRaisingOpportunity.Id;
        insert objEvent2;
		
        objEvent1.Subject = 'Test Event Subject';
        update objEvent1;

        delete objEvent;

        SL_ActivityHandler.run = true;

        Task objTask = new Task();
        objTask.IsParent__c = true;
        insert objTask;

        Task objTask1 = new Task();
        objTask1.ParentId__c = objTask.Id;
        insert objTask1;

        objTask.Subject = 'Test Task Subject';
        objTask.Status = 'In Progress';
        update objTask;
		
		SL_ActivityHandler.run = true;
		
		objTask1.Subject = 'Test Task Subject1';
		objTask1.Status = 'In Progress';
		update objTask1;
		
		SL_ActivityHandler.run = true;
		objTask1.Status = 'Completed';
		update objTask1;
		
        delete objTask;
    }
    
     static testMethod void unitTestCodeTaskTriggerandTearSheet() {

        Account objAccount  = new Account(Name = 'Test Account');
        insert objAccount;
        
        Event objEvent = new Event();
        objEvent.IsParent__c = true;
        objEvent.StartDateTime = date.today();
        objEvent.EndDateTime = date.today();
        objEvent.WhatId = objAccount.Id;
        insert objEvent;

        Event objEvent1 = new Event();
        objEvent1.StartDateTime = date.today();
        objEvent1.EndDateTime = date.today();
        objEvent1.ParentId__c = objEvent.Id;
        insert objEvent1;

        delete objEvent;

        Task objTask = new Task();
        objTask.IsParent__c = true;
        insert objTask;

        Task objTask1 = new Task();
        objTask1.ParentId__c = objTask.Id;
        insert objTask1;

        delete objTask;

        SL_MN_Related_List__c customSetting = new SL_MN_Related_List__c(Close_Related_Activities__c=true);
        insert customSetting;

        List<Task> lstParentTasks = new List<Task>{ 
                                                    new Task(Subject='Test1', IsParent__c=true, Status='Completed'),
                                                    new Task(Subject='Test2', IsParent__c=true, Status='Not Started')
                                                  };
        insert lstParentTasks;

        List<Task> lstChildTasks = new List<Task>{ 
                                                    new Task(Subject='Test3', IsParent__c=false, ParentId__c=lstParentTasks[0].Id, Status='Completed'),
                                                    new Task(Subject='Test4', IsParent__c=false, ParentId__c=lstParentTasks[0].Id, Status='Completed'),
                                                    new Task(Subject='Test5', IsParent__c=false, ParentId__c=lstParentTasks[1].Id, Status='Not Started'),
                                                    new Task(Subject='Test6', IsParent__c=false, ParentId__c=lstParentTasks[1].Id, Status='Not Started')
                                                  };
        insert lstChildTasks;

        lstChildTasks[2].Status = 'Completed';
        update lstChildTasks[2];

        System.assertEquals(lstChildTasks[2].Status, 'Completed');

        lstParentTasks[1].Status = 'Completed';
        update lstParentTasks[1];
        
        System.assertEquals(lstParentTasks[1].Status, 'Completed');

    }
}