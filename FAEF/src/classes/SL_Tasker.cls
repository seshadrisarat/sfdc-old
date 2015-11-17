public class SL_Tasker{

	private void SL_Tasker()
	{

	}

	public static boolean createTasks(List<sObject> inpList, String ownerFieldName)
	{
		List<Tasker_Task__c> tasks = Tasker_Task__c.getall().values();
		List<Task> tasksToInsert = new List<Task>();
		Boolean retVal = false;

		for(sObject obj : inpList)
		{
			for(Tasker_Task__c task : tasks)
			{
				if((task.Active__c == true) && (obj.get(ownerFieldName) != null))
				{
					tasksToInsert.add(new Task(Subject = (task.Subject__c==null?task.Name:task.Subject__c),
											   Status = (task.Status__c==null?'':task.Status__c),
											   ActivityDate = Date.today() + (task.Days_til_Due_Date__c==null?0:Integer.valueOf(task.Days_til_Due_Date__c)),
											   Type = (task.Type__c==null?'':task.Type__c),
											   Priority = (task.Priority__c==null?'':task.Priority__c),
											   Description  = (task.Comments__c==null?'':task.Comments__c),
											   WhatId = obj.Id,
											   OwnerId = (Id)obj.get(ownerFieldName)
											  )
									  );	
				}
			}	
		}
		if(!tasksToInsert.isEmpty())
		{
			try
			{
				insert tasksToInsert;	
				retVal = true;
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.ERROR,'catch block' + e.getMessage());
				retVal = false;
			}
		}
		return retVal;
	}
}