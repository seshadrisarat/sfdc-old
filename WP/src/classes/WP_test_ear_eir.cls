@isTest
private  class WP_test_ear_eir {

static testMethod void test_ear_eir() 
    {
    	Test.startTest();
          //merch = [SELECT ID,Merchandise__c.name,Price__c,Description__c,Total_Inventory__c FROM Merchandise__c];
          
    	
    	ear_sample_pdf_page_controller ear = new ear_sample_pdf_page_controller();
    	eir_sample_pdf_page_controller eir = new eir_sample_pdf_page_controller();
    	//List<Deal__c> dList = [Select Id from Deal__c limit 1];
    	//ear.deal_id=dList[0].Id;
    	Decimal d = ear.getDecimalMod(1.2,3.4);
    	string s = ear.pad2(3);
    	ear_sample_pdf_page_controller.bsTestMethod2();
    	
    	d = eir.getDecimalMod(1.2,3.4);
    	s = eir.pad2(3);
    	eir_sample_pdf_page_controller.bsTestMethod2();
    	
    	Test.stopTest();
    	
    }
}