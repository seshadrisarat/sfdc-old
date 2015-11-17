@isTest
private class SL_test_VendorScheduleDetailController {
	
	@isTest static void SL_ctrl_VendorScheduleDetail() {

		Letter_of_Intent__c objLOI = new Letter_of_Intent__c();
		insert objLOI;
		Schedule__c objSched = new Schedule__c(Letter_of_Intent__c = objLOI.Id);
		insert objSched;
    	
		PageReference pageRef = new PageReference('/SL_VendorScheduleDetail?scheduleId=' + objSched.Id);
        Test.setCurrentPage(pageRef);

        SL_ctrl_VendorScheduleDetail page = new SL_ctrl_VendorScheduleDetail();

        System.assertEquals(page.schedule.Id, objSched.Id);
	}
	
}