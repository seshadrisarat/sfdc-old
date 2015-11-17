/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Call_Log_Contact__c trigger handler. Runs onAfterInsert   
 * \test SL_Test_CallLogContact_Trigger_Handler
 */
public with sharing class SL_CallLogContact_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToCallLogCAdded = false;
    
    public SL_CallLogContact_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
         
    public void OnAfterInsert(map<ID,Call_Log_Contact__c> newMap_CallLogContactId_CallLogContacts)
    {   
        if(!isFeedToCallLogCAdded)
        {
            isFeedToCallLogCAdded = true;
            setFeedToContact(newMap_CallLogContactId_CallLogContacts);
        }
    }
     
    private void setFeedToContact(map<ID,Call_Log_Contact__c> map_CallLogContactId_CallLogContacts)
    {
    	Set<Id> listCallLogContactIds = map_CallLogContactId_CallLogContacts.keySet();
    	if(listCallLogContactIds.size() > 0)
    	{
	    	map<Id, list<SL_Trigger_Helper.AccountValues>> map_CallLogIds_ToContact = new map<Id, list<SL_Trigger_Helper.AccountValues>>();
	    	map<Id, list<SL_Trigger_Helper.AccountValues>> map_CallLogIds_ToAccount = new map<Id, list<SL_Trigger_Helper.AccountValues>>();
	    	for(Call_Log_Contact__c item :[	SELECT Call_Log__c, Contact__r.Name, Contact__c, Contact__r.Account.Name, Contact__r.AccountId
	    									FROM Call_Log_Contact__c
	    									WHERE ID IN :listCallLogContactIds])
	    	{
	    		if(item.Call_Log__c != null && item.Contact__c != null)
	    		{
	    			
	    			if(!map_CallLogIds_ToContact.keySet().contains(item.Call_Log__c))	map_CallLogIds_ToContact.put(item.Call_Log__c, new list<SL_Trigger_Helper.AccountValues>());
	    			map_CallLogIds_ToContact.get(item.Call_Log__c).add(new SL_Trigger_Helper.AccountValues(
	    																			item.Contact__c,
	    																			item.Contact__r.Name,
	    																			item.Contact__r.Account.Name));
	    			if(!map_CallLogIds_ToAccount.keySet().contains(item.Call_Log__c))	map_CallLogIds_ToAccount.put(item.Call_Log__c, new list<SL_Trigger_Helper.AccountValues>());
	    			map_CallLogIds_ToAccount.get(item.Call_Log__c).add(new SL_Trigger_Helper.AccountValues(
	    																			item.Contact__r.AccountId,
	    																			item.Contact__r.Name,
	    																			item.Contact__r.Account.Name));
	    		}
	    	}
	    	SL_Trigger_Helper.createFeedMessageMulty(map_CallLogIds_ToContact, 'Call Log');
	    	SL_Trigger_Helper.createFeedMessageMulty(map_CallLogIds_ToAccount, 'Call Log');
    	}
    } 
}