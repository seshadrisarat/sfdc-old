/*
//MOELIS-19:
Please add a new trigger on Call Log Contacts (insert, update, delete) 
to Company lookup field (a "Company" lookup field in Call Log Contacts). 
This should work the same way as: trigger employeeRelationshipAccountUPD 
(on Employee_Relationships_c) which keeps Company_relationship_c up-to-date.
*/
trigger Call_Log_Contact_UPD on Call_Log_Contact__c (before insert, before update)
{
	Set<Id> contactIdSet = new Set<Id>();
    for (Call_Log_Contact__c clc : Trigger.new) contactIdSet.add(clc.Contact__c);
	Map<Id, Contact> contactMap = new Map<Id, Contact>([select AccountId from Contact where id in :contactIdSet]);
	for (Integer i = 0; i < Trigger.new.size(); i++) 
	{
		if(Trigger.new[i].Contact__c!=null && ''+Trigger.new[i].Contact__c!='') 
		{
			Contact curContactObj = contactMap.get(Trigger.new[i].Contact__c);
			Trigger.new[i].Company__c = curContactObj.AccountId;
		}
		else Trigger.new[i].Company__c = null;
	}

	
	
	//autofilling fields (Title, Phone, Email, Business City, Business State/Province) from Contact
    if(trigger.isInsert)
    {
    	List<ID> ListContact_ID = new List<ID>();
    	for(Call_Log_Contact__c item : trigger.new)	ListContact_ID.add(item.Contact__c);
    	Map<ID,Contact> mapContact = new Map<ID,Contact>([select ID,Title,Phone,Email,MailingState,MailingCity,Account.Name,Account.Id from Contact where ID IN :ListContact_ID]);
    	for (integer i = 0; i<trigger.new.size(); i++)  
        {
    		//Trigger.new[i].Company_Name__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).Account.Name:'';
    		Trigger.new[i].Company__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).Account.Id:'';
    		Trigger.new[i].Title__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).Title:'';
    		Trigger.new[i].Phone__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).Phone:'';
    		Trigger.new[i].Email__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).Email:'';
    		Trigger.new[i].Business_State_Province__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).MailingState:'';
    		Trigger.new[i].Business_City__c  = mapContact.containsKey(Trigger.new[i].Contact__c)?mapContact.get(Trigger.new[i].Contact__c).MailingCity:'';
    	}
    } 
}