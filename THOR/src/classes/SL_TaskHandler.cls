/**
*  ClassName      : SL_TaskHandler
*  JIRATicket     : THOR-26
*  CreatedOn      : 28/AUG/2014
*  ModifiedBy     : Sanath Kumar
*  Description    : This is the handler class to rollup the task dates based on type to the Lead and Opportunity
*/
public with sharing class SL_TaskHandler 
{
	/*
    	* MethodName   : onAfterInsert
        * param        : trigger.new values
        * Description  : This method is called after task records are inserted
    */
	public void onAfterInsert(List<Task> lstTask)
	{
		List<Task> lstFilteredTask = new List<Task>();
		Set<Id> setContactRoleId = new Set<Id>();
		
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on insert of Task
		updateLeadAndOpportunity(lstTask);
		
		for(Task objTask:lstTask)
		{
			if(objTask.WhatId != null && objTask.WhatId.getsObjectType() == Contact_Role__c.getsObjectType())
			{
				lstFilteredTask.add(objTask);
				setContactRoleId.add(objTask.WhatId);
			}
		}
		
		if(!lstFilteredTask.isEmpty()  && !setContactRoleId.isEmpty())
			rollupTasksToOpportunity(Json.serialize(lstFilteredTask),setContactRoleId);
	}
	
	/*
    	* MethodName   : onAfterUpdate
        * param        : trigger.oldMap, trigger.newMap
        * Description  : This method is called after Task records are updated
    */
	public void onAfterUpdate(map<Id,Task> mapTaskOld, map<Id,Task> mapTaskNew)
	{
		List<Task> lstNewFilteredTasks = new List<Task>();///List to store the new filtered Task records
		List<Task> lstOldFilteredTasks = new List<Task>();///List to store the Old filtered Task records
		
		///Create lists of Tasks whose Start date or Type or WhatId or WhoId has been updated
		for(Id objTaskId:mapTaskNew.keyset())
		{
			if((mapTaskOld.get(objTaskId).ActivityDate != mapTaskNew.get(objTaskId).ActivityDate) ||
			   (mapTaskOld.get(objTaskId).Type != mapTaskNew.get(objTaskId).Type) ||
			   (mapTaskOld.get(objTaskId).WhatId != mapTaskNew.get(objTaskId).WhatId) ||
			   (mapTaskOld.get(objTaskId).WhoId != mapTaskNew.get(objTaskId).WhoId)||
			   (!mapTaskOld.get(objTaskId).isClosed && mapTaskNew.get(objTaskId).isClosed))
			{
				lstNewFilteredTasks.add(mapTaskNew.get(objTaskId));
				lstOldFilteredTasks.add(mapTaskOld.get(objTaskId));
			}
		}
		
		///Call updateLeadAndOpportunity method to update fields on new lead and opportunity on update of Task
		updateLeadAndOpportunity(lstNewFilteredTasks);
		
		///Call updateLeadAndOpportunity method to update fields on old lead and opportunity on update of Task
		updateLeadAndOpportunity(lstOldFilteredTasks);
	}
	
	/*
    	* MethodName   : onAfterDelete
        * param        : trigger.old values
        * Description  : This method is called after Task records are deleted
    */
	public void onAfterDelete(List<Task> lstTaskOld)
	{
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on delete of Task
		updateLeadAndOpportunity(lstTaskOld);
	}
	
	/*
    	* MethodName   : onAfterUnDelete
        * param        : trigger.new values
        * Description  : This method is called after Task records are undeleted
    */
	public void onAfterUnDelete(List<Task> lstTaskNew)
	{
		///Call updateLeadAndOpportunity method to update fields on lead and opportunity on undelete of Task
		updateLeadAndOpportunity(lstTaskNew);
	}
	
	/*
    	* MethodName   : updateLeadAndOpportunity
        * param        : Filtered Task records
        * Description  : This method is to update lead and opportunity records
    */
	private void updateLeadAndOpportunity(List<Task> lstTask)
	{
		Set<Id> setWhatId = new Set<Id>();
		Set<Id> setWhoId = new Set<Id>();
		List<Sobject> lstSobject = new List<Sobject>();
		
		///Create sets of Opportunity and lead ids
		for(Task objTask:lstTask)
		{
			if(objTask.WhatId != null)
				setWhatId.add(objTask.WhatId);
			if(objTask.WhoId != null)
				setWhoId.add(objTask.WhoId);
		}
		
		///Create a list of Opportunity
		for(Opportunity objOpportunity:[SELECT Id 
		                                FROM Opportunity
		                                WHERE Id IN:setWhatId])
		{
			lstSobject.add((sObject)objOpportunity);
		}
		
		///Create a list of Lead
		for(Lead objLead:[SELECT Id 
		                  FROM Lead
		                  WHERE Id IN:setWhoId])
		{
			lstSobject.add((sObject)objLead);
		}
		
		SL_ActivityMilestoneGenericClass  objActivityMilestoneGenericClass  = new SL_ActivityMilestoneGenericClass(lstSobject);
	}
	
	
	/*
    	* MethodName   : rollupTasksToOpportunity
        * param        : Filtered Task records
        * Description  : This method is to rolluptasks from contact role to opportunity
    */
    @future
	private static void rollupTasksToOpportunity(String strTaskRecords,Set<Id> setContactRoleId)
	{
		List<Task> lstTask = (List<Task>)JSON.deserialize(strTaskRecords, List<Task>.class);
		List<Task> lstTaskToInsert = new List<Task>();
		Map<Id,Id> mapContactRoleId_OppId = new Map<Id,Id>();
		
		for(Contact_Role__c objContactRole:[SELECT Id,Opportunity__c 
		                                    FROM Contact_Role__c
		                                    WHERE Id IN:setContactRoleId])
		{
			if(objContactRole.Opportunity__c != null)
				mapContactRoleId_OppId.put(objContactRole.Id, objContactRole.Opportunity__c);
		}
		
		
		///Create a new task
		for(Task objTask:lstTask)
		{
			if(mapContactRoleId_OppId.containskey(objTask.WhatId) && mapContactRoleId_OppId.get(objTask.WhatId) != null)
			{
				lstTaskToInsert.add(new Task
				(
					Subject = objTask.Subject,
					Description = objTask.Description,
					Status = objTask.Status,
					ActivityDate = objtask.ActivityDate,
					Priority = objTask.Priority,
					OwnerId = objTask.OwnerId,
					WhoId = objtask.WhoId,
					WhatId = mapContactRoleId_OppId.get(objTask.WhatId)
				));
			}
		}
		
		if(!lstTaskToInsert.isEmpty())
			database.insert(lstTaskToInsert,false);
	}
	
}