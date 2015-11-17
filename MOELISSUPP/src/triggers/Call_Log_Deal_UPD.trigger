trigger Call_Log_Deal_UPD on Call_Log_Deal__c (after delete, after insert, after update) 
{
	List<Call_Log_Deal__c> List_CallLogDeal = new List<Call_Log_Deal__c>();
	List<Call_Log_Deal__c> Trigger_list;
	if(trigger.isInsert || trigger.isUpdate) Trigger_list = Trigger.new;
	if(trigger.isDelete) Trigger_list = Trigger.old;
	Boolean isFireTrigger = false;
	Id oneDeal_Id;
	Id secondDeal_Id;
	Id oneCallLog_Id;
	Id secondCallLog_Id;
	for (Call_Log_Deal__c item : Trigger_list) 
	{
		if(trigger.isInsert || trigger.isUpdate) oneDeal_Id = Trigger.newMap.get(item.Id).Deal__c;
		if(trigger.isDelete)	oneDeal_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondDeal_Id = Trigger.oldMap.get(item.Id).Deal__c;
		if(trigger.isInsert)	secondDeal_Id = null;
		if(trigger.isInsert || trigger.isUpdate) oneCallLog_Id = Trigger.newMap.get(item.Id).Call_Log__c;
		if(trigger.isDelete)	oneCallLog_Id = null;
		if(trigger.isDelete || trigger.isUpdate) secondCallLog_Id = Trigger.oldMap.get(item.Id).Call_Log__c;
		if(trigger.isInsert)	secondCallLog_Id = null;
		
		if (oneDeal_Id != secondDeal_Id || oneCallLog_Id != secondCallLog_Id) 
		{	
			isFireTrigger = true;	
			List_CallLogDeal.add(item);
		}
	}
	if (isFireTrigger) 
	{
		List<Id> List_CallLogId = new List<Id>();
		for(Call_Log_Deal__c item : List_CallLogDeal)
		{
			List_CallLogId.add(item.Call_Log__c);
		}
		if(List_CallLogId.size() > 0)
		{
			List<Schedule_Data__c> List_toInsert = new List<Schedule_Data__c>();
			for(Id itemId : List_CallLogId)
			{
				Schedule_Data__c newSD = new Schedule_Data__c();
				newSD.Object_Id__c = itemId;
				newSD.Type__c = 'Call Log';
				List_toInsert.add(newSD);
			}
			if(List_toInsert.size() > 0) insert List_toInsert;
			/*
			try{
				Batch_CallLogShareUPD batch = new Batch_CallLogShareUPD(List_CallLogId);
				Database.executeBatch(batch, 100);
			}catch(Exception e){throw new MyException('Please, wait. Previous batch process has not complited yet.');}
			//CallLogSharingRules.Set_UpdateCallLogSharing_True(List_CallLogId);
			*/
		}
	}
	
	public class MyException extends Exception{}
}