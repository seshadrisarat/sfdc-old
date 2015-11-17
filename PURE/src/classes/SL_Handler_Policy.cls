/**
* ClassName      : SL_Handler_Policy 
* JIRATicket     : PURE-19
* CreatedOn      : 2/14/2014
* ModifiedBy     : Wes Weingartner
* Description    : Handler class to help integration delete child records.
*/
global without sharing class SL_Handler_Policy
{
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public static boolean PolicyHandlerHasRun = false;

	public SL_Handler_Policy(boolean isExecuting, integer size)
	{
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
		 
	public void OnAfterInsert(Map<Id,Policy__c> newMap)
	{
		if(!PolicyHandlerHasRun)
		{
			PolicyHandlerHasRun = true;
			Map<Id,Policy__c> policiesToHandle = determinePolicies(new Map<Id, Policy__c>(),newMap);
			deleteChildrenRecords(policiesToHandle);
			updatePolicies(policiesToHandle);
		}
	}
	public void OnAfterUpdate(Map<Id,Policy__c> oldMap, Map<Id,Policy__c> newMap)
	{
		if(!PolicyHandlerHasRun)
		{
			PolicyHandlerHasRun = true;
			Map<Id,Policy__c> policiesToHandle = determinePolicies(oldMap,newMap);
			deleteChildrenRecords(policiesToHandle);
			updatePolicies(policiesToHandle);
		}    
	}
	private Map<Id,Policy__c> determinePolicies(Map<Id,Policy__c> oldMap, Map<Id,Policy__c> newMap)
	{
		// if the old value of the delete children flag is false and new value is true, add it to the map to be returned.
		Map<Id,Policy__c> mapToReturn = new Map<Id, Policy__c>();
		for(Policy__c newPolicy : newMap.values())
		{
			if((newPolicy.Delete_Children__c) && (oldMap.isEmpty() || (!oldMap.isEmpty() && !oldMap.get(newPolicy.Id).Delete_Children__c)))
			{
				mapToReturn.put(newPolicy.Id, new Policy__c(Id= newPolicy.Id, Delete_Children__c = false));
			}
		}
		return mapToReturn;
	}
	private void updatePolicies(Map<Id,Policy__c> mapPolicies)
	{
		List<Debug_Log__c> lstFailedRecords = new List<Debug_Log__c>();
		if(!mapPolicies.isEmpty())
		{
			try
			{
				Database.Saveresult[] dmlResult = Database.update(mapPolicies.values(),false);
				
            	if(SL_DebugLogCreationFlag__c.getInstance('Error Logging Flag').logErrors__c)
            	{
	            	String errorMessage = '';
	            	//	Iterates through the DML result and inserts the Debug Log records for the failed
	            	for(Database.Saveresult result : dmlResult)
	            	{
	            		if(!result.isSuccess())
	            		{
	            			errorMessage = '';
	            			for(Database.Error err : result.getErrors())
	            			{
	            				errorMessage += err.getMessage();	
	            			}
	            			lstFailedRecords.add(new Debug_Log__c(Record_Id__c = result.getId(), Description__c = errorMessage));
	            		}
	            	}
	            	insert lstFailedRecords;
            	}
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.ERROR, e);
				insert new Debug_Log__c(Description__c = 'deleteChildren caught an exception;' + e + ' ||| policy ids: ' + mapPolicies.keySet());
			}
		}
	}
	private void deleteChildrenRecords(Map<Id,Policy__c> mapPolicies)
	{
		if(!mapPolicies.isEmpty())
		{
			/*
			List<Id> listOfIds = new List<Id>();

			Map<Id,sObject> vehiclesMap = new Map<Id,sObject>([SELECT Id FROM Vehicle__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			listOfIds.addAll(vehiclesMap.keySet());

			Map<Id,sObject> propertiesMap = new Map<Id,sObject>([SELECT Id FROM Property__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			listOfIds.addAll(propertiesMap.keySet());

			Map<Id,sObject> vesselsMap = new Map<Id,sObject>([SELECT Id FROM Covered_Vessels__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			listOfIds.addAll(vesselsMap.keySet());

			Map<Id,sObject> operatorsMap = new Map<Id,sObject>([SELECT Id FROM Operator__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			listOfIds.addAll(operatorsMap.keySet());

			Map<Id,sObject> paymentsMap = new Map<Id,sObject>([SELECT Id FROM Future_Payment__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			listOfIds.addAll(paymentsMap.keySet());

			deleteChildren(listOfIds);
			*/

			Map<Id,sObject> vehiclesMap = new Map<Id,sObject>([SELECT Id FROM Vehicle__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			Map<Id,sObject> propertiesMap = new Map<Id,sObject>([SELECT Id FROM Property__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			Map<Id,sObject> vesselsMap = new Map<Id,sObject>([SELECT Id FROM Covered_Vessels__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			Map<Id,sObject> operatorsMap = new Map<Id,sObject>([SELECT Id FROM Operator__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			Map<Id,sObject> paymentsMap = new Map<Id,sObject>([SELECT Id FROM Future_Payment__c WHERE Policy__c IN : mapPolicies.keySet() ORDER BY Policy__c]);
			/*Map<String,Id> allChildrenMap = new Map<String,Id>();
			for(sObject obj : vehiclesMap.values())
			{
				allChildrenMap.put(obj.get('Policy__c') + '|' + obj.get('Id'), (Id)obj.get('Id'));
			}
			for(sObject obj : propertiesMap.values())
			{
				allChildrenMap.put(obj.get('Policy__c') + '|' + obj.get('Id'), (Id)obj.get('Id'));
			}
			for(sObject obj : vesselsMap.values())
			{
				allChildrenMap.put(obj.get('Policy__c') + '|' + obj.get('Id'), (Id)obj.get('Id'));
			}
			for(sObject obj : operatorsMap.values())
			{
				allChildrenMap.put(obj.get('Policy__c') + '|' + obj.get('Id'), (Id)obj.get('Id'));
			}
			for(sObject obj : paymentsMap.values())
			{
				allChildrenMap.put(obj.get('Policy__c') + '|' + obj.get('Id'), (Id)obj.get('Id'));
			}

			List<String> all_CompoundKeys = new List<String>();

			all_CompoundKeys.addAll(allChildrenMap.keySet());
			all_CompoundKeys.sort();

			List<Id> idsToDelete = new List<Id>();
			for(String str:all_CompoundKeys)
			{
				idsToDelete.add(allChildrenMap.get(str));
			}*/
			List<Id> idsToDelete = new List<Id>();
			idsToDelete.addAll(vehiclesMap.keySet());
			deleteChildren(idsToDelete);
			
			idsToDelete.clear();
			idsToDelete.addAll(propertiesMap.keySet());
			deleteChildren(idsToDelete);
			
			idsToDelete.clear();
			idsToDelete.addAll(vesselsMap.keySet());
			deleteChildren(idsToDelete);
			
			idsToDelete.clear();
			idsToDelete.addAll(operatorsMap.keySet());
			deleteChildren(idsToDelete);
			
			idsToDelete.clear();
			idsToDelete.addAll(paymentsMap.keySet());
			deleteChildren(idsToDelete);

		}
	}
	@future
	public static void deleteChildren(List<Id> listIds)
	{
		List<Debug_Log__c> lstFailedRecords = new List<Debug_Log__c>();
		if(!listIds.isEmpty())
		{
			try
			{
				Database.Deleteresult[] dmlResult = Database.delete(listIds, false);
				
            	if(SL_DebugLogCreationFlag__c.getInstance('Error Logging Flag').logErrors__c)
            	{
	            	String errorMessage = '';
	            	//	Iterates through the DML result and inserts the Debug Log records for the failed
	            	for(Database.Deleteresult result : dmlResult)
	            	{
	            		if(!result.isSuccess())
	            		{
	            			for(Database.Error err : result.getErrors())
	            			{
	            				errorMessage = err.getMessage();	
	            			}
	            			//	Initializes a new Debug log record for the failures and stores into a list
	            			lstFailedRecords.add(new Debug_Log__c(Record_Id__c = result.getId(), Description__c = errorMessage));
	            		}
	            		errorMessage = '';
	            	}
	            	insert lstFailedRecords;
            	}
			}
			catch(Exception e)
			{
				System.debug(LoggingLevel.ERROR, e);
				insert new Debug_Log__c(Description__c = 'deleteChildren caught an exception;' + e + ' ||| list of Ids to delete: ' + listIds);				
			}
		}
		
	}
}