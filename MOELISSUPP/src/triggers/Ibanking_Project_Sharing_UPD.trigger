trigger Ibanking_Project_Sharing_UPD on Ibanking_Project__c (before delete, after insert, after update) 
{
	/*
	List<Ibanking_Project__c> List_Deal = new List<Ibanking_Project__c>();
	List<Ibanking_Project__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	List<Id> List_DealId = new List<Id>();
	for (Ibanking_Project__c item : Trigger_list) List_DealId.add(item.Id);
	if(List_DealId.size() > 0)DealSharingRules.Set_UpdateDealSharing_True(List_DealId);
	if (trigger.isUpdate) {}
	*/
	
	if(trigger.isDelete)
	{
		List<Call_Log_Deal__c> List_To_delete = new List<Call_Log_Deal__c>();
		for(Call_Log_Deal__c item : [SELECT Id FROM Call_Log_Deal__c WHERE Deal__c IN : trigger.old]) 
		{
			List_To_delete.add(item);
		}
		system.debug('List_To_delete ---------------------->'+List_To_delete);
		if(List_To_delete.size() > 0 ) delete List_To_delete; 
	}
}