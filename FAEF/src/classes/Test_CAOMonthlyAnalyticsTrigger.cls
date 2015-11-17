@isTest
private class Test_CAOMonthlyAnalyticsTrigger {

	static testMethod void test() {
		
		User u = [select Id from User where isActive = true limit 1];
	
		CAO_Monthly_Analytics__c c = new CAO_Monthly_Analytics__c(
			AccountID__c = u.Id,
			Account_Owner__c = 'Test',
			C1_s__c = 5,
			C2_s__c = 5,
			C3_s__c = 5,
			C5_s__c = 5,  
			C6_s__c = 5,
			Hot__c = 5,
			Non_Target_s__c = 5,
			Strategic_s__c = 5,
			Target_s__c = 5,
			Warm_s__c = 5
		);
		insert c;
	}
	
	static testMethod void test2() {
		Integer lastYear = Date.today().year() - 1;
		Date lastYearDate = Date.newInstance(lastYear, 12, 1);
		User u = [select Id, This_Year_s_Goal__c, Last_Year_s_Goal__c from User where isActive = true limit 1];
		
		CAO_Goal__c cao = new CAO_Goal__c();
		cao.CAO_Goal__c = 1000000;
		cao.CAO_User__c = u.id;
		cao.Level_Type__c = 'CAO';
		cao.Item_Type__c = 'GROSS_MARGIN';
		cao.Period_Type__c = 'ANNUAL';
		cao.Period_Start_Date__c = Date.today();
		
		insert cao;
		
		CAO_Goal__c cao2 = new CAO_Goal__c();
		cao2.CAO_Goal__c = 1000000;
		cao2.CAO_User__c = u.id;
		cao2.Level_Type__c = 'CAO';
		cao2.Item_Type__c = 'GROSS_MARGIN';
		cao2.Period_Type__c = 'ANNUAL';
		cao2.Period_Start_Date__c = lastYearDate;
		
		insert cao2;
		
	}

}