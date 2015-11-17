trigger ContactBeforeInsert on Contact (before insert) {
	//
	// Set up outlook sync for this contact if any users have indicated that they sync all contacts for this contact's account.
	//
	
	OutlookSync.syncNewContact(Trigger.New);
}