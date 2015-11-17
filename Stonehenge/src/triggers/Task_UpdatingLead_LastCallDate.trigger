trigger Task_UpdatingLead_LastCallDate on Task (after insert, after update) {
	
	List<Id> leadIdList = new List<Id>();
	
	for(Task item : Trigger.new)
		if (item.Type == 'Call' && item.Status == 'Completed')
			leadIdList.add(item.WhoId);
			
	List<Lead> leadForUpdateList = [SELECT Last_Call_Date__c FROM Lead WHERE Id in :leadIdList];
	
	for(Lead item : leadForUpdateList)
		item.Last_Call_Date__c = date.today(); 
	
	update leadForUpdateList;
	
}