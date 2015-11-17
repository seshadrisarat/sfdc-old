trigger AccountTrigger on Account (after insert, after update, before insert, before update, before delete, after undelete) 
// originally - trigger AccountTrigger on Account (after insert, after update, before update) 
{
    new AccountTriggerHandler().run();
       
    if (AccountEmailOptResetJob.isBulkAccountUpdate || AccountBoatCategoryUpdateJob.isBulkAccountUpdate || AccountServices.disableTriggerProcessing) {
        return;
    } else if (System.isFuture()) {
        system.debug('Preempting trigger because System.isFuture()');
        return;
    }
    
    /*
    * BS-265 (David Hickman)
    * Need to exclude the "Media" and "Marketing Partner" record types from executing the trigger
    *
    * Copies of the trigger.new and trigger.old lists are created to allow removing the new / old
    * record if it is one of the trigger exclusion types
    *
    */
   List<Account> triggerNewList = AccountServices.qualifyAccountRecordTypesForTrigger(Trigger.new);
    
    if (!triggerNewList.isEmpty()) {
        system.debug('Qualified accounts found.');
        List<Account> triggerOldList = AccountServices.qualifyAccountRecordTypesForTrigger(Trigger.old);
        Map<Id, Account> triggerNewMap = (triggerNewList.isEmpty() || (trigger.isBefore && trigger.isInsert)) ? new map<Id, Account>() : new Map<Id, Account> (triggerNewList);
        Map<Id, Account> triggerOldMap = (triggerOldList.isEmpty() || (trigger.isBefore && trigger.isInsert)) ? new map<Id, Account>() : new Map<Id, Account> (triggerOldList); 
        
        list<Account> triggerDealerNewList = AccountServices.getDealerAccounts(triggerNewList);
        list<Account> triggerOwnerNewList = OwnerServices.getOwnerAccounts(triggerNewList);
        
        list<Account> triggerDealerOldList = AccountServices.getDealerAccounts(triggerOldList);
        list<Account> triggerOwnerOldList = OwnerServices.getOwnerAccounts(triggerOldList);
        
        map<Id, Account> triggerOldDealerMap = (triggerDealerOldList.isEmpty() || (trigger.isBefore && trigger.isInsert))  ? new map<Id, Account>() : new map<Id, Account>(triggerDealerOldList);
        map<Id, Account> triggerNewDealerMap = (triggerDealerNewList.isEmpty() || (trigger.isBefore && trigger.isInsert)) ? new map<Id, Account>() : new map<Id, Account>(triggerDealerNewList);
        map<Id, Account> triggerOldOwnerMap = (triggerOwnerOldList.isEmpty() || (trigger.isBefore && trigger.isInsert)) ? new map<Id, Account>() : new map<Id, Account>(triggerOwnerOldList);
        map<Id, Account> triggerNewOwnerMap = (triggerOwnerNewList.isEmpty() || (trigger.isBefore && trigger.isInsert)) ? new map<Id, Account>() : new map<Id, Account>(triggerOwnerNewList);
        
        system.debug('triggerDealerNewList size = ' + triggerDealerNewList.size());
        system.debug('triggerDealerOldList size = ' + triggerDealerOldList.size());
        system.debug('triggerOwnerNewList size = ' + triggerOwnerNewList.size());
        system.debug('triggerOwnerOldList size = ' + triggerOwnerOldList.size());
        
        // We need to mark the accounts for geocoding in the future if there are too many
        if (trigger.isBefore && trigger.isInsert) {
            if (triggerDealerNewList.size() > AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                system.debug('marking dealer accounts for geocoding because there are too many to process synchronously');
                AccountServices.markNewAccountForGeocodingRetry(triggerDealerNewList);  
            }
            if (triggerOwnerNewList.size() > AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                system.debug('marking owner accounts for geocoding because there are too many to process synchronously');
                AccountServices.markNewAccountForGeocodingRetry(triggerOwnerNewList);   
            }
        }
        
        if (trigger.isBefore && trigger.isUpdate) {
            if (triggerDealerNewList.size() > AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                system.debug('marking dealer accounts for geocoding if address has changed because there are too many to process synchronously');
                AccountServices.markAccountForGeocodingRetryIfAddressHasChanged(triggerOldDealerMap, triggerNewDealerMap);  
            }
            if (triggerOwnerNewList.size() > AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                system.debug('marking owner accounts for geocoding if address has changed because there are too many to process synchronously');
                AccountServices.markAccountForGeocodingRetryIfAddressHasChanged(triggerOldOwnerMap, triggerNewOwnerMap);    
            }   
        }
    
        if(trigger.isAfter&& (trigger.isInsert || trigger.isUpdate)) 
        {
            system.debug('trigger is after insert or update');
            if (Trigger.isUpdate){
                if (DealerServices.ACCOUNTS_TO_REPROCESS){
                    BatchServices.launchBatchImmediately( DealerConsolidationBatch.class, 1 );
                    DealerServices.ACCOUNTS_TO_REPROCESS = false;
                }
            }
        }
        
        if (trigger.isAfter && trigger.isInsert) {
            if (!triggerDealerNewList.isEmpty()) {
                if (triggerDealerNewList.size() <= AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                    if (!AccountServices.ranPopulateAccountGeoFields && !System.isFuture() && !System.isBatch()) {
                        system.debug('running geocoding for dealer accounts');
                        AccountServices.populateAccountGeoFieldsFuture(Pluck.ids(triggerDealerNewList));    
                    }
                    else {
                        system.debug('Not running geocoding because ranPopulateAccountGeoFields=true');
                    }
                }   
                else {
                    if (!AccountServices.ranPopulateAccountGeoFields) {
                        system.debug('scheduling dealer geocoding job');
                        AccountServices.scheduleDealerGeocodingJob(triggerDealerNewList);
                    }
                    else {
                        system.debug('Not scheduling geocoding job because ranPopulateAccountGeoFields=true');
                    }
                }
            }
            
            if (!triggerOwnerNewList.isEmpty()) {
                if (triggerOwnerNewList.size() <= AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                    if (!OwnerServices.populateOwnerGeoFieldsIsRunning && !System.isFuture() && !System.isBatch()) {
                        system.debug('running geocoding for owner accounts');
                        OwnerServices.schedulePopulateOwnerGeoFieldsNoEmail(Pluck.ids(triggerOwnerNewList));
                    }
                }   
                else {
                    if (!OwnerServices.populateOwnerGeoFieldsIsRunning) {
                        system.debug('scheding owner geocoding job');
                        AccountServices.scheduleOwnerGeocodingJob(triggerOwnerNewList);
                    }
                }
            }
        }
        
        if (trigger.isAfter && trigger.isUpdate) {
            if (!triggerDealerNewList.isEmpty()) {
                if (triggerDealerNewList.size() <= AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                    if (!AccountServices.ranPopulateAccountGeoFields && !System.isFuture() && !System.isBatch()) {
                        system.debug('geocoding dealers if address has changed');
                        AccountServices.geocodeDealersIfAddressHasChanged(triggerOldDealerMap, triggerNewDealerMap);    
                    }
                }   
                else {
                    if (!AccountServices.ranPopulateAccountGeoFields) {
                        system.debug('scheduing dealer geocoding job');
                        AccountServices.scheduleDealerGeocodingJobIfAddressHasChanged(triggerOldDealerMap, triggerNewDealerMap);
                    }
                }
            }
            
            if (!triggerOwnerNewList.isEmpty()) {
                AccountServices.disableTriggerProcessing = true;
                OwnerServices.assignDealersToOwnersIfNotGeocodingButAssignmentDataOrScoreHasChanged(triggerOldOwnerMap, triggerNewOwnerMap);
                AccountServices.disableTriggerProcessing = false;
                
                if (triggerOwnerNewList.size() <= AccountServices.MAX_ACCOUNT_GEOCODE_BATCH_SIZE) {
                    if (!OwnerServices.populateOwnerGeoFieldsIsRunning && !System.isFuture() && !System.isBatch()) {
                        system.debug('geocoding owners if address has changed');
                        AccountServices.geocodeOwnersIfAddressHasChanged(triggerOldOwnerMap, triggerNewOwnerMap);
                    }
                }   
                else {
                    if (!OwnerServices.populateOwnerGeoFieldsIsRunning) {
                        system.debug('scheduing owner geocoding job');
                        AccountServices.scheduleOwnerGeocodingJobIfAddressHasChanged(triggerOldOwnerMap, triggerNewOwnerMap);
                    }
                }
            }   
        }
        
        
        if (Trigger.isBefore){
            if (Trigger.isUpdate){
                if (!triggerNewDealerMap.isEmpty()) {
                    system.debug('consolidating dealers');
                    DealerServices.consolidateDealers(triggerNewDealerMap, triggerOldDealerMap);
                }
            }
        }
    }

    if (trigger.isAfter && trigger.isUpdate) {        

        SROC_DeactiveAccountUser.checkUserDeactivationCriteria(Trigger.oldMap,Trigger.newMap);
    }
}