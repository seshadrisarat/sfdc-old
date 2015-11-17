trigger RollupRefresh_DealContact on Deal_Contact__c (after insert, after update, after delete, after undelete) {
    List<Deal_Contact__c> dealContacts;
    if (Trigger.isDelete) {
        dealContacts = Trigger.old;
    } else {
        dealContacts = Trigger.new;
    }

    Set<Id> dealIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    for (Deal_Contact__c dc : dealContacts) {
        dealIds.add(dc.Deal__c);
        accountIds.add(dc.RelatedCompany__c);
    }
    
//    String qDealsWorked = 'SELECT Deal__c, Contact_Name__r.AccountId FROM Deal_Contact__c WHERE Contact_Name__r.AccountId<>NULL AND IsDeleted=FALSE AND Contact_Name__r.AccountId IN (' + Utilities.quoteSet(accountIds) + ')';
//    Utilities.dealsWorkedRollup(qDealsWorked);
    Utilities.dealsWorkedRollup(null);

    if (Trigger.isDelete) {
//        String qInitializeAccount = 'SELECT Id, (SELECT Id FROM Deals__r WHERE IsDeleted=FALSE LIMIT 1), (SELECT Id FROM RelatedDeals__r WHERE IsDeleted=FALSE LIMIT 1) FROM Account WHERE IsDeleted=FALSE AND Id IN (' + Utilities.quoteSet(accountIds) + ')';
//        Utilities.initializeAccount(qInitializeAccount);
        Utilities.initializeAccount(null);
    }
}