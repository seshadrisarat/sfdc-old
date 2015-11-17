@isTest
public with sharing class DealerOwnerAssignmentEmailControlle_Test {
	
	static testMethod void test() {
		DealerOwnerAssignmentEmailController controller = new DealerOwnerAssignmentEmailController();
		
		System.assertNotEquals(null, controller.selectQry);
		
		System.assertNotEquals(null, controller.getSelectFields());
		
		System.assertNotEquals(null, controller.theOwner);
		
		System.assertNotEquals(null, controller.ownerValues);
	}

}