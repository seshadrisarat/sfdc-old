// See the 596 task in ACE
trigger Contact_Relationships_Upd on Contact (after update) {
	
	Map<Id,Id> contactAccountMap = new Map<Id,Id>();
	List<Id> contactIdList = new List<Id>();

	for(Contact contactItem : Trigger.new) {
		contactIdList.add(contactItem.Id);
		contactAccountMap.put(contactItem.Id, contactItem.AccountId);
	}

	List<Employee_Relationships__c> ER_List = [
		SELECT Company_Relationship__c, Contact__c 
		FROM   Employee_Relationships__c 
		WHERE  Contact__c in :contactIdList];

	for(Employee_Relationships__c item : ER_List) 
		item.Company_relationship__c = contactAccountMap.get(item.Contact__c);

	update ER_List;
}