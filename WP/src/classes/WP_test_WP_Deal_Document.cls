@isTest(SeeAllData=true)
public with Sharing class WP_test_WP_Deal_Document {

    static testMethod void WP_test_WP_Deal_DocumentTest() {
        // TO DO: implement unit test
        Test.startTest();
            string sDealName = 'ABC Corp.';
    	List<String> args = new List<String>();
    	args.add(sDealName); 
            string sEmail = 'kipp.koenig@warburgpincus.com';
        List<String> emails = new List<String>();
    	emails.add(sEmail);
    	Deal_Document_Link__c wplx =  new Deal_Document_Link__c();
    	Deal__c d = [select Id from Deal__c limit 1];
    	wplx.Deal__c = d.Id;
    	wplx.Location__c = 'who cares';
    	wplx.Type__c = 'Early Action Report';
    	insert wplx;
    	
        WP_handler_WP_Deal_Document.SendEARDealNotClosedEnquiryEmail(args, emails);
        Test.stopTest();
    }
}