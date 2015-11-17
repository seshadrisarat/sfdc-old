@isTest(SeeAllData=true)

private class WP_test_handler_DCRProcessLog {
    static testMethod void test_SL_handler_DCRProcessLog() {
    	Test.startTest();
		
    	Deal__c dlX = [Select Id From Deal__c limit 1];
    	DCR_Process_Log__c dpl  =  new DCR_Process_Log__c
    	(
    	Deal_Closed_On__c =  Date.valueOf('2012-05-10'),
    	Deal_Closed_Email__c = 'sfsucks@warburgpincus.com',
    	Deal_Closed_By__c = 'abc123',
    	DCR_Sent_By__c='abc123',
	Deal__c = dlX.Id   	
    	 );
    	insert dpl;
    	dpl.Deal_Closed_By__c = 'pdq456';
    	update dpl;
      Test.stopTest();

    }

}