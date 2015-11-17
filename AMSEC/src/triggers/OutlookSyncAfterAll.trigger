trigger OutlookSyncAfterAll on Outlook_Sync__c (after delete, after insert, after undelete, after update) {
	//
	// Manages the Contact.Outlook_Mobile_Sync__c multi-select picklist based on entries in this object.
	// When entries are made against a contact, sync for that contact. 
	// When entries are made against an account, sync for all contacts at that account.
	//

	Set<Id> contactIds = new Set<Id>();
	Set<Id> accountIds = new Set<Id>();
	for (Outlook_Sync__c s : (Trigger.New == null ? Trigger.Old : Trigger.New)) {
		if (s.Contact__c != null) contactIds.add(s.Contact__c);
		if (s.Account__c != null) accountIds.add(s.Account__c);
	}

	OutlookSync.sync(contactIds, accountIds);	
}