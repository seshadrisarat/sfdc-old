trigger PBI_UPD on Potential_Buyer_Investor__c (after delete, after insert, after update) 
{
	List<Id> List_PBIId = new List<Id>();
	List<Potential_Buyer_Investor__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneDeal_Id;
	Id secondDeal_Id;
	for (Potential_Buyer_Investor__c item : Trigger_list) 
	{
		if(trigger.isInsert || trigger.isUpdate) oneDeal_Id = Trigger.newMap.get(item.Id).Project__c;
		if(trigger.isDelete)	oneDeal_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondDeal_Id = Trigger.oldMap.get(item.Id).Project__c;
		if(trigger.isInsert)	secondDeal_Id = null;
		if(trigger.isUpdate && oneDeal_Id != secondDeal_Id || trigger.isInsert) 
		{	
			isFireTrigger = true;	
			List_PBIId.add(item.Id);
		}
	}
	if (isFireTrigger && List_PBIId.size() > 0)
	{
		List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
		for(Id itemId : List_PBIId)
		{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'PBI';
				List_toInsert.add(newSD);
		}
		if(List_toInsert.size() > 0) insert List_toInsert;
	}
}