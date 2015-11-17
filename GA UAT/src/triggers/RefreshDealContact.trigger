trigger RefreshDealContact on Deal_Contact__c (before insert, before update) {
    Map<Id, Id> contactToAccountMap = new Map<Id, Id>();
    for (Deal_Contact__c dc : Trigger.new) {       
        contactToAccountMap.put(dc.Contact_Name__c, null);
    }
    
    contactToAccountMap.remove(null);
    for (Contact c : [SELECT AccountId FROM Contact WHERE Id IN :contactToAccountMap.keySet()]) {
        contactToAccountMap.put(c.Id, c.AccountId);
    }
    
    for (Deal_Contact__c dc : Trigger.new) {
        dc.RelatedCompany__c = contactToAccountMap.get(dc.Contact_Name__c);
    }
}