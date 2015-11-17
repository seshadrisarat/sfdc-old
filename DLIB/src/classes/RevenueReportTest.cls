@isTest
private class RevenueReportTest
{
	@isTest
	static void test_report()
	{
		createData();
		Test.startTest();

		PageReference pgRef = Page.RevenueReport;
     	Test.setCurrentPageReference (pgRef);
     	RevenueReport pgCont = new RevenueReport();
     	system.debug(pgCont.allPages);
     	system.debug(pgCont.pageNumber);
     	system.debug(pgCont.getNumRecords());
     	system.debug(pgCont.getSortDirection());

     	pgCont.updateProjects();

     	pgCont.strRecPerPage = '1';
     	pgCont.setSortDirection('DESC');
     	pgCont.refresh();

     	pgCont.sortExpression = 'tmpBillableAmount__c';
     	pgCont.refresh();

     	if(pgCont.hasNext) pgCont.next();
     	if(pgCont.hasPrevious) pgCont.previous();
     	pgCont.last();
     	pgCont.first();

     	pgCont.params.pse__Notes__c = 'TES';
     	pgCont.searchProjects();

     	pgCont.params.pse__End_Date__c = date.today().addDays(-5);
     	pgCont.fullrefresh();

     	PageReference pgRefPrint = Page.RevenueReportPdf;
     	pgRefPrint.getParameters().put('date', String.ValueOf(Date.today()).replace(' 00:00:00',''));
     	Test.setCurrentPageReference (pgRefPrint);
     	RevenueReportPrint pgContPrint = new RevenueReportPrint();
     	Test.stopTest(); 
	}

	private static void createData() {
	   	pse__Region__c region = new pse__Region__c(Name='Test region', pse__Action_Update_Current_Time_Period__c=false, pse__Current_Time_Period__c = null);
        insert region;
    	
        pse__Proj__c proj = new pse__Proj__c();
        proj.Name = 'TEST';
        proj.pse__Region__c = region.Id;
        proj.JIRA_Project_Name__c = 'TEST';
        proj.pse__Is_Active__c = true;
        proj.pse__Is_Billable__c = true;
        proj.pse__Allow_Timecards_Without_Assignment__c = true;
        proj.pse__Project_Type__c='Customer';
        proj.pse__Billing_Type__c = 'Time and Materials';
        insert proj;

        pse__Proj__c proj2 = new pse__Proj__c();
        proj2.Name = 'TEST2';
        proj2.pse__Region__c = region.Id;
        proj2.JIRA_Project_Name__c = 'TEST2';
        proj2.pse__Is_Active__c = true;
        proj2.pse__Is_Billable__c = true;
        proj2.pse__Allow_Timecards_Without_Assignment__c = true;
        proj2.pse__Project_Type__c='Customer';
        proj2.pse__Billing_Type__c = 'Time and Materials';
        insert proj2;
        
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
    	schedule.pse__Start_Date__c = date.today().addDays(-14);
    	schedule.pse__End_Date__c = date.today().addDays(-7);
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
        
        
        pse__Timecard_Header__c tcBillable = new pse__Timecard_Header__c(pse__Billable__c = true, pse__Daily_Bill_Rate__c = false, pse__Project_Phase_Object__c = phase.Id, pse__Project__c = proj.Id, pse__Resource__c = resource.Id, pse__Assignment__c = assignment.Id);
        tcBillable.pse__Monday_Hours__c  = 2;
        tcBillable.pse__Tuesday_Hours__c = 2;
        tcBillable.pse__Bill_Rate__c = 15;
        tcBillable.pse__Start_Date__c = date.today().addDays(-14);
        tcBillable.pse__End_Date__c = date.today().addDays(-8);
        tcBillable.pse__Status__c = 'Open';
        tcBillable.pse__Milestone__c = childmilestone.id;
        insert tcBillable;

		/*
		timecards.add(new pse__Timecard__c(pse__Project__c = proj.Id, pse__Total_Billable_Amount__c = 1200, pse__Timecard_Header__c = tcBillable.Id));
		timecards.add(new pse__Timecard__c(pse__Project__c = proj.Id, pse__Total_Billable_Amount__c = 800, pse__Timecard_Header__c = tcBillable.Id));
		insert timecards;*/
		list<pse__Timecard__c> timecards = new list<pse__Timecard__c>([select Id, pse__Status__c, pse__Total_Billable_Amount__c, pse__Timecard_Header__c
										FROM pse__Timecard__c WHERE pse__Timecard_Header__c = :tcBillable.Id]);

        system.debug(timecards);
        
        
        map<string,Id> mapRecordTypeNames2Ids = new map<string,Id>();
		for (RecordType item:[Select Id, DeveloperName FROM RecordType WHERE sObjectType='pse__Miscellaneous_Adjustment__c'])
		{
			mapRecordTypeNames2Ids.put(item.DeveloperName, item.id);
		}
        pse__Miscellaneous_Adjustment__c maPreBill = new pse__Miscellaneous_Adjustment__c();
        maPreBill.RecordTypeId = mapRecordTypeNames2Ids.get('Pre_Bill');
        maPreBill.Name = 'Pre Bill';
        maPreBill.pse__Amount__c = -100;
        maPreBill.pse__Transaction_Category__c = 'Revenue';
        maPreBill.pse__Effective_Date__c = date.today();
        maPreBill.pse__Project__c = proj.Id;
        maPreBill.pse__Billed__c = false;
		maPreBill.pse__Invoiced__c = false;
		//insert maPreBill;

		/*Invoice__c invoice = new Invoice__c(PSA_Project__c = proj.Id);
		insert invoice;

		list<Slip__c> slips = new list<Slip__c>();
		slips.add(new Slip__c(Invoice__c = invoice.Id, Rate__c = 100, Quantity__c  = 10, Category__c='Timecard'));
		slips.add(new Slip__c(Invoice__c = invoice.Id, Rate__c = 50, Quantity__c  = 10, Category__c='Timecard'));
		insert slips;*/

	}
}