trigger InitializeEmployeeMetric on Employee_Metrics__c (before insert, before update) {
    for (Employee_Metrics__c em : Trigger.new) {
        em.ExternalId__c = em.Employee__c + '-' + em.Date__c.year() + '-' + em.Date__c.month() + '-' + em.Date__c.day();
    }
}