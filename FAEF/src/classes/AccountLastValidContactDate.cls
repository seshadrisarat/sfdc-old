public with sharing class AccountLastValidContactDate {

    public static void execute(Map<Id, Task> newTaskMap, Map<Id, Task> oldTaskMap) {
        
        List<Task> newTasks = newTaskMap.values();
        
        String accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
        String contactPrefix = Contact.sObjectType.getDescribe().getKeyPrefix();
        
        // get related Accounts
        Set<String> relatedAccountIds = new Set<String>();
        Set<String> relatedContactIds = new Set<String>();
        String whatId;
        String whoId;
        
        for(Task t : newTasks) {
            
            try {
                
                whatId = t.WhatId;
                whoId = t.WhoId;
                
                if(whatId != null && whatId.startsWith(accountPrefix)) relatedAccountIds.add(whatId);
                if(whoId != null && whoId.startsWith(contactPrefix)) relatedContactIds.add(whoId);
                
            }
            catch(Exception ex) {
                whatId = null;
                whoId = null;
                continue;
            }  
            
        }
        
        if(relatedAccountIds.size() > 0) {
        
            List<Account> accounts = [select Id, Last_Valid_Contact_Date__c from Account where Id in :relatedAccountIds];
            
            for(Task t : newTasks) {
                
                if(t.Status != 'Completed') continue;
                if(t.Type != 'Email In' && t.Result__c != 'Spoke to DM' && t.Result__c != 'Spoke to Influencer') continue;
                
                for(Account a : accounts) {
                    if(a.Id == t.WhatId) {
                        if(oldTaskMap == null || oldTaskMap.get(t.Id).Status != t.Status) {
                            a.Last_Valid_Contact_Date__c = Date.today();
                            break;
                        }
                    }   
                }
            }
            
            //update accounts;
        
        }
        
        if(relatedContactIds.size() > 0) {
        
            List<Contact> contacts = [select Id, Last_Call_Attempt__c from Contact where Id in :relatedContactIds];
            
            for(Task t : newTasks) {
                
                if(t.Status != 'Completed') continue;
                if(t.Type != 'Outbound Call') continue;
                
                for(Contact c : contacts) {
                    if(c.Id == t.WhoId) {
                        if(oldTaskMap == null || oldTaskMap.get(t.Id).Status != t.Status) {
                            c.Last_Call_Attempt__c = DateTime.now();
                            break;
                        }
                    }   
                }
            }
            
            //update contacts;
        
        }
        
    }

}