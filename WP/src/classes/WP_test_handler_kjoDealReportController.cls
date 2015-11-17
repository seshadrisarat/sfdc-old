@isTest(SeeAllData=true)

public with sharing   class WP_test_handler_kjoDealReportController {
	
	static testMethod void test_WP_test_handler_kjoDealReportController () {
			Test.startTest();
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
			System.debug('TEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASSTEST CLASS TEST CLASS');
		      Deal_Team__c fo = new Deal_Team__c();
     Contact emp = [Select Id from Contact where lastname = 'Chiu' limit 1];
      Deal__c dlX = [Select Id From Deal__c limit 1];
      
      kjoDealReportController k = new kjoDealReportController();
      kjoDealReportController.getProfessionalsList('hiu');
      kjoDealReportController.getFinanceCurrencies();
      string s = kjoDealReportController.getCurrencySymbolFromIso('USD');
      k.SFTestClass();
      //List<kjoDealReportController.FinanceOptions> lfo = kjoDealReportController.FinanceOptions.getFinanceOptions();
      //kjoDealReportController.FinanceOptions fX2 = new kjoDealReportController.FinanceOptions('sfsucks',kjoDealReportController.FinanceOptions.getFinanceOptions() );
       
//	List<person> lst = kjoDealReportController.getProfessionalsList('hiu');
		Test.stopTest();

		
	}
	
	 public static testMethod void testMyController() {
/*        PageReference pageRef = Page.success;
        Test.setCurrentPage(pageRef);
      
        kjoDealReportController controller = new kjoDealReportController();
        String nextPage = kjoDealReportController.save().getUrl();

        // Verify that page fails without parameters
        System.assertEquals('/apex/failure?error=noParam', nextPage);

        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('qp', 'yyyy');
      
        // Instantiate a new controller with all parameters in the page
        controller = new kjoDealReportController(); 
        
        nextPage = controller.save().getUrl();

        // Verify that the success page displays
        System.assertEquals('/apex/success', nextPage);
        //Lead[] leads = [select id, email from lead where Company = 'acme'];
        //System.assertEquals('firstlast@acme.com', leads[0].email);
        */
    }
	
	}