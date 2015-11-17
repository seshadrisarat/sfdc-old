global class SL_Batch_TruncateNotes implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;

	global Set<Id> rgIds;
	
	global SL_Batch_TruncateNotes()
	{
		Relationship_Group__c[] rgList = [Select Id From Relationship_Group__c
										WHERE Rep_Code__r.Name LIKE 'BL%' OR Rep_Code__r.Name = 'HV01'];

		rgIds = new Set<Id>();

		for(Relationship_Group__c rg : rgList)
		{
			rgIds.add(rg.Id);
		}

		query = 'Select Id,WhatId From Task WHERE WhatId != null AND Type != \'To Do\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
   		Task[] tList = (Task[]) scope;
   		Task[] delList = new Task[]{};

   		for(Task t : tList)
   		{
   			if(!rgIds.contains(t.WhatId))
   			{
   				delList.add(t);
   			}
   		}

   		delete delList;
	}
	
	global void finish(Database.BatchableContext BC) 
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {'bryan.anderson@silverlinecrm.com'};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Delete Task Completed');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}