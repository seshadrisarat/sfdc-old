trigger RefreshDeal on Deal__c (before update) {
    Map<Id, Id> contactToAccountMap = new Map<Id, Id>();
    for (Deal__c d : Trigger.new) {
        // Set Last Status and Last Updated
        String previousStatus = Trigger.oldMap.get(d.Id).Status__c;
        if (d.Status__c != previousStatus) {
            d.Last_Status__c = previousStatus;
            d.Last_Updated__c = Date.today();
        }
        
        contactToAccountMap.put(d.Source_Name__c, null);
    }
    
    contactToAccountMap.remove(null);
    for (Contact c : [SELECT AccountId FROM Contact WHERE Id IN :contactToAccountMap.keySet()]) {
        contactToAccountMap.put(c.Id, c.AccountId);
    }
    
    for (Deal__c d : Trigger.new) {
        if (d.Source_Name__c != null) {
            d.Source_Company__c = contactToAccountMap.get(d.Source_Name__c);
        }
        d.Taken_to_IC__c |= (d.Status__c == 'IC Approved' || d.Status__c == 'Awaiting IC Feedback');
    }
}