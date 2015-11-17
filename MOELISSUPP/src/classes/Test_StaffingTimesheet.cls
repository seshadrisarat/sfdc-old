@isTest
private class Test_StaffingTimesheet {

    public static testmethod void StaffingTimesheetReport_Test() {
		Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
		//Preparing data
		//Creating test Employee_Profile__c
		Employee_Profile__c testEmp = new Employee_Profile__c(Name = 'Test Employee',First_Name__c = 'Test',Last_Name__c = 'Test',Status__c = 'Active',Office_Location__c = 'New York',Title__c = 'Consultant',Business_Type__c = 'Merchant Banking');
		insert testEmp;
		//Creating test Deal
		Ibanking_Project__c testDeal = new Ibanking_Project__c(Client__c = acc.Id);
		Ibanking_Project__c testDeal2 = new Ibanking_Project__c(Name = 'Non-Deal Project',Client__c = acc.Id);
		insert testDeal;
		insert testDeal2;
		//Creating TimeSheet_Summary__c objects
		TimeSheet_Summary__c tssObj1 = new TimeSheet_Summary__c(Week_Start_Date__c = Date.newInstance(2010,8,30),Employee__c = testEmp.Id,Stage__c = 'Submitted');
		TimeSheet_Summary__c tssObj2 = new TimeSheet_Summary__c(Week_Start_Date__c = Date.newInstance(2010,8,23),Employee__c = testEmp.Id,Stage__c = 'New');
		TimeSheet_Summary__c tssObj3 = new TimeSheet_Summary__c(Week_Start_Date__c = Date.newInstance(2010,8,16),Employee__c = testEmp.Id,Stage__c = 'Submitted');
		insert tssObj1;
		insert tssObj2;
		insert tssObj3;
		//Creating Time_Tracker__c objects related to TimeSheets
		//Create TimeTrackers for first TimeSheet
		List<Time_Tracker__c> toInsert;
		toInsert = new List<Time_Tracker__c>();
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj1.Id,Deal__c = testDeal.Id));
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj1.Id,Non_Deal_Project__c = 'Holiday',Deal__c = testDeal.Id));
		//Create TimeTrackers for second TimeSheet
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj2.Id,Deal__c = testDeal.Id));
		//toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj2.Id,Deal__c = testDeal.Id));
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj2.Id,Non_Deal_Project__c = 'Holiday',Deal__c = testDeal2.Id));
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj2.Id,Non_Deal_Project__c = 'Vacation',Deal__c = testDeal2.Id));
		//Create TimeTrackers for third TimeSheet
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj3.Id,Deal__c = testDeal.Id));
		//toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj3.Id,Deal__c = testDeal.Id));
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj3.Id,Non_Deal_Project__c = 'Holiday',Deal__c = testDeal2.Id));
		toInsert.add(new Time_Tracker__c(Time_Sheet_Summary__c = tssObj3.Id,Non_Deal_Project__c = 'Vacation',Deal__c = testDeal2.Id));
		insert toInsert;

		StaffingTimesheetReport controllerObj;
		
		system.Test.startTest();
		
		/* === Generating SUMMARY report === */
		/* titles=''  offices=''  includeAll=0  includeInactive=0 */
		System.currentPageReference().getParameters().put('reportType', 'summary');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', '');
		System.currentPageReference().getParameters().put('offices', '');
		System.currentPageReference().getParameters().put('includeInactive', '0');
		System.currentPageReference().getParameters().put('includeAll', '0');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=0  includeInactive=0 ***************');
		system.debug('************** SUMMARY REPORT *****************'+controllerObj.getReport());

		/* titles=''  offices=''  includeAll=1  includeInactive=1 */
		System.currentPageReference().getParameters().put('reportType', 'summary');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', '');
		System.currentPageReference().getParameters().put('offices', '');
		System.currentPageReference().getParameters().put('includeInactive', '1');
		System.currentPageReference().getParameters().put('includeAll', '1');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=1  includeInactive=1 ***************');
		system.debug('************** SUMMARY REPORT *****************'+controllerObj.getReport());
		
		/* titles=''  offices=''  includeAll=1  includeInactive=1  Office=NewYork;Boston  Title=Consultant;Other */
		System.currentPageReference().getParameters().put('reportType', 'summary');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', 'Consultant;Other');
		System.currentPageReference().getParameters().put('offices', 'New York;Boston');
		System.currentPageReference().getParameters().put('includeInactive', '1');
		System.currentPageReference().getParameters().put('includeAll', '1');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=1  includeInactive=1  Office=NewYork;Boston  Title=Consultant;Other***************');
		system.debug('************** SUMMARY REPORT *****************'+controllerObj.getReport());

		/* === Generating DETAIL report === */
		/* titles=''  offices=''  includeAll=0  includeInactive=0 */
		System.currentPageReference().getParameters().put('reportType', 'detail');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', 'Consultant;Other');
		System.currentPageReference().getParameters().put('offices', 'New York;Boston');
		System.currentPageReference().getParameters().put('includeInactive', '0');
		System.currentPageReference().getParameters().put('includeAll', '0');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=0  includeInactive=0 ***************');
		system.debug('************** DETAIL REPORT *****************'+controllerObj.getDetailReport());
		
		//system.Test.stopTest();

		/* titles=''  offices=''  includeAll=1  includeInactive=1 */
		System.currentPageReference().getParameters().put('reportType', 'detail');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', 'Consultant;Other');
		System.currentPageReference().getParameters().put('offices', 'New York;Boston');
		System.currentPageReference().getParameters().put('includeInactive', '1');
		System.currentPageReference().getParameters().put('includeAll', '1');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=1  includeInactive=1 ***************');
		system.debug('************** DETAIL REPORT *****************'+controllerObj.getDetailReport());
		
		/* titles=''  offices=''  includeAll=1  includeInactive=1  office=NewYork;Boston  Title=Consultant;Other*/
		System.currentPageReference().getParameters().put('reportType', 'detail');
		System.currentPageReference().getParameters().put('fromStartDate', Date.newInstance(2010,8,1)+'');
		System.currentPageReference().getParameters().put('endStartDate', Date.newInstance(2010,8,31)+'');
		System.currentPageReference().getParameters().put('titles', 'Consultant;Other');
		System.currentPageReference().getParameters().put('offices', 'New York;Boston');
		System.currentPageReference().getParameters().put('includeInactive', '1');
		System.currentPageReference().getParameters().put('includeAll', '1');
		System.currentPageReference().getParameters().put('businessType','Merchant Banking');
		controllerObj = new StaffingTimesheetReport();
		
		system.debug('************** includeAll=1  includeInactive=1 office=New York;Boston  Title=Consultant;Other ***************');
		system.debug('************** DETAIL REPORT *****************'+controllerObj.getDetailReport());
		
		//Empty parameters
		System.currentPageReference().getParameters().put('reportType', null);
		controllerObj = new StaffingTimesheetReport();
		system.debug('************** Test errMsg **************** '+controllerObj.errMsg);
		system.debug('************** Test Generated by **************** '+controllerObj.generatedBy);
		system.debug('************** Test Generated time **************** '+controllerObj.generatedTime);
		
		system.Test.stopTest();
	}
	
	public static testmethod void StaffingTimesheetReport_filter_Test() {
		Contact cntct = new Contact();
		cntct.FirstName = 'Test';
		cntct.LastName = 'Test';
		cntct.Phone = '123';
		cntct.MobilePhone = '123';
		insert cntct;
		Test.startTest();
		StaffingTimesheetReport_filter cls = new StaffingTimesheetReport_filter();
		Employee_Profile__c f = cls.getFilter();
		cls.setFilter(f);
		String output = cls.outputTo;
		f.Staffing_Title__c = null;
		f.Staffing_Office_Location__c = 'Dubai';
		//f..Staffing_Business_Type__c = '';
		cls.getFromStartDate();
		cls.setFromStartDate(cntct);
		cls.getEndStartDate();
		cls.setEndStartDate(cntct);
		List<SelectOption> lst = cls.titles;
		List<String> lst2 = cls.titlesList;
		cls.titlesList = lst2;
		List<Employee_Profile__c> lstEmp = cls.currEmployee;
		//String s = cls.titlesString;
		lst = cls.offices;
		lst2 = cls.officesList;
		cls.officesList = lst2;
		String s = cls.officesString;
		String strTitle = cls.StTitle;
		String strBusiness = cls.StBusinessType;
		List<SelectOption> lstTitles = cls.titles;
		List<SelectOption> lstBusinessTypes = cls.businessTypes;
		//String strtitle = cls.titlesString;
		String strRes = cls.displayBlock;
		String strLocation = cls.stOfficeLocation;
		List<String> lstIds = cls.selectedIds;
		String strReport = cls.reportLink;
		String strStTitle = cls.StTitle;
		String strStLocation = cls.StOfficeLocation;
		Boolean flag = cls.includeInactive;
		try{
			cls.showSummaryReport();
		} 
		
		catch (Exception e) {}
		try{
			cls.showDetailReport();
		} 
		
      	catch (Exception e) {}
		Test.stopTest();
	}
}