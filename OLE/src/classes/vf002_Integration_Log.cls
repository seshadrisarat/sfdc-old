global class vf002_Integration_Log {
    public static void tr_Before_Insert(List<Integration_Log__c> triggerNew, List<Integration_Log__c> triggerOld, Map<Id,Integration_Log__c> triggerNewMap, Map<Id,Integration_Log__c> triggerOldMap) {
        Set<string> st_integration_object=new Set<string>();
        for(Integration_Log__c il_new: triggerNew) {
            if(il_new.Integration_Status__c=='In Process' ) st_integration_object.add(il_new.Integration_Object__c);
        }
        //find any already existing integrations in "In Process" status
        Map<string,Integration_Log__c> m_integrationobjectname_integrationlog=new Map<string,Integration_Log__c>();
        List<Integration_Log__c> lAlreadyRunningIntegration=new List<Integration_Log__c>([SELECT Id,Name,Integration_Object__c,Integration_Status__c FROM Integration_Log__c WHERE Integration_Object__c IN :st_integration_object AND Integration_Status__c='In Process']);
        if(lAlreadyRunningIntegration.isEmpty()) return;
        for(Integration_Log__c il_running: lAlreadyRunningIntegration) m_integrationobjectname_integrationlog.put(il_running.Integration_Object__c,il_running);
        for(Integration_Log__c il_new: triggerNew) {
            if(m_integrationobjectname_integrationlog.containsKey(il_new.Integration_Object__c)) il_new.AddError('ERROR: You are not allowed to have more than one "In Process" integration for the same integration object! Integration Name: "' + il_new.Integration_Object__c 
                + '" Existing "In Process" integration: ' + m_integrationobjectname_integrationlog.get(il_new.Integration_Object__c).Name + ' (Id=' +  m_integrationobjectname_integrationlog.get(il_new.Integration_Object__c).Id+ ')');
        }       
    }
}