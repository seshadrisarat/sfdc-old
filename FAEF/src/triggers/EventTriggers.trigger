trigger EventTriggers on Event (before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore){
      //Populate the End Date/Time field
      for(Event e : Trigger.new){
          if(e.EndDateTime != null){
             e.End_Date_Time__c = e.EndDateTime;
          }
      }
        
      UpdateVMInPersonDates.CopyDatesFromEventToContact(Trigger.new);
    }
    
    if(Trigger.isAfter) {
        
        String accountPrefix = Account.sObjectType.getDescribe().getKeyPrefix();
            
        // get related Accounts
        Set<String> relatedAccountIds = new Set<String>();
        
        List<AccountShare> accountShares = new List<AccountShare>();
        Set<Id> accountShareIds = new Set<Id>();
        String whatId;
        
        // share the related account records
        for(Event e : Trigger.new) {
            
            if(e.WhatId == null) continue;
            
            whatId = e.WhatId;
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
        
        AccountActivityFields.execute((List<sObject>)Trigger.new);
        
        // unshare
        /*
        accountShares = [select Id, AccountAccessLevel from AccountShare where AccountAccessLevel = 'Edit' and UserOrGroupId = :UserInfo.getUserId()];
        for(AccountShare share : accountShares) share.AccountAccessLevel = 'Read';
        update accountShares;
        */
        
    }
      
}