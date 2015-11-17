public with sharing class MostRecentCommentsHandler
{
	public String strKeyPrefix = '';
	
	public MostRecentCommentsHandler()
	{
		Map<String, SObjectType> mapSchemaSobject = Schema.getGlobalDescribe();
		Schema.DescribeSObjectResult result =  mapSchemaSobject.get('Account').getDescribe();
		strKeyPrefix = Result.getKeyPrefix();
	}
	
	public void updateMostRecentForTask(List<Task> lstNewTask)
	{
		set<String> setAccId = new set<String>();
		
		for(Task objTask : lstNewTask)
		{
			if(objTask.WhatId != null && String.valueOf(objTask.WhatId).startsWith(strKeyPrefix))
				setAccId.add(objTask.WhatId);
		}
		if(setAccId.size() > 0)
		updateMostRecentActivity(setAccId);
	}
	
	public void updateMostRecentForEvent(List<Event> lstNewEvent)
	{
		set<String> setAccId = new set<String>();
		for(Event objEvent : lstNewEvent)
		{
			if(objEvent.WhatId != null && String.valueOf(objEvent.WhatId).startsWith(strKeyPrefix) && objEvent.ActivityDate < date.today())
				setAccId.add(objEvent.WhatId);
		}
		if(setAccId.size() > 0)
		updateMostRecentActivity(setAccId);
	}
	
	public void updateMostRecentActivity(set<String> setAccountId)
	{
		map<String, Task> mapAccountId_Task = new map<String, Task>();
		map<String, String> mapAccountId_Comment = new map<String, String>();
		List<Account> lstAccountToUpdate = new List<Account>();
		
		try
		{
			if(setAccountId.size() > 0)
			{
				for(Task objTask: [select Id, ActivityDate, WhatId, Description From Task where IsClosed=TRUE AND WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC])
				{
					if(!mapAccountId_Task.containsKey(objTask.WhatId))
					{
						mapAccountId_Task.put(objTask.WhatId, objTask);
						mapAccountId_Comment.put(objTask.WhatId, objTask.Description);
					}
				}
				for(Event objEvent : [select Id, ActivityDate, WhatId, Description From Event where WhatId IN: setAccountId order by ActivityDate DESC, LastModifiedDate DESC])
				{
					if(mapAccountId_Task.containsKey(objEvent.WhatId))
					{
						if(mapAccountId_Task.get(objEvent.WhatId).ActivityDate > objEvent.ActivityDate)
							mapAccountId_Comment.put(objEvent.WhatId, mapAccountId_Task.get(objEvent.WhatId).Description);
						else
							mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
					}
					else
						mapAccountId_Comment.put(objEvent.WhatId, objEvent.Description);
				}
				for(Account objAccount :[select Id, Most_Recent_Activity_Comment__c from Account where Id IN: mapAccountId_Comment.keySet()])
				{
					objAccount.Most_Recent_Activity_Comment__c = mapAccountId_Comment.get(objAccount.Id);
					lstAccountToUpdate.add(objAccount);		
				}
				if(lstAccountToUpdate.size() > 0)
				update lstAccountToUpdate;
			}
		}
		catch(Exception e)
		{
			Task objTask = new Task();
			objTask.addError('An unexpected error has occured, please notify your Administrator.');
		}
	}
}