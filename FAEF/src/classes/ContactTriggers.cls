public with sharing class ContactTriggers {
	
	public static void updateAccountLastCallAttemptFields(List<Contact> contacts) {
		if(Site.getSiteId() == null)
		{		
			Set<Id> accountIds = new Set<Id>();
			
			for(Contact c : contacts) {
				if(c.AccountId == null && c.Account.LastModifiedById != '005600000015aFAAAY') continue;
				accountIds.add(c.AccountId);
			}
			
			Map<Id, Account> accountsMap = new Map<Id, Account>([select Id, Last_Call_Attempt__c 
																from Account where Id in :accountIds]);

			for(Contact c : contacts) {
				if(!accountsMap.containsKey(c.AccountId)) continue;
				accountsMap.get(c.AccountId).Last_Call_Attempt__c = c.Last_Call_Attempt__c;
			}
			
			update accountsMap.values();
		}
		
	}
	
}