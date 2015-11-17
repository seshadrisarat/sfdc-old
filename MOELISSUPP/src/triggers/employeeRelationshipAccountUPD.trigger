trigger employeeRelationshipAccountUPD on Employee_Relationships__c (before insert, before update) {

	// fetching id's set of Contact in Trigger.new
    Set<Id> contactIdSet = new Set<Id>();
    for (Employee_Relationships__c er : Trigger.new) contactIdSet.add(er.Contact__c);

	// fetching contact map
	Map<Id, Contact> contactMap = new Map<Id, Contact>([select AccountId from Contact where id in :contactIdSet]);
	
	for (Integer i = 0; i < Trigger.new.size(); i++) {
		if(Trigger.new[i].Contact__c!=null && ''+Trigger.new[i].Contact__c!='') {
			Contact curContactObj = contactMap.get(Trigger.new[i].Contact__c);//[Select Id, AccountId from Contact where Id = :Trigger.new[i].Contact__c];
			Trigger.new[i].Company_relationship__c = curContactObj.AccountId;
		}
		else Trigger.new[i].Company_relationship__c = null;
	}
}





/*
// Eugen Kryvobok (10/07/09)
// old version of trigger before bulk improvement 
trigger employeeRelationshipAccountUPD on Employee_Relationships__c (before insert, before update)
{

	for (Integer i = 0; i < Trigger.new.size(); i++)
	{
		if(Trigger.new[i].Contact__c!=null && ''+Trigger.new[i].Contact__c!='')
		{
			Contact curContactObj = [Select Id, AccountId from Contact where Id = :Trigger.new[i].Contact__c];
			Trigger.new[i].Company_relationship__c = curContactObj.AccountId;
		}
		else Trigger.new[i].Company_relationship__c = null;
	}

}
*/