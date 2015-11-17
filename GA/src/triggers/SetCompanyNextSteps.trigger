trigger SetCompanyNextSteps on Task (after insert) {
    Map<Id, Account> accountMap = new Map<Id, Account>();
    
    
    /* New 3549 Logic */
    for (Task t : Trigger.new) {
        accountMap.put(t.AccountId, new Account(
            Id=t.AccountId,
            Add_to_call_list__c=false
        ));
    }
    accountMap.remove(null);

//CWD-- 2012-12-01: pulling the following otu of the below 2 SOQL statements: "AND Next_Steps__c<>NULL"
    Map<Id, Task> tasks = new Map<Id, Task>();
    for (Account a : [SELECT Id, (SELECT ActivityDate,Description,subject, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note'  ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Account WHERE Id IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany']) {
        for (Task t : a.Tasks) {
            tasks.put(a.Id, t);
        }
    }
    for (Deal__c d : [SELECT Related_Company__c, (SELECT ActivityDate,Description, subject, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Deal__c WHERE Related_Company__c IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany' AND Status__c NOT IN ('Closed', 'Passed', 'Funded by Others', 'On Hold')]) {
        for (Task t : d.Tasks) {
            Task oldT = tasks.get(d.Related_Company__c);
            if (oldT == null || oldT.ActivityDate > t.ActivityDate) {
                tasks.put(d.Related_Company__c, t);
            }
        }
    }
    for (Id aId : tasks.keySet()) {
        if(tasks.get(aId).Next_Steps__c!=null)  accountMap.get(aId).Next_Steps__c = tasks.get(aId).Next_Steps__c;
        accountMap.get(aId).Latest_Status_Note__c = tasks.get(aId).Description;
        accountMap.get(aId).Latest_Status_Note_Subject__c = tasks.get(aId).subject;
    }



    
    /* REMOVED PER CASE 3549
    Set<Id> callListAccounts = new Set<Id>();

    for (Task t : Trigger.new) {
        if (t.AccountId != null && (t.Type =='Prospect Call' || t.Type == 'Prospect Meeting Notes')) {
            callListAccounts.add(t.AccountId);
        }

        if (!t.IsClosed || t.AccountId == null || t.WhatId != t.AccountId || t.Next_Steps__c == null || t.Type != 'Status Note') {
            continue;
        }
        accountMap.put(t.AccountId, new Account(
            Id = t.AccountId
        ));
    }

    Map<Id, Task> tasks = new Map<Id, Task>();
    for (Account a : [SELECT Id, (SELECT ActivityDate, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' AND Next_Steps__c<>NULL ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Account WHERE Id IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany']) {
        for (Task t : a.Tasks) {
            tasks.put(a.Id, t);
        }
    }
    for (Deal__c d : [SELECT Related_Company__c, (SELECT ActivityDate, Next_Steps__c FROM Tasks WHERE IsClosed=TRUE AND Type='Status Note' AND Next_Steps__c<>NULL ORDER BY ActivityDate DESC, LastModifiedDate DESC LIMIT 1) FROM Deal__c WHERE Related_Company__c IN :accountMap.keySet() AND RecordType.DeveloperName='DealCompany' AND Status__c NOT IN ('Closed', 'Passed', 'Funded by Others', 'On Hold')]) {
        for (Task t : d.Tasks) {
            Task oldT = tasks.get(d.Related_Company__c);
            if (oldT == null || oldT.ActivityDate > t.ActivityDate) {
                tasks.put(d.Related_Company__c, t);
            }
        }
    }
    for (Id aId : tasks.keySet()) {
        accountMap.get(aId).Next_Steps__c = tasks.get(aId).Next_Steps__c;
    }

    for (Account a : [SELECT Id, Latest_Next_Steps_Update__c FROM Account WHERE ID IN :callListAccounts AND Add_to_call_list__c=TRUE AND RecordType.DeveloperName='DealCompany' AND IsDeleted=FALSE]) {
        if (accountMap.get(a.Id) != null) {
            accountMap.get(a.Id).Add_to_call_list__c = false;
        } else {
            accountMap.put(a.Id,new Account(Id=a.Id,Add_to_call_list__c=false));
        }
    }
    */
    if (!accountMap.isEmpty()) {
        update accountMap.values();
    }
}