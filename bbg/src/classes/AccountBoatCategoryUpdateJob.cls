global class AccountBoatCategoryUpdateJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	public static boolean isBulkAccountUpdate = false;
	private DateTime startDateTime = DateTime.now();
	
	private static Id dealerRecordTypeId {
        get{
            
            if (dealerRecordTypeId == null){
                dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
            }
            system.debug('Dealer record type id: ' + dealerRecordTypeId);
            return dealerRecordTypeId;
        }
        set;
    }
    
    private static Id subDealerRecordTypeId {
        get{
            
            if (subDealerRecordTypeId == null){
                subDealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Sub_Dealers'].Id;
            }
            system.debug('Sub-dealer record type id: ' + subDealerRecordTypeId);
            return subDealerRecordTypeId;
        }
        set;
    }
	
	global Database.QueryLocator start(Database.BatchableContext context){
		system.debug('In QueryLocator.getQueryLocator');

		if(Test.isRunningTest()) {
		    return Database.getQueryLocator([Select t.Id, t.Boat_Class__c, t.Dealer_Brand__r.Dealer__r.Id From Territory__c t Where t.Dealer_Brand__r.Brand__c = 'SR' And Dealer_Brand__r.Status__c ='Active' And Dealer_Brand__r.Dealer__r.RecordTypeId In (:dealerRecordTypeId, :subDealerRecordTypeId) LIMIT 20]);
		} else {
			return Database.getQueryLocator([Select t.Id, t.Boat_Class__c, t.Dealer_Brand__r.Dealer__r.Id From Territory__c t Where t.Dealer_Brand__r.Brand__c = 'SR' And Dealer_Brand__r.Status__c ='Active' And Dealer_Brand__r.Dealer__r.RecordTypeId In (:dealerRecordTypeId, :subDealerRecordTypeId)]);
		}
	}
	
	global void execute(Database.BatchableContext context, List<sObject> dbTerritories){
		system.debug('In execute ');
		isBulkAccountUpdate = true;
		Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
		Map<Id, Territory__c> territoryIdToTerritoryMap = new Map<Id, Territory__c>();
        
		//Iterate through the territories and create a map
		for (sObject sTerritory : dbTerritories) {
			Territory__c territory = (Territory__c) sTerritory; 
			territoryIdToTerritoryMap.put(territory.Id, territory);
		}
			
		Set<Id> accountSet = new Set<Id>();
		for (Id territoryId : territoryIdToTerritoryMap.keySet()) {
    		accountSet.add(territoryIdToTerritoryMap.get(territoryId).Dealer_Brand__r.Dealer__r.Id);
    	}
		system.debug('**************** accountSet: ' + accountSet);
		
		//Get all of the accounts
		Map<Id, Account> accounts = new Map<Id, Account>([Select a.Id, a.Sea_Ray_Boat_Categories__c From Account a Where a.Id In :accountSet]);
		
		//Iterate through each territory, check the boat category on the associated account, and update as needed
		for (Id territoryId : territoryIdToTerritoryMap.keySet()) {
			Territory__c territory = territoryIdToTerritoryMap.get(territoryId);
			Set<String> boatCategories = new Set<String>(territory.Boat_Class__c.split(';'));
			
			Account account = accounts.get(territory.Dealer_Brand__r.Dealer__r.Id);
			system.debug('************* account id: ' + account.Id);
			
			if (account !=null) {
				for (String boatCategory : boatCategories) {
					system.debug('************* territory boat category: ' + boatCategory);
					system.debug('************* account boat category: ' + account.Sea_Ray_Boat_Categories__c);
					if (account.Sea_Ray_Boat_Categories__c == null || !account.Sea_Ray_Boat_Categories__c.contains(boatCategory)) {
						if (String.isEmpty(account.Sea_Ray_Boat_Categories__c)) {
							account.Sea_Ray_Boat_Categories__c = boatCategory;
						} else {
							account.Sea_Ray_Boat_Categories__c += ', ' + boatCategory;
						}
						if (accountsToUpdate.get(account.Id) != null) {
							//Remove the existing value so that we can replace it with the new one
							accountsToUpdate.remove(account.Id);
						}
						accountsToUpdate.put(account.Id, account);
					}
				}
			}
		}
		
    	if (!accountsToUpdate.isEmpty()) {
    		update new List<Account>(accountsToUpdate.values());
    	}
	}
	
	global void finish(Database.BatchableContext context){
		//Send out email
		DateTime endDateTime = DateTime.now();
    	String formattedStartDT = startDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String formattedEndDT = endDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
	    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
			TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob WHERE Id =
			:context.getJobId()];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Account Boat Category Update Job: ' + a.Status);
		mail.setPlainTextBody('The account boat category update job ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT
		);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}