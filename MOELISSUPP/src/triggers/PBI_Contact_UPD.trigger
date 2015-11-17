trigger PBI_Contact_UPD on Potential_Buyer_Investor_Contact__c (before insert) 
{
    //autofilling fields (Title, Phone, Email, Business City, Business State/Province) from Contact
    if(trigger.isInsert)
    {
    	List<ID> ListContact_ID = new List<ID>();
    	for(Potential_Buyer_Investor_Contact__c item : trigger.new)	ListContact_ID.add(item.Contact__c);
    	Map<ID,Contact> mapContact = new Map<ID,Contact>([select ID,Title,Phone,Email,MailingState,MailingCity,Account.Name,Account.Id from Contact where ID IN :ListContact_ID]);
    	for (integer i = 0; i<trigger.new.size(); i++)  
        {
        	if (!mapContact.containsKey(Trigger.new[i].Contact__c)) continue;
    		//Trigger.new[i].Company_Name__c  = mapContact.get(Trigger.new[i].Contact__c).Account.Name;
    		Trigger.new[i].Company_Name__c  = mapContact.get(Trigger.new[i].Contact__c).Account.Id;
    		Trigger.new[i].Title__c  = mapContact.get(Trigger.new[i].Contact__c).Title;
    		Trigger.new[i].Phone__c  = mapContact.get(Trigger.new[i].Contact__c).Phone;
    		Trigger.new[i].Email__c  = mapContact.get(Trigger.new[i].Contact__c).Email;
    		Trigger.new[i].Business_State_Province__c  = mapContact.get(Trigger.new[i].Contact__c).MailingState;
    		Trigger.new[i].Business_City__c  = mapContact.get(Trigger.new[i].Contact__c).MailingCity;
    	}
    }
}