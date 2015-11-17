global class ContactOtherActiveBrandsUpdateJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
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
		system.debug('****************************** In QueryLocator.getQueryLocator');
	    return Database.getQueryLocator([Select c.Id, c.Email, c.Active_Brands__c From Contact c Where c.Email != null And (c.Account.RecordTypeId = :dealerRecordTypeId Or c.Account.RecordTypeId = :subDealerRecordTypeId) Order By Email ]);
	}
	
	global void execute(Database.BatchableContext context, List<sObject> dbContactEmails){
		system.debug('****************************** In execute ');

		Set<Contact> contacts = new Set<Contact>();
		List<Contact> contactsToUpdate = new List<Contact>();
		
		//Iterate through contact email addresses		
		for (sObject sContact : dbContactEmails) {
			contacts.add((Contact) sContact);
		}
			
		for (Contact contact : contacts) {
			
			system.debug('****************************** Working on contact id: ' + contact.Id);
			
			Set<String> contactActiveBrands = new Set<String>();
			Set<String> contactOtherActiveBrands = new Set<String>();
			
			contact.Other_Active_Brands__c = '';
			
			for (Contact c : [Select Id, c.Active_Brands__c From Contact c Where c.Email = :contact.Email And (c.Account.RecordTypeId = :dealerRecordTypeId Or c.Account.RecordTypeId = :subDealerRecordTypeId)]) {
				List<String> abSplit = new List<String>();
				
				if (c.Active_Brands__c != null) {
					abSplit = c.Active_Brands__c.split(';');
				}
				contactActiveBrands.addAll(absplit);
				system.debug('****************************** Just added active brands: ' + abSplit + ' for contact id: ' + c.id);
			}
			
			for (String activeBrand : contactActiveBrands) {
				system.debug('****************************** Comparing active brand: ' + activeBrand + ' to contact active brands: ' + contact.Active_Brands__c);
				if (contact.Active_Brands__c == null || !contact.Active_Brands__c.contains(activeBrand)) {
					contactOtherActiveBrands.add(activeBrand);
				}
			}
			
			if (!contactOtherActiveBrands.isEmpty()) {
				contact.Other_Active_Brands__c = String.join(new List<String> (contactOtherActiveBrands), ';');
			}
			
			contactsToUpdate.add(contact);
		}
		
		update contactsToUpdate;
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