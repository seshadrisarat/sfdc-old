/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Call_Log_related__c trigger handler. Runs onAfterInsert  
 * \test SL_Test_CallLogRelated_Trigger_Handler
 */
public without sharing class SL_CallLogRelated_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToCallLogAdded = false;
    
    public SL_CallLogRelated_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnAfterInsert(map<ID,Call_Log_related__c> newMap_CallLogRId_CallLogRs)
    {   
        if(!isFeedToCallLogAdded)
        {
            isFeedToCallLogAdded = true;
            setFeedToCallLog(newMap_CallLogRId_CallLogRs);
        }
    }
    
    private void setFeedToCallLog(map<ID,Call_Log_related__c> map_CallLogRId_CallLogRs)
    {
    	Set<Id> listCallLogIds = new Set<Id>();
    	for(Id callLogRelatedId : map_CallLogRId_CallLogRs.keySet())
    	{
    		if(map_CallLogRId_CallLogRs.get(callLogRelatedId).Call_Log__c != null)
    			listCallLogIds.add(map_CallLogRId_CallLogRs.get(callLogRelatedId).Call_Log__c); 
    	}
    	map<Id, Id> map_CallLogId_AccountId = new map<Id, Id>();
    	map<Id, SL_Trigger_Helper.AccountValues> map_CallLogIds_Account = new map<Id, SL_Trigger_Helper.AccountValues>();
    	for(Call_Log_related__c item :[	SELECT Call_Log__c, Account__r.Name, Account__c
    									FROM Call_Log_related__c
    									WHERE Call_Log__c IN : listCallLogIds])
    	{
    		map_CallLogIds_Account.put(item.Call_Log__c,new SL_Trigger_Helper.AccountValues(item.Account__c,item.Account__r.Name));
    		map_CallLogId_AccountId.put(item.Call_Log__c,item.Account__c);
    	}
    	SL_Trigger_Helper.createFeedMessage(map_CallLogIds_Account, 'Call Log');
    	
    	SL_Trigger_Helper.createFeedMessageForContactsOfAccount(map_CallLogId_AccountId, 'Call Log');
    } 
}