@isTest
private class SL_Test_Schedule_RenewalOpportunities {
	
	@isTest static void testy_schedule() {
		Test.StartTest();
		SL_Schedule_RenewalOpportunities schClass = new SL_Schedule_RenewalOpportunities();      
		 String sch = '20 30 8 10 2 ?';
		        system.schedule('Test SL_Schedule_RenewalOpportunities', sch, schClass);
		Test.stopTest();
	}
}