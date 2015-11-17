@isTest
public with sharing class DealerLeadAssignmentEmailController_Test {
	
	static testMethod void test() {
		DealerLeadAssignmentEmailController controller = new DealerLeadAssignmentEmailController();
		
		System.assertNotEquals(null, controller.selectQry);
		
		System.assertNotEquals(null, controller.getSelectFields());
		
		System.assertNotEquals(null, controller.theLead);
		
		System.assertNotEquals(null, controller.leadValues);
	}

}