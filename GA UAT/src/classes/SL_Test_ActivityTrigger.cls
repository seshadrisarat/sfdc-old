/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class SL_Test_ActivityTrigger {
    
    // test method for Opportunity Rollup 
    static testMethod void testTaskEventTrigger() {
        
        SL_TaskHandler objTaskHandler = new SL_TaskHandler();
        
        //Creating opportunity objects for creating tasks and events for it
        Account objAccount = new Account(Name = 'TestAccount', Status__c = 'Monitor', Source__c = 'Other', Description = 'TestAccount', Nearest_Metropolitan_City__c = 'Bangalore');
        insert objAccount;
        
        //Creating a task for the Account and inserting
        Task objTaskTest1 = new Task(Subject = 'Call', ActivityDate = Date.today() + 1, WhatId = objAccount.Id, Description = 'TestTask-02', Status = 'In Progress', Priority = 'Normal', 
                                     Material_Interaction__c = true,Notify_Deal_Team__c = true);
        insert objTaskTest1;
        
        //Creating an event for the Account and inserting
        Event objEventTest1 = new Event(Subject = 'Call', ActivityDate = Date.today(), StartDateTime = DateTime.now() + 2, EndDateTime = DateTime.now() + 4, WhatId = objAccount.Id, Description = 'TestEvent-02',
                                       Material_Interaction__c = true);
        insert objEventTest1;
        
        //Querying the corresponding task record
        Task objTask = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Task WHERE Id =: objTaskTest1.id];
        //Querying the corresponding Event record
        Event objEvent = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Event WHERE Id =: objEventTest1.id];
        
        //String that is updated in Material_Interaction_Notes__c field of Account
        String MINote =objEvent.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.month()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.month()) : '0' + String.valueOf(objEvent.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.day()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.day()) : '0' + String.valueOf(objEvent.ActivityDate.day())) + ' - ' + objEvent.Subject + ' (' + (objEvent.Owner.Alias == null ? '' : objEvent.Owner.Alias) + ')' + '\n\n' + objTask.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.month()).length())) == 2 ? String.valueOf(objTask.ActivityDate.month()) : '0' + String.valueOf(objTask.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.day()).length())) == 2 ? String.valueOf(objTask.ActivityDate.day()) : '0' + String.valueOf(objTask.ActivityDate.day())) + ' - ' + objTask.Subject + ' (' + (objTask.Owner.Alias == null ? '' : objTask.Owner.Alias) + ')' ;
        //system.assertEquals([Select Material_Interaction_Notes__c from Account where id =: objAccount.Id].Material_Interaction_Notes__c,MINote);
        
        //Updating the task record
        objTaskTest1.Subject = 'TaskTestSubject1';
        update objTaskTest1;
        
        //Querying the corresponding task record
        objTask = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Task WHERE Id =: objTaskTest1.id];
        
        //String that is updated in Material_Interaction_Notes__c field of Account
        MINote =objEvent.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.month()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.month()) : '0' + String.valueOf(objEvent.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.day()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.day()) : '0' + String.valueOf(objEvent.ActivityDate.day())) + ' - ' + objEvent.Subject + ' (' + (objEvent.Owner.Alias == null ? '' : objEvent.Owner.Alias) + ')' + '\n\n' + objTask.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.month()).length())) == 2 ? String.valueOf(objTask.ActivityDate.month()) : '0' + String.valueOf(objTask.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.day()).length())) == 2 ? String.valueOf(objTask.ActivityDate.day()) : '0' + String.valueOf(objTask.ActivityDate.day())) + ' - ' + objTask.Subject + ' (' + (objTask.Owner.Alias == null ? '' : objTask.Owner.Alias) + ')' ;
        
        //system.assertEquals([Select Material_Interaction_Notes__c from Account where id =: objAccount.Id].Material_Interaction_Notes__c,MINote);
               
        //Deleting the event record
        delete objEventTest1;
        
        //String that is updated in Material_Interaction_Notes__c field of Account
        MINote = objTask.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.month()).length())) == 2 ? String.valueOf(objTask.ActivityDate.month()) : '0' + String.valueOf(objTask.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.day()).length())) == 2 ? String.valueOf(objTask.ActivityDate.day()) : '0' + String.valueOf(objTask.ActivityDate.day())) + ' - ' + objTask.Subject + ' (' + (objTask.Owner.Alias == null ? '' : objTask.Owner.Alias) + ')' ;
        
        //system.assertEquals([Select Material_Interaction_Notes__c from Account where id =: objAccount.Id].Material_Interaction_Notes__c,MINote);
        
        /* START : GA-5: Added By Sandeep*/
        Commitment_Type__c objCommitmentType = new Commitment_Type__c(Name = 'test');
        insert objCommitmentType;
        
        //Creating opportunity objects for creating tasks and events for it
        list<Opportunity> lstOpportunity = new list<Opportunity>(); 
        Opportunity objOpportunity = new Opportunity(Name = 'TestOpportunity', StageName = 'Passed', CloseDate = Date.today(), AccountId = objAccount.Id, Commitment_Type__c = objCommitmentType.Id);
        lstOpportunity.add(objOpportunity);
        
        Opportunity objOpportunityTest = new Opportunity(Name = 'TestOpportunity2', StageName = 'Passed', CloseDate = Date.today(), AccountId = objAccount.Id, Commitment_Type__c= objCommitmentType.Id);
        lstOpportunity.add(objOpportunityTest);
        
        /* END : GA-5: Added By Sandeep*/
        
        insert lstOpportunity;       //inserting the list of opportunity
        
        //Creating task records for the Opportunity records
        List<Task> lstTask = new List<Task>();    //list of task to insert
        objTaskTest1 = new Task(Subject = 'Call', ActivityDate = Date.today() + 1, WhatId = lstOpportunity[0].Id, Description = 'TestTask-02', Status = 'In Progress', Priority = 'Normal', 
                                     Material_Interaction__c = true,Notify_Deal_Team__c = true);
        lstTask.add(objTaskTest1);
        
        if(lstTask.size() > 0)   //inserting the list of task
            insert lstTask;        
        
        //Creating Event records for the Opportunity records
        objEventTest1 = new Event(Subject = 'Call', ActivityDate = Date.today(), StartDateTime = DateTime.now() + 2, EndDateTime = DateTime.now() + 4, WhatId = lstOpportunity[0].Id, Description = 'TestEvent-02',
                                       Material_Interaction__c = true);
        insert objEventTest1;
        
        //Querying the corresponding task record
        objTask = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Task WHERE Id =: objTaskTest1.id];
        //Querying the corresponding Event record
        objEvent = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Event WHERE Id =: objEventTest1.id];
        
        //String that is updated in Material_Interaction_Notes__c field of Opportunity
        MINote =objEvent.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.month()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.month()) : '0' + String.valueOf(objEvent.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.day()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.day()) : '0' + String.valueOf(objEvent.ActivityDate.day())) + ' - ' + objEvent.Subject + ': ' +(objEvent.Description == null ? '' : objEvent.Description) + ' (' + (objEvent.Owner.Alias == null ? '' : objEvent.Owner.Alias) + ')' + '\n\n' + objTask.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.month()).length())) == 2 ? String.valueOf(objTask.ActivityDate.month()) : '0' + String.valueOf(objTask.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objTask.ActivityDate.day()).length())) == 2 ? String.valueOf(objTask.ActivityDate.day()) : '0' + String.valueOf(objTask.ActivityDate.day())) + ' - ' + objTask.Subject +  ': ' + (objTask.Description == null ? '' : objTask.Description) + ' (' + (objTask.Owner.Alias == null ? '' : objTask.Owner.Alias) + ')' ;
        //system.assertEquals([Select Material_Interaction_Notes__c from Opportunity where id =: lstOpportunity[0].Id].Material_Interaction_Notes__c,MINote);
        
        //Updating corresponding task record
        objTaskTest1.Subject = 'TaskTestSubject1';
        objTaskTest1.ActivityDate = date.today() + 5;
        update objTaskTest1;
        
        MINote = objTaskTest1.ActivityDate.year() + '-' + objTaskTest1.ActivityDate.month() + '-' + objTaskTest1.ActivityDate.day() + ' - ' + objTaskTest1.Subject +  ': ' + (objTaskTest1.Description == null ? '' : objTaskTest1.Description) + '(' + (objTask.Owner.Alias == null ? '' : objTask.Owner.Alias) + ')' ;
        
        //Deleting corresponding task record
        delete objTaskTest1;
        
        list<Event> lstEvent = new List<Event>();
        //Creating event records for the Opportunity records
        Event objEventTest = new Event(Subject = 'Call', ActivityDate = Date.today(), StartDateTime = DateTime.now() + 1, EndDateTime = DateTime.now() + 4, WhatId = lstOpportunity[1].Id, Description = 'TestEvent-02',
                                       Material_Interaction__c = true);
        lstEvent.add(objEventTest);
        
        if(lstEvent.size() > 0)    //inserting the list of Events
            insert lstEvent;
        
        //Querying the corresponding Event record
        objEvent = [SELECT ActivityDate, Subject, Owner.Alias, Description FROM Event WHERE Id =: objEventTest.id];
        MINote = objEvent.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.month()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.month()) : '0' + String.valueOf(objEvent.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objEvent.ActivityDate.day()).length())) == 2 ? String.valueOf(objEvent.ActivityDate.day()) : '0' + String.valueOf(objEvent.ActivityDate.day())) + ' - ' + objEvent.Subject +  ': ' + (objEvent.Description == null ? '' : objEvent.Description)+ ' (' + (objEvent.Owner.Alias == null ? '' : objEvent.Owner.Alias) + ')' ;
        
        //system.assertEquals([Select Material_Interaction_Notes__c from Opportunity where id =: lstOpportunity[1].Id].Material_Interaction_Notes__c,MINote);
        
        //Updating corresponding event record
        objEventTest.Description = 'Test1';
        objEventTest.ActivityDate = Date.today() + 1;
        update objEventTest;
        
        MINote = objEventTest.ActivityDate.year() + '-' + (Integer.valueOf((String.valueOf(objEventTest.ActivityDate.month()).length())) == 2 ? String.valueOf(objEventTest.ActivityDate.month()) : '0' + String.valueOf(objEventTest.ActivityDate.month())) + '-' + (Integer.valueOf((String.valueOf(objEventTest.ActivityDate.day()).length())) == 2 ? String.valueOf(objEventTest.ActivityDate.day()) : '0' + String.valueOf(objEventTest.ActivityDate.day())) + ' - ' + objEventTest.Subject + ': ' + (objEventTest.Description == null ? '' : objEventTest.Description) + ' (' + (objEvent.Owner.Alias == null ? '' : objEvent.Owner.Alias) + ')' ;
        //system.assertEquals([Select Material_Interaction_Notes__c from Opportunity where id =: lstOpportunity[1].Id].Material_Interaction_Notes__c,MINote);
        
        //Deleting corresponding event record
        delete objEventTest;
        //system.assertEquals([Select Material_Interaction_Notes__c from Opportunity where id =: lstOpportunity[1].Id].Material_Interaction_Notes__c,null);
                                    
    }
    
    // Existing Test Code Took from Test_MostRecentCommentsHandler.cls
    static testMethod void myTestTrigger(){
    
        SL_TaskHandler objTaskHandler = new SL_TaskHandler();
    
        Account objAccount = new Account();
        objAccount.Name = 'TestAccount';
        objAccount.Status__c = 'Monitor';
        objAccount.Source__c = 'Other';
        objAccount.Description = 'TestAccount';
        objAccount.Nearest_Metropolitan_City__c = 'Bangalore';
        insert objAccount;
        
        Event objEvent1 = new Event();
        objEvent1.Subject = 'TestEvent-02';
        objEvent1.Type = 'Other';
        objEvent1.StartDateTime = Date.today();
        objEvent1.EndDateTime = Date.today()+1;
        objEvent1.WhatId = objAccount.Id;
        objEvent1.Description = 'TestEvent-02';
        insert objEvent1;
        
        Task objTask1 = new Task();
        objTask1.Subject = 'TestTask-02';
        objTask1.Type = 'Status Note';
        objTask1.Status = 'Completed';
        objTask1.Priority = 'Normal';
        objTask1.ActivityDate = Date.today()-1;
        objTask1.WhatId = objAccount.Id;
        objTask1.Description = 'TestTask-02';
        insert objTask1;
        
        objEvent1.Description = 'Test1';
        objEvent1.ActivityDate = Date.today()+4;
        update objEvent1;
        
        objTask1.ActivityDate = date.today()+5;
        update objTask1;
        
        delete objTask1;
        delete objEvent1;
        
        ts2__Job__c objJob = new ts2__Job__c(Name = 'Test' , ts2__Job_Function__c = 'Administrator',ts2__Department__c = 'Business Service', ts2__Location__c = 'New York',
                                                ts2__Date_Posted__c = Date.Today());
        insert objJob;
        
        Task objTask5 = new Task(Subject = 'TestTask-02', Type = 'Status Note', Status = 'Completed', Priority = 'Normal',ActivityDate = Date.today()-1,
                                        WhatId = objJob.Id, Description = 'TestTask-02');
        insert objTask5;
        objTask5.Subject = '';
        update objTask5;
        delete objTask5;
    }
}