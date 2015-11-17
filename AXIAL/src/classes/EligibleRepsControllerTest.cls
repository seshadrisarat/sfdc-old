@isTest
private class EligibleRepsControllerTest {
	
	@isTest static void testPage() {
		PageReference page = new PageReference('/eligiblereps');
		Test.setCurrentPage(page);
		EligibleRepsController ctrl = new EligibleRepsController();
		List<User> users = [SELECT Id, FirstName, LastName, Eligible_To_Receive_Leads__c, Last_Lead_Assigned_Date__c
                        FROM User
                        WHERE isActive = true];
		Test.startTest();
			System.assertEquals(users.size(), ctrl.getEligibleReps().size());
		Test.stopTest();
	}

	@isTest static void testSave() {
		PageReference page = new PageReference('/eligiblereps');
		Test.setCurrentPage(page);
		EligibleRepsController ctrl = new EligibleRepsController();
		List<User> users = [SELECT Id, FirstName, LastName, Eligible_To_Receive_Leads__c, Last_Lead_Assigned_Date__c
                        FROM User
                        WHERE isActive = true];
		Test.startTest();
			ctrl.save();
		Test.stopTest();
	}
	
}