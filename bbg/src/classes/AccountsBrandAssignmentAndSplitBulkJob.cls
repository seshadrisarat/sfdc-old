global class AccountsBrandAssignmentAndSplitBulkJob  implements Database.Batchable<sObject>, Database.Stateful {
	
	private Integer PARDOT_INSERT_OBJ_STATE = 1;
	private Integer recordLimit = null;
	
	private List<String> splitAccountNames = new List<String>();
	private List<Id> updatedAccountIds = new List<Id>();
	
	global AccountsBrandAssignmentAndSplitBulkJob() {
	}
	
	global AccountsBrandAssignmentAndSplitBulkJob(Integer maxRecords) {
		this();
		this.recordLimit = maxRecords;
	}
	
	global Database.QueryLocator start(Database.BatchableContext context){
		system.debug('creating query locator');
		if (recordLimit != null) {
			return Database.getQueryLocator([
				select owner__r.personemail, owner__r.id, hin_number__r.brand_del__C, HIN_Number__c, Purchase_Date__c, Status__c
				from Owner_Boat_Relationship__c
				where owner__r.brand__c = null or owner__r.brand__c = 'NA'
				order by owner__r.id
				limit :recordLimit]);
		}
		return Database.getQueryLocator([
			 select owner__r.personemail, owner__r.id, hin_number__r.brand_del__C, HIN_Number__c, Purchase_Date__c, Status__c
			 from Owner_Boat_Relationship__c
			 where  owner__r.brand__c = null or owner__r.brand__c = 'NA'
			 order by owner__r.id
		]);
	}
	
	global void execute(Database.BatchableContext context, List<sObject> owners){
		system.debug('starting bulk execution');
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		
		// ownerBrandMap - a map Owner_Boat_Relationship__c to the Brand
		Map<Owner_Boat_Relationship__c, String> ownerBrandMap = new Map<Owner_Boat_Relationship__c, String>();
		// ownerAccountBrandMapSet-  a map with keys of owner account IDs and value of brand to set on the account
		Map<Id, Set<String>> ownerAccountBrandMapSet = new Map<Id, Set<String>>();
		Map<Id, Set<Owner_Boat_Relationship__c>> accountToOwnerRelMap = new Map<Id, Set<Owner_Boat_Relationship__c>>();
		for (sObject o : owners) {
			Owner_Boat_Relationship__c ownerRel = (Owner_Boat_Relationship__c)o;
			system.debug('putting key-value on ownerBrandMap:' + ownerRel + ' - ' + ownerRel.hin_number__r.brand_del__c);
			ownerBrandMap.put(ownerRel, ownerRel.hin_number__r.brand_del__c);
			
			if (!accountToOwnerRelMap.containsKey(ownerRel.owner__r.id)) {
				accountToOwnerRelMap.put(ownerRel.owner__r.id, new Set<Owner_Boat_Relationship__c>());
			}
			accountToOwnerRelMap.get(ownerRel.owner__r.id).add(ownerRel);
			
			Id accountId = ownerRel.owner__r.id;
			if (!ownerAccountBrandMapSet.containsKey(accountId)) {
				ownerAccountBrandMapSet.put(accountId, new Set<String>());
			}
			ownerAccountBrandMapSet.get(accountId).add(ownerRel.hin_number__r.brand_del__c);
		}
		
		List<Owner_Boat_Relationship__c> ownerRelationships = [
			select id, owner__r.id
			from Owner_Boat_Relationship__c
			where id in :ownerBrandMap.keySet()
		];
		
		// accountToBoatOwnerRelMap - a map of account id to to boat owner relationships
		Map<Id, Set<Id>> accountToBoatOwnerRelMap = new Map<Id, Set<Id>>();
		// accountsToClone - a set of all the account ids that have multiple brands
		Set<Id> accountsToCloneIdSet = new Set<Id>();
		for (Owner_Boat_Relationship__c ownerRel : ownerRelationships) {
			Id accountId = ownerRel.owner__r.id;
			if (!accountToBoatOwnerRelMap.containsKey(accountId)) {
				accountToBoatOwnerRelMap.put(accountId, new Set<Id>());
			}
			accountToBoatOwnerRelMap.get(accountId).add(ownerRel.id);
			if (accountToBoatOwnerRelMap.get(accountId).size()>1) {
				accountsToCloneIdSet.add(accountId);
			}
		}
		
		// determine which accounts will be cloned
		String soql = getCreatableFieldsSOQL('Account', 'Id in :accountsToCloneIdSet');
		List<Account> accountsToClone = Database.query(soql);
		Map<Id, Account> accountIdToFullObjectMap = new Map<Id, Account>();
		for (Account full : accountsToClone) {
			accountIdToFullObjectMap.put(full.id, full);
		}
		
		// get the accounts to update
		List<Account> accounts = [select id, personEmail, personContactId from Account where id in :accountToBoatOwnerRelMap.keySet()];
		List<Account> newAccounts = new List<Account>();
		// accountsToDupeAccountsMap - a map of old accounts to the set of newly created duplicate accounts
		Map<Account, Set<Account>> accountsToDupeAccountsMap = new Map<Account, Set<Account>>();
		
		for (Account a : accounts) {
			// need to duplicate the account per brand
			Set<String> accountBrands = ownerAccountBrandMapSet.get(a.id);
			Integer i = 0;
			for (String brand: accountBrands) {
				if (i==0) {
					// just update the account, don't duplicate for the first brand
					system.debug('Updating account id: ' + a.id + ' with value: ' + brand);
					updatedAccountIds.add(a.id);
					a.brand__c = brand;
				}
				else {
					// need to clone the account and assign the brand
					Account full = accountIdToFullObjectMap.get(a.id);
					Account brandClone = full.clone(false,true);
					brandClone.brand__c = brand;
					if (!accountsToDupeAccountsMap.containsKey(full)) {
						accountsToDupeAccountsMap.put(full, new Set<Account>());
					}
					accountsToDupeAccountsMap.get(full).add(brandClone);
					newAccounts.add(brandClone);
					splitAccountNames.add(a.id);
					system.debug('creating clone of account: ' + a.id);
				}
				i++;
			}
		}

		if (!accounts.isEmpty()) {
			update accounts;
		}
		if (!newAccounts.isEmpty()) {
			insert newAccounts;
			List<Owner_Boat_Relationship__c> newBoatOwnerRels = new List<Owner_Boat_Relationship__c>();
			List<Owner_Boat_Relationship__c> boatOwnerRelsToRemove = new List<Owner_Boat_Relationship__c>();
			// need to create the boat owner relations ships for the new accounts
			for (Account old : accountsToDupeAccountsMap.keySet()) {
				Set<Owner_Boat_Relationship__c> boatRels = accountToOwnerRelMap.get(old.id);
				for (Account newAccount : accountsToDupeAccountsMap.get(old)) {
					for (Owner_Boat_Relationship__c rel: boatRels) {
						if (rel.hin_number__r.brand_del__C == newAccount.brand__c) {
							Owner_Boat_Relationship__c newRel = rel.clone(false, true);
							newRel.owner__c = newAccount.id;
							newBoatOwnerRels.add(newRel);
							boatOwnerRelsToRemove.add(rel);
						}
					}
				}
			}
			if (!newBoatOwnerRels.isEmpty()) {
				insert newBoatOwnerRels;
			}
			if (!boatOwnerRelsToRemove.isEmpty()) {
				delete boatOwnerRelsToRemove;
			}
		}
		
    }
    
	global void finish(Database.BatchableContext context){
		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
		// Query the AsyncApexJob object to retrieve the current job's information.
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
			TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob WHERE Id =
			:context.getJobId()];
		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('AccountsBrandAssignmentAndSplitBulkJob status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
			' batches with '+ a.NumberOfErrors + ' failures.' + '\n' +
			'Updated Account Ids: ' + updatedAccountIds.size() + '\n' +
			'Split Accounts: ' + splitAccountNames.size());
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	

	// Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
	// taken from http://sfdc.arrowpointe.com/2011/03/28/cloning-records-in-apex/
    private String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && fd.getName() != 'Name'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }

}