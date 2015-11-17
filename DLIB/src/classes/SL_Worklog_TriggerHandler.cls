public with sharing class SL_Worklog_TriggerHandler {
/** 
* \author Julia Kolesnik 
* \date 12/05/08
* \see https://silverline.jira.com/browse/SLPSA-2 
* \brief Worklog trigger handler. Runs onBeforeInsert, onBeforeUpdate
* \test SL_Test_Worklog_TriggerHandler 
*/
	//private boolean m_isExecuting = false;
	//private integer BatchSize = 0;
	
	//public SL_Worklog_TriggerHandler(boolean isExecuting, integer size)
	//{
	//	m_isExecuting = isExecuting;
	//	BatchSize = size;
	//}
    
 //   public void OnBeforeInsert(list<Worklog__c> newWL)
 //   { 
 //   	Set<String> setWLOAIds = new Set<String>();
 //   	map<String,Id> mapOAId2SFId = new map<String,Id>();
 //   	for (Worklog__c item:newWL)
 //   	{
 //   		if (item.OA_ProjectTask_ID__c!=null) setWLOAIds.add(item.OA_ProjectTask_ID__c);
 //   	}
 //   	mapOAId2SFId = getWLSFId(setWLOAIds);
 //   	for (Worklog__c item:newWL)
 //   	{
 //   		if (mapOAId2SFId.containsKey(item.Project__c + ''+item.OA_ProjectTask_ID__c)) item.Project_Task__c=mapOAId2SFId.get(item.Project__c + ''+item.OA_ProjectTask_ID__c);
 //   		else item.Project_Task__c = null;
 //   	}
    
 //   }
     
 //   public void OnBeforeUpdate(map<ID,Worklog__c> oldWLMap, map<ID,Worklog__c> newWLMap)
 //   { 
 //   	Set<String> setWLOAIds = new Set<String>();
 //   	map<String,Id> mapOAId2SFId = new map<String,Id>();
 //   	for (Worklog__c item:newWLMap.values())
 //   	{
 //   		if (item.OA_ProjectTask_ID__c!=null && item.OA_ProjectTask_ID__c!=oldWLMap.get(item.Id).OA_ProjectTask_ID__c) setWLOAIds.add(item.OA_ProjectTask_ID__c);
 //   	}
    	
 //   	mapOAId2SFId = getWLSFId(setWLOAIds);
 //   	for (Worklog__c item:newWLMap.values())
 //   	{
 //   		if (mapOAId2SFId.containsKey(item.Project__c + ''+item.OA_ProjectTask_ID__c)) item.Project_Task__c=mapOAId2SFId.get(item.Project__c + ''+item.OA_ProjectTask_ID__c);
 //   		else item.Project_Task__c = null; 
 //   	}
 //   }
     
	//public map<String,Id> getWLSFId(Set<String> setWLOAIds)
	//{
	//	map<String,Id> tmpMap = new map<String,Id>();
	//	for (Project_Task__c item:[Select Id, OA_Project_Task_Id_Number__c, Project__c FROM Project_Task__c WHERE OA_Project_Task_Id_Number__c IN :setWLOAIds limit 50000])
 //   	{
 //   		if (!tmpMap.containsKey(item.Project__c + '' + item.OA_Project_Task_Id_Number__c)) tmpMap.put(item.Project__c + '' +item.OA_Project_Task_Id_Number__c,item.Id);
 //   	}
 //   	return tmpMap;
	//}
    
}