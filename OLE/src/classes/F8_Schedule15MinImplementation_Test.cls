@isTest 
private class F8_Schedule15MinImplementation_Test {
    static testMethod void testRestartCrashed() {
        Integration_Log__c il=new Integration_Log__c(Integration_Object__c='Test Integration', Integration_Start__c=datetime.now().addminutes(-65), Integration_Status__c ='In Process');
        insert il;
        F8_Schedule15MinImplementation.RestartCrashedIntegrations();
    }
}