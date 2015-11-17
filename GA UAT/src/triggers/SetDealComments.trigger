trigger SetDealComments on Task (after insert, after update, after delete)
{
    // Added after delete event for REQ-0000338
    
    MostRecentCommentsHandler objRecentCommentsHandler = new MostRecentCommentsHandler();

    if(trigger.isAfter && trigger.isInsert)
    {
        objRecentCommentsHandler.updateMostRecentForTask(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        objRecentCommentsHandler.updateMostRecentForTask(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isDelete)
    {
        objRecentCommentsHandler.updateMostRecentForTask(trigger.old);
    }
    
    String dealPrefix = Deal__c.SObjectType.getDescribe().getKeyPrefix();

    Map<Id, Deal__c> dealMap = new Map<Id, Deal__c>();
    if(trigger.isAfter && trigger.isInsert)
    {
        for (Task t : Trigger.new) {
            if (!t.IsClosed || t.WhatId == null || !((String) t.WhatId).startsWith(dealPrefix)) {
                continue;
            }
            dealMap.put(t.WhatId, new Deal__c(
                Id = t.WhatId
            ));
        }
    }

    Map<Id, Account> accountMap = new Map<Id, Account>();
    Map<Id, Task> tasks = new Map<Id, Task>();
    for (Deal__c d : [SELECT Related_Company__c, (SELECT ActivityDate, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' AND Next_Steps__c<>NULL ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Deal__c WHERE Id IN :dealMap.keySet() AND Status__c NOT IN ('Closed', 'Passed', 'Funded by Others', 'On Hold')]) {
        for (Task t : d.Tasks) {
            dealMap.get(d.Id).Deal_Comments__c = t.Next_Steps__c;
            accountMap.put(d.Related_Company__c, new Account(
                Id = d.Related_Company__c,
                Next_Steps__c = t.Next_Steps__c
            ));
            tasks.put(d.Related_Company__c, t);
        }
    }

    if (!dealMap.isEmpty()) {
        update dealMap.values();
    }

    accountMap.remove(null);
    if (!accountMap.isEmpty()) {
        update accountMap.values();
    }
}