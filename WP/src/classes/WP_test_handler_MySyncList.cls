@isTest(SeeAllData=true)

private class WP_test_handler_MySyncList {
    static testMethod void WP_test_handler_MySyncList() {
    	Test.startTest();
		Contact contact = [Select Id from Contact limit 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(contact);
		MySyncList mysync = new MySyncList(sc);
		mysync.createCompanyListMembers();
		
      Test.stopTest();

    }

}