trigger Project_Client_Contact_UPD on Project_Client_Contact__c (before insert) 
{
	//autofilling fields (Title, Phone, Email, Business City, Business State/Province) from Contact
    if(trigger.isInsert)
    {
    	List<ID> ListContact_ID = new List<ID>();
    	for(Project_Client_Contact__c item : trigger.new)	ListContact_ID.add(item.Client_Contact__c);
    	//system.debug('ListContact_ID-------------->'+ListContact_ID);
    	Map<ID,Contact> mapContact = new Map<ID,Contact>([select ID,Title,Phone,Email,MailingState,MailingCity,Account.Name,Account.Id from Contact where ID IN :ListContact_ID]);
    	//system.debug('mapContact-------------->'+mapContact);
    	for (integer i = 0; i<trigger.new.size(); i++)  
        {
        	if (!mapContact.containsKey(Trigger.new[i].Client_Contact__c)) continue;
    		//Trigger.new[i].Company_Name__c  = mapContact.get(Trigger.new[i].Client_Contact__c).Account.Name;
    		Trigger.new[i].Company_Name__c  = mapContact.get(Trigger.new[i].Client_Contact__c).Account.Id;
    		Trigger.new[i].Title__c  = mapContact.get(Trigger.new[i].Client_Contact__c).Title;
    		Trigger.new[i].Phone__c  = mapContact.get(Trigger.new[i].Client_Contact__c).Phone;
    		Trigger.new[i].Email__c  = mapContact.get(Trigger.new[i].Client_Contact__c).Email;
    		Trigger.new[i].Business_State_Province__c  = mapContact.get(Trigger.new[i].Client_Contact__c).MailingState;
    		Trigger.new[i].Business_City__c  = mapContact.get(Trigger.new[i].Client_Contact__c).MailingCity;
    	}
    } 
}