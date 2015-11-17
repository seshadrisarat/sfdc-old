trigger TaskTriggers on Task (before insert, before update, after insert, after update) {

    if(Trigger.isBefore) {
        
        String contactPrefix = Contact.SObjectType.getDescribe().getKeyPrefix();
        Set<Id> affectedContactIds = new Set<Id>();
        
        for(Task t : Trigger.new) {
            
            // BT: set Call Note field based on Description
            if(t.Type == 'Email' || t.Type == 'Email In' || t.Type == 'Email Out') {
                if(t.Description == null) continue;
    
                String callNote = t.Description;
    
                if(callNote.indexOf('Attachment:') > -1) callNote = callNote.substring(callNote.indexOf('Attachment:'));
                else if(callNote.indexOf('Subject:') > -1) callNote = callNote.substring(callNote.indexOf('Subject:'));
                else if(callNote.indexOf('To:') > -1) callNote = callNote.substring(callNote.indexOf('To:'));
                else if(callNote.indexOf('From:') > -1) callNote = callNote.substring(callNote.indexOf('From:'));
                if(callNote.indexOf('\n') > -1) callNote = callNote.substring(callNote.indexOf('\n'));
                
                if(callNote.length() > 255) t.Call_Note__c = callNote.substring(0, 255);
                else t.Call_Note__c = callNote;
                
            }
            
            if(t.WhoId == null) continue;
            if(t.WhatId != null) continue; // skip if related to is already defined (we don't want to override with our default rules)
            if(String.valueOf(t.WhoId).startsWith(contactPrefix)) affectedContactIds.add(t.WhoId);
        }
        if(affectedContactIds.size() == 0) return;
          
        Map<Id, Contact> contacts = new Map<Id, Contact>([select Id, AccountId from Contact where AccountId != null and Id in :affectedContactIds]);
        if(contacts.values().size() == 0) return;
      
        for(Task t : Trigger.new) {
            if(!contacts.containsKey(t.WhoId)) continue;
            t.WhatId = contacts.get(t.WhoId).AccountId;
        }
    
    }
    
    else if(Trigger.isAfter) {
        
        String accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
            
        // get related Accounts
        Set<String> relatedAccountIds = new Set<String>();
        
        List<AccountShare> accountShares = new List<AccountShare>();
        Set<Id> accountShareIds = new Set<Id>();
        String whatId;
        
        // share the related account records
        for(Task t : Trigger.new) {
            
            whatId = t.WhatId;
            if(whatId == null) continue;
            if(!whatId.startsWith(accountPrefix)) continue;
            
            AccountShare share = new AccountShare();
            share.AccountId = whatId;
            share.UserOrGroupId = UserInfo.getUserId();
            share.AccountAccessLevel = 'Edit';
            share.OpportunityAccessLevel = 'Read';
            share.CaseAccessLevel = 'Read';
            accountShares.add(share);
            
        }
        
        List<Database.SaveResult> saveResults = Database.insert(accountShares, false);
        
        for(Database.SaveResult sr : saveResults) {
            if(sr.isSuccess()) accountShareIds.add(sr.getId());
            system.debug(sr.isSuccess());
            system.debug(sr.getErrors());    
        }
        
        
        //This is the old last valid contact date code (Will cause DupeCatcher and iHance errors if turned on)
        /*
        if(Trigger.oldMap == null) AccountLastValidContactDate.execute(Trigger.newMap, null);
        else AccountLastValidContactDate.execute(Trigger.newMap, Trigger.oldMap);
        
        AccountActivityFields.execute((List<sObject>)Trigger.new);
        */
        
        // unshare
        /*
        accountShares = [select Id, AccountAccessLevel from AccountShare where AccountAccessLevel = 'Edit' and UserOrGroupId = :UserInfo.getUserId()];
        for(AccountShare share : accountShares) share.AccountAccessLevel = 'Read';
        update accountShares;
        */
        
    }
    

}