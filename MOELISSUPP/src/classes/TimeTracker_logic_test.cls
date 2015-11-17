@isTest
private without sharing class TimeTracker_logic_test {
	public static testmethod void Test_TimeTracker_Logic() {
		/*system.debug('================ TEST TimeTracker_logic ==================');
		Employee_Profile__c emp1 = new Employee_Profile__c();
		upsert emp1;
		Employee_Profile__c emp2 = new Employee_Profile__c();
		upsert emp2;
		system.debug('================ Employee1 id ======>>> '+emp1.Id);
		system.debug('================ Employee2 id ======>>> '+emp2.Id);*/
		User newUser = [SELECT id, name FROM User LIMIT 1].get(0);
        Employee_Profile__c empl1 = new Employee_Profile__c();
		empl1.First_Name__c = 'Test';
		empl1.Last_Name__c = 'Test';
		empl1.User_ID__c = newUser.Id;
		insert empl1;
		Employee_Profile__c empl2 = new Employee_Profile__c();
		empl2.First_Name__c = 'Test';
		empl2.Last_Name__c = 'Test';
		empl2.User_ID__c = newUser.Id;
		insert empl2;
		List<TimeSheet_Summary__c> tmp = new List<TimeSheet_Summary__c>();
		List<Time_Tracker__c> tmpTT = new List<Time_Tracker__c>();
		List<String> strTmp;

		List<TimeSheet_Summary__c> TTList = new List<TimeSheet_Summary__c>();
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl1.Id,Week_Start_Date__c = Date.newInstance(2010,8,5)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl1.Id,Week_Start_Date__c = Date.newInstance(2010,9,6)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl1.Id,Week_Start_Date__c = Date.newInstance(2010,10,7)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl1.Id,Week_Start_Date__c = Date.newInstance(2010,11,8)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,1,2)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,2,3)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,3,4)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,5,6)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,7,8)));
		TTList.add(new TimeSheet_Summary__c(Employee__c = empl2.Id,Week_Start_Date__c = Date.newInstance(2010,9,10)));
		insert TTList;

		system.debug('================ TEST getWeekDates for 1-st Employee ======');
		strTmp = TimeTracker_logic.getWeekDates('a0HS0000002JSGi');
		for (String item: strTmp) {
			system.debug('====================== >>>>>>>>  '+item);
		}
		system.debug('================ TEST getWeekDates for 2-nd Employee ======');
		strTmp = TimeTracker_logic.getWeekDates('a0HS0000002JVs7');
		for (String item: strTmp) {
			system.debug('====================== >>>>>>>>  '+item);
		}

		system.debug('================ TEST getAvailableTimesheets for 2-nd Employee ======');
		tmp = TimeTracker_logic.getAvailableTimeSheets('a0HS0000002JVs7');
		for (TimeSheet_Summary__c item: tmp) {
			system.debug('====================== >>>>>>>>  '+item.Week_Start_Date__c);
		}
		system.debug('================ TEST getAvailableTimeSheets for 1-st Employee ======');
		tmp = TimeTracker_logic.getAvailableTimeSheets('a0HS0000002JSGi');
		for (TimeSheet_Summary__c item: tmp) {
			system.debug('====================== >>>>>>>>  '+item.Week_Start_Date__c);
		}

		system.debug('================ TEST getTimeSheetById ======');
		//system.debug('================ Normal Data ====== '+tmp[0].Id);
		//system.debug('================ tmp[0] ====== '+TimeTracker_logic.getTimeSheetById(tmp[0].Id));
		
		system.debug('================ TEST getTimeTrackerList & getTimeTracker ======');
		tmpTT = new List<Time_Tracker__c>();
		if (tmp.size() > 0)
			tmpTT = TimeTracker_logic.getTimeTrackerList(tmp[4].Id);
		for (Time_Tracker__c item: tmpTT) {
			system.debug('***=== getTimeTrackerList(id) === >>>> '+item);
			system.debug('***=== getTimeTracker(id,id) === >>>> '+TimeTracker_logic.getTimeTracker(tmp[4].Id,item.Deal__r.Id));
		}

		system.debug('================ TEST getTimeTrackerList_nonDeal ======');
		tmpTT = new List<Time_Tracker__c>();
		if (tmp.size() > 0)
			tmpTT = TimeTracker_logic.getTimeTrackerList_nonDeal(tmp[4].Id);
		for (Time_Tracker__c item: tmpTT) {
			system.debug('***====== >>>> '+item);
		}
		
		if (tmp.size() > 0) {
			system.debug('================ TEST getTotalHours ====== by '+tmp[4].Id);
			system.debug('********* ==== >>>>>>>> '+TimeTracker_logic.getTotalHours(tmp[4].Id));
		}
	}
	
	public static testmethod void Test_TimeTracker_logic_WrongData() {
		system.debug('************************* WRONG DATA *****************************');
		system.debug('================ getWeekDates ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getWeekDates('111'));
		system.debug('================ getAvailableTimeSheets ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getAvailableTimeSheets('111'));
		system.debug('================ getTimeSheetById ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getTimeSheetById('111'));
		system.debug('================ getTimeTracker ====== '+'111,222');
		system.debug('================ 111 ====== '+TimeTracker_logic.getTimeTracker('111','222'));
		system.debug('================ getTimeTrackerList ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getTimeTrackerList('111'));
		system.debug('================ getTimeTrackerList_nonDeal ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getTimeTrackerList_nonDeal('111'));
		system.debug('================ getTotalHours ====== '+'111');
		system.debug('================ 111 ====== '+TimeTracker_logic.getTotalHours('111'));
	}
}