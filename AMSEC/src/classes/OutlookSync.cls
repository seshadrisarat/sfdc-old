public with sharing class OutlookSync {
	
	public static void sync(Set<Id> contactIds, Set<Id> accountIds) {
		System.debug(System.LoggingLevel.INFO, 
			'\n**** Contact IDs: '+contactIds.size() + 
			'\n**** Account IDs: '+accountIds.size()
		); 
		Map<Id, Set<String>> contactId_to_subscriberAliases = new Map<Id, Set<String>>();
		
		// Get the accounts for the referenced contacts
//		if (!contactIds.isEmpty()) for (Contact c : [Select Id, AccountId From Contact Where Id IN : contactIds]) accountIds.add(c.AccountId);
		
		// Sync the users designated on the account's Outlook Sync list for all contacts at that account
		if (!accountIds.isEmpty()) {
			List<Account> accounts = [Select Id, (Select Id From Contacts), (Select User_Alias__c From Outlook_Sync__r) From Account a Where Id IN : accountIds];
			for (Account a : accounts) {
				System.debug(System.LoggingLevel.INFO, '\n**** Account Contacts: '+ a.Contacts.size());
				for (Contact c : a.Contacts) {
					contactIds.add(c.Id);
					if (!contactId_to_subscriberAliases.containsKey(c.Id)) contactId_to_subscriberAliases.put(c.Id, new Set<String>());
					for (Outlook_Sync__c s : a.Outlook_Sync__r) {
						contactId_to_subscriberAliases.get(c.Id).add(s.User_Alias__c);
					}
				}
			}
		}
		
		// Sync the users designated on the contact's Outlook Sync list for those contacts
		if (!contactIds.isEmpty()) {
			List<Contact> contacts = [Select Id, AccountId, (Select User_Alias__c From Outlook_Sync__r) From Contact c Where Id IN : contactIds];
			for (Contact c : contacts) {
				if (!contactId_to_subscriberAliases.containsKey(c.Id)) contactId_to_subscriberAliases.put(c.Id, new Set<String>());
				for (Outlook_Sync__c s : c.Outlook_Sync__r) {
					contactId_to_subscriberAliases.get(c.Id).add(s.User_Alias__c);
				}
			}
		}
		
		if (!contactId_to_subscriberAliases.isEmpty()) {
			List<Contact> contacts = new List<Contact>();
			for (Id contactId : contactId_to_subscriberAliases.keySet()) {
				Contact c = new Contact(
					Id=contactId,
					Outlook_Mobile_Sync__c = getSyncList(contactId_to_subscriberAliases.get(contactId))
				);
				contacts.add(c);
			}
			
			update contacts;
		}
	}
	
	public static void syncNewContact(List<Contact> contacts) {
		Set<Id> accountIds = new Set<Id>();
		for (Contact c : contacts) accountIds.add(c.AccountId);
		List<Account> accounts = [Select Id, (Select User_Alias__c From Outlook_Sync__r) From Account a Where Id IN : accountIds];
		
		Map<Id, Set<String>> accountId_to_subscriberAliases = new Map<Id, Set<String>>();
		for (Account a : accounts) {
			if (!a.Outlook_Sync__r.isEmpty() && !accountId_to_subscriberAliases.containsKey(a.Id)) accountId_to_subscriberAliases.put(a.Id, new Set<String>());
			for (Outlook_Sync__c s : a.Outlook_Sync__r) {
				accountId_to_subscriberAliases.get(a.Id).add(s.User_Alias__c);
			}
		}
		
		if (!accountId_to_subscriberAliases.isEmpty()) {
			for (Contact c : contacts) c.Outlook_Mobile_Sync__c = getSyncList(accountId_to_subscriberAliases.get(c.AccountId));
		}
	}
	
	private static String getSyncList(Set<String> aliases) {
		String sync_list = '';
		for (String alias : aliases) {
			sync_list += alias + ';';
		}
		if (sync_list.length() > 0) sync_list = sync_list.substring(0,sync_list.length()-1);
		return sync_list;
	}
	
	//
	// TEST METHODS
	//
	
	private static testMethod void testOutlookSync() {
		Account a = new Account(Name='Test');
		insert a;
		
		Outlook_Sync__c s1 = new Outlook_Sync__c(Account__c=a.Id, User_Alias__c='ABC');
		insert s1;
		
		Contact c1 = new Contact(LastName='Contact1', AccountId=a.Id);
		insert c1;
		c1 = getContact(c1.Id);
		System.assertEquals('ABC', c1.Outlook_Mobile_Sync__c);
		
		Outlook_Sync__c s2 = new Outlook_Sync__c(Account__c=a.Id, User_Alias__c='DEF');
		insert s2;

		c1 = getContact(c1.Id);
		System.assertEquals('ABC;DEF', c1.Outlook_Mobile_Sync__c);

		Contact c2 = new Contact(LastName='Contact1', AccountId=a.Id);
		insert c2;
		c2 = getContact(c2.Id);
		System.assertEquals('ABC;DEF', c2.Outlook_Mobile_Sync__c);
		
		delete s1;

		c1 = getContact(c1.Id);
		System.assertEquals('DEF', c1.Outlook_Mobile_Sync__c);
	}
	
	private static Contact getContact(Id contactId) {
		return [Select Id, Outlook_Mobile_Sync__c From Contact Where Id =: contactId];
	}
}