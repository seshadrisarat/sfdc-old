public class ContactServices {
	
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
	
	@future
	public static void updateContactOtherBrandsByAccount(Set<Id> accountIdsWithUpdatedBrands) {
		system.debug('************* Entering ContactServices.filterAccountBrandsRelationshipChange with: ' + accountIdsWithUpdatedBrands);
		Set<String> dealerContactEmails = new Set<String>();
		Map<Id, Contact> contacts = new Map<Id, Contact>();
		Set<Contact> contactsToUpdate = new Set<Contact>();
		
		for (Id accountId : accountIdsWithUpdatedBrands) {
			//Get all of the contact email addresses associated with the account
			for (Contact c : [Select c.Id, c.Email, c.Active_Brands__c From Contact c Where c.AccountId = :accountId And c.Email != null And (c.Account.RecordTypeId = :dealerRecordTypeId Or c.Account.RecordTypeId = :subDealerRecordTypeId) Order By Email]) {
				dealerContactEmails.add(c.Email);
			}
		}
		
		//Now get all of the contacts with the found email addresses
		for (Contact c : [Select c.Id, c.Email, c.Active_Brands__c From Contact c Where c.Email In :dealerContactEmails And (c.Account.RecordTypeId = :dealerRecordTypeId Or c.Account.RecordTypeId = :subDealerRecordTypeId) Order By Email]) {
			contacts.put(c.id, c);
		}
		
		for (Contact contact : contacts.values()) {
			
			system.debug('************* Working on contact id: ' + contact.Id);
			
			Set<String> contactActiveBrands = new Set<String>();
			Set<String> contactOtherActiveBrands = new Set<String>();
			
			contact.Other_Active_Brands__c = '';
			
			if (!String.IsBlank(contact.Email)) {
			
				//Find other contacts with the same email address
				for (Contact c : [Select Id, c.Active_Brands__c From Contact c Where c.Email = :contact.Email And (c.Account.RecordTypeId = :dealerRecordTypeId Or c.Account.RecordTypeId = :subDealerRecordTypeId)]) {
					List<String> abSplit = new List<String>();
					
					if (c.Active_Brands__c != null) {
						abSplit = c.Active_Brands__c.split(';');
					}
					contactActiveBrands.addAll(absplit);
					system.debug('************* Just added active brands: ' + abSplit + ' for contact id: ' + c.id);
				}
				
				for (String activeBrand : contactActiveBrands) {
					system.debug('************* Comparing active brand: ' + activeBrand + ' to contact active brands: ' + contact.Active_Brands__c);
					if (contact.Active_Brands__c == null || !contact.Active_Brands__c.contains(activeBrand)) {
						contactOtherActiveBrands.add(activeBrand);
					}
				}
				
				system.debug('************* Setting other active brands for contact: ' + contact.Id + ' to: ' + contactOtherActiveBrands);
				if (!contactOtherActiveBrands.isEmpty()) {
					contact.Other_Active_Brands__c = String.join(new List<String> (contactOtherActiveBrands), ';');
				}
			}
			
			system.debug('************* Added contact id: ' + contact.Id + ' to list of contacts to update');
			contactsToUpdate.add(contact);
		}
		
		system.debug('************* Updating contacts: ' + contactsToUpdate);
		update new List<Contact>(contactsToUpdate);
	}

}