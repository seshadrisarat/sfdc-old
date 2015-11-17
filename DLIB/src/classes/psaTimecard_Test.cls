/****************************************************************************************
Name            : psaTimecard_Test
Author          : Julia Kolesnik
Created Date    : January 21, 2014
Description     : Test class for psaTimecard.trigger and psaTimecardHandler.cls
******************************************************************************************/
@isTest
private class psaTimecard_Test {

    static testMethod void test_Rollups() {
        pse__Region__c region = new pse__Region__c(Name='Test region', pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
        insert region;
        
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'TEST';
        proj.pse__Region__c = region.Id;
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        insert proj;
        
        pse__Project_Phase__c phase = new pse__Project_Phase__c();
        phase.pse__Project__c = proj.Id;
        insert phase;
        
        Contact resource = new Contact();
        resource.LastName = 'Test LN';
        resource.pse__Is_Resource_Active__c = true;
        resource.pse__Is_Resource__c = true;
        insert resource;
        
        insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Resource__c=resource.Id, pse__Timecard_Entry__c=true, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c = true);
        insert new pse__Permission_Control__c(pse__User__c=UserInfo.getUserId(), pse__Project__c= proj.Id, pse__Timecard_Ops_Edit__c = true, pse__Staffing__c=true);
        
        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = date.today().addDays(-7);
        schedule.pse__End_Date__c = date.today().addDays(1);
        schedule.pse__Monday_Hours__c = 8;
        schedule.pse__Tuesday_Hours__c = 8;
        schedule.pse__Wednesday_Hours__c = 8;
        schedule.pse__Thursday_Hours__c = 8;
        schedule.pse__Friday_Hours__c = 8;
        insert schedule;
        
        pse__Assignment__c assignment = new pse__Assignment__c();
        assignment.pse__Project__c = proj.Id;
        assignment.pse__Resource__c = resource.Id;
        assignment.pse__Bill_Rate__c = 15;
        assignment.pse__Is_Billable__c = true;
        assignment.pse__Schedule__c = schedule.Id;
        insert assignment;
        
        pse__Milestone__c parentmilestone = new pse__Milestone__c();
        parentmilestone.Actual_Hours__c = 4;
        parentmilestone.pse__Project__c = proj.Id;
        parentmilestone.pse__Default_Bill_Rate__c = 10;
        parentmilestone.pse__Target_Date__c = date.today();
        parentmilestone.pse__Actual_Date__c = Date.today();
        parentmilestone.Project_Phase__c = phase.Id;
        parentmilestone.pse__Status__c = 'Open';
        parentmilestone.RecordTypeId = psaUtils.idRTParentTask;
        insert parentmilestone;
        
        pse__Milestone__c childmilestone = new pse__Milestone__c();
        childmilestone.Actual_Hours__c = 4;
        childmilestone.pse__Project__c = proj.Id;
        childmilestone.Parent_Milestone__c = parentmilestone.Id;
        childmilestone.pse__Actual_Date__c = Date.today();
        childmilestone.pse__Target_Date__c = date.today();
        childmilestone.pse__Status__c = 'Open';
        childmilestone.Project_Phase__c = phase.Id;
        childmilestone.RecordTypeId = psaUtils.idRTChildTask;
        insert childmilestone;
        
        list<pse__Timecard_Header__c> lstTimecards = new list<pse__Timecard_Header__c>();
        
        pse__Timecard_Header__c tcBillable = new pse__Timecard_Header__c(pse__Billable__c = true, pse__Daily_Bill_Rate__c = false, pse__Project_Phase_Object__c = phase.Id, pse__Project__c = proj.Id, pse__Resource__c = resource.Id, pse__Assignment__c = assignment.Id);
        tcBillable.pse__Monday_Hours__c  = 2;
        tcBillable.pse__Tuesday_Hours__c = 2;
        tcBillable.pse__Bill_Rate__c = 15;
        tcBillable.pse__Start_Date__c = date.today().addDays(-6);
        tcBillable.pse__End_Date__c = date.today();
        tcBillable.pse__Status__c = 'Open';
        tcBillable.pse__Milestone__c = childmilestone.id;
        lstTimecards.add(tcBillable);
        
        pse__Timecard_Header__c tcNonBillable = new pse__Timecard_Header__c(pse__Billable__c = false, pse__Daily_Bill_Rate__c = false, pse__Project_Phase_Object__c = phase.Id, pse__Project__c = proj.Id, pse__Resource__c = resource.Id , pse__Assignment__c = assignment.Id);
        tcNonBillable.pse__Monday_Hours__c  = 3;
        tcNonBillable.pse__Tuesday_Hours__c = 4;
        tcNonBillable.pse__Bill_Rate__c = 15;
        tcNonBillable.pse__Start_Date__c = date.today().addDays(-6);
        tcNonBillable.pse__End_Date__c = date.today();
        tcNonBillable.pse__Status__c = 'Open';
        tcNonBillable.pse__Milestone__c = childmilestone.id;
        lstTimecards.add(tcNonBillable);
        
        pse__Timecard_Header__c tcNewBillable = new pse__Timecard_Header__c(pse__Billable__c = true, pse__Daily_Bill_Rate__c = false, pse__Project_Phase_Object__c = phase.Id, pse__Project__c = proj.Id, pse__Resource__c = resource.Id , pse__Assignment__c = assignment.Id);
        tcNewBillable.pse__Monday_Hours__c  = 3;
        tcNewBillable.pse__Tuesday_Hours__c = 4;
        tcNewBillable.pse__Bill_Rate__c = 15;
        tcNewBillable.pse__Start_Date__c = date.today().addDays(-6);
        tcNewBillable.pse__End_Date__c = date.today();
        tcNewBillable.pse__Status__c = 'Open';
        tcNewBillable.pse__Milestone__c = childmilestone.id;
        lstTimecards.add(tcNewBillable);
        
        Test.startTest();
        
        insert lstTimecards;
        psaTimecardHandler.isDone = false;
        
        list<pse__Timecard__c> lstTimecardSplits = new list<pse__Timecard__c>();
        for (pse__Timecard__c item:[select Id, pse__Status__c FROM pse__Timecard__c WHERE pse__Timecard_Header__c IN :lstTimecards]) {
            item.pse__Status__c = 'Approved';
            lstTimecardSplits.add(item);
        }
        
        if (lstTimecardSplits.size()>0) update lstTimecardSplits;
        
        lstTimecards[0].pse__Submitted__c = true;
        lstTimecards[1].pse__Submitted__c = true;
        //update lstTimecards;
        psaTimecardHandler.isDone = false;
        
        lstTimecards[0].pse__Approved__c = true;
        lstTimecards[1].pse__Approved__c = true;
        lstTimecards[2].pse__Submitted__c = true;
        //update lstTimecards;
        psaTimecardHandler.isDone = false;
        
        /*for (pse__Project_Phase__c item:[Select Id, Actual_Hours_Billable__c, Actual_Hours_Non_Billable__c, Total_Billable_Amount__c 
                                        FROM pse__Project_Phase__c WHERE Id=:phase.Id limit 1]) 
        {
            system.assertEquals(item.Actual_Hours_Billable__c,4);
            system.assertEquals(item.Actual_Hours_Non_Billable__c,7);
            system.assertEquals(item.Total_Billable_Amount__c,60);
        }*/
        
        lstTimecards[2].pse__Approved__c = true;
        update lstTimecards[2];
        psaTimecardHandler.isDone = false;
        
        /*for (pse__Project_Phase__c item:[Select Id, Actual_Hours_Billable__c, Actual_Hours_Non_Billable__c, Total_Billable_Amount__c 
                                        FROM pse__Project_Phase__c WHERE Id=:phase.Id limit 1]) 
        {
            system.assertEquals(item.Actual_Hours_Billable__c,11);
            system.assertEquals(item.Actual_Hours_Non_Billable__c,7);
            system.assertEquals(item.Total_Billable_Amount__c,4*15+7*15);
        }
        */
        delete lstTimecards[2];
        psaTimecardHandler.isDone = false;
        
        /*for (pse__Project_Phase__c item:[Select Id, Actual_Hours_Billable__c, Actual_Hours_Non_Billable__c, Total_Billable_Amount__c 
                                        FROM pse__Project_Phase__c WHERE Id=:phase.Id limit 1]) 
        {
            system.assertEquals(item.Actual_Hours_Billable__c,4);
            system.assertEquals(item.Actual_Hours_Non_Billable__c,7);
            system.assertEquals(item.Total_Billable_Amount__c,60);
        }*/
        
        Test.stopTest();
    }
}