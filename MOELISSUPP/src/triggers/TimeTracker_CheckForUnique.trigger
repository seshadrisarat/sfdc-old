trigger TimeTracker_CheckForUnique on Time_Tracker__c (before insert, before update) {
	/*
	if (trigger.isInsert || trigger.isUpdate) {
		List<Time_Tracker__c> newValues = trigger.new;
		List<Id> dealIds = new List<Id>();
		for (Time_Tracker__c item: newValues) {
			dealIds.add(item.Deal__c);
		}
		
		List<Ibanking_Project__c> deals = [SELECT Id,Name FROM Ibanking_Project__c WHERE Id in :dealIds];
		Map<Id,String> idToDealName = new Map<Id,String>();
		
		for (Ibanking_Project__c item: deals) {
			idToDealName.put(item.Id,item.Name);
			system.debug('======== idToDealName.get(item.Id) ======== >>>> '+idToDealName.get(item.Id));
		}
		
		for (Time_Tracker__c item: newValues) {
			if (idToDealName.get(item.Deal__c) != 'Non-Deal Project') {
				item.Check_for_Unique__c = item.Time_Sheet_Summary__c + '-' + item.Deal__c;
			}
			system.debug('======== item.Check_for_Unique__c ======== >>>> '+item.Check_for_Unique__c);
		}
	}
	*/
}