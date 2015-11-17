@isTest 
private class vf002_Integration_Log_Test {
    static testMethod void testInsert() {
        insert New Integration_Log__c(
            INTEGRATION_OBJECT__C='Test_OnlyOneInProcess'
            ,INTEGRATION_START__C=datetime.now()
            ,INTEGRATION_STATUS__C='In Process'
            ,INTEGRATION_START_TEXT__C=string.valueof(datetime.now())
            );
        
        try {
            insert New Integration_Log__c(
                INTEGRATION_OBJECT__C='Test_OnlyOneInProcess'
                ,INTEGRATION_START__C=datetime.now()
                ,INTEGRATION_STATUS__C='In Process'
                ,INTEGRATION_START_TEXT__C=string.valueof(datetime.now())
                );
            //trigger should stop insert of the second "In Process" integration log record
            system.assert(false,'ERROR in trIntegration_Log trigger: it should prevent creation of the second "In Process" integration log record for the same integration object. Check vf002_Integration_Log.tr_Before_Insert method'); 
        } catch(Exception e) {
            system.debug('@@@INFO: correct work of the trIntegration_Log trigger - it did not allow creation of the second "In Process" integration log record for the same integration object.');
        }
    }
}