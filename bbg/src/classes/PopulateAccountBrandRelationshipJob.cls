global class PopulateAccountBrandRelationshipJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	private DateTime startDateTime = DateTime.now();
	
	private static Id dealerRecordTypeId {
        get{
            
            if (dealerRecordTypeId == null){
                dealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Dealer'].Id;
            }
            system.debug('****************************** Dealer record type id: ' + dealerRecordTypeId);
            return dealerRecordTypeId;
        }
        set;
    }
    
    private static Id subDealerRecordTypeId {
        get{
            
            if (subDealerRecordTypeId == null){
                subDealerRecordTypeId = [Select Id From RecordType Where SObjectType = 'Account' And DeveloperName = 'Sub_Dealers'].Id;
            }
            system.debug('****************************** Sub-dealer record type id: ' + subDealerRecordTypeId);
            return subDealerRecordTypeId;
        }
        set;
    }

	global Database.QueryLocator start(Database.BatchableContext context){
		system.debug('In QueryLocator.getQueryLocator');
		return Database.getQueryLocator([Select a.Id From Account a Where a.RecordTypeId = :dealerRecordTypeId Or a.RecordTypeId = :subDealerRecordTypeId Order By a.Id]);
	}
	
	global void execute(Database.BatchableContext context, List<sObject> dbAccounts){
		system.debug('In execute ');
		Set<Id> accountIds = new Set<Id>();
		Map<Id, Set<String>> accountsToBrandsMap= new Map<Id, Set<String>>();
		List<Account> accountsToUpdate = new List<Account>();
		
		//Iterate through objects		
		for (sObject sAccount : dbAccounts) {
			accountIds.add(((Account) sAccount).Id);
		}
		
		for(Id acctId: accountIds){
			accountsToBrandsMap.put(acctId, new Set<String>());
		}

		for( Dealer_Brand__c dealer :[SELECT Id, Dealer__c, Brand__c from Dealer_Brand__c 
										where Dealer__c IN :accountIds AND Status__c='Active']){
			accountsToBrandsMap.get(dealer.Dealer__c).add(dealer.Brand__c);
		}
		
		for(Id acctId: accountIds){
			accountsToUpdate.add(new Account(Id=acctId, Brand_Relationships__c=String.join(new List<String>(accountsToBrandsMap.get(acctId)), ';')));
		}
		
		update accountsToUpdate;
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
		mail.setSubject('Populate Account Brand Relationship: ' + a.Status);
		mail.setPlainTextBody('The populate account brand relationship job ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT
		);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}