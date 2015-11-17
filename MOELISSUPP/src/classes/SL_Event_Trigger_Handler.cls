/** 
 * \author Vika Osmak 
 * \date 06/15/11
 * \see http://silverline.jira.com/browse/MC-1
 * \brief Ibanking_Project__c trigger handler. Runs onAfterInsert 
 * \test SL_Test_Deal_Trigger_Handler
 */
public without sharing class SL_Event_Trigger_Handler 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    private static boolean isFeedToFollowersAdded = false;
     
    public SL_Event_Trigger_Handler(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(map<ID,Event> newMap_EventIds_Events)
    {   
        if(!isFeedToFollowersAdded)
        {
            isFeedToFollowersAdded = true;
            setFeedToAccount(newMap_EventIds_Events);
        }
    }
     
    private void setFeedToAccount(map<ID,Event> newMap_EventIds_Events)
    {
    	Set<Id> listEventIds = newMap_EventIds_Events.keySet(); 
    	map<Id, SL_Trigger_Helper.AccountValues> map_EventIds_Account = new map<Id, SL_Trigger_Helper.AccountValues>();
    	map<Id, SL_Trigger_Helper.AccountValues> map_EventIds_Contact = new map<Id, SL_Trigger_Helper.AccountValues>();
    	map<Id, SL_Trigger_Helper.AccountValues> map_EventIds_ContactAccount = new map<Id, SL_Trigger_Helper.AccountValues>();
    	map<Id, Id> map_EventId_AccountId = new map<Id, Id>();
    	map<Id, Id> map_EventId_WhoId = new map<Id, Id>();
    	
    	Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
		String AccountPrefix = R.getKeyPrefix();
		
    	for(Event item :[	SELECT id,Account.Name, AccountId,Who.Name,WhoId,WhatId,What.Name
    						FROM Event
    						WHERE Id IN : listEventIds])
    	{
	    	if(item.WhatId != null && String.valueOf(item.WhatId).substring(0,3) == AccountPrefix) 
	    		map_EventIds_Account.put(item.Id,new SL_Trigger_Helper.AccountValues(item.WhatId,item.What.Name));
	    		
	    	if(item.WhoId != null) map_EventId_WhoId.put(item.Id,item.WhoId);
    	}
    	
    	//add feed to Campany (in WhatId)
    	SL_Trigger_Helper.createFeedMessage(map_EventIds_Account, 'Meeting');
    	
    	list<Id> listContactIds = map_EventId_WhoId.values();
    	map<Id, Contact> mapContactId_Contact = new map<Id, Contact>();
    	if(listContactIds.size() > 0)
    	{
    		for(Contact item : [SELECT Id, Name, Account.Name, AccountId FROM Contact WHERE ID IN : listContactIds])
    			mapContactId_Contact.put(item.Id, item);
    		for(Id eventId : map_EventId_WhoId.keySet())
    		{
    			map_EventIds_Contact.put(eventId, new SL_Trigger_Helper.AccountValues(
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).Id, 
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).Name, 
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).Account.Name
    													)
    									  );
    			map_EventIds_ContactAccount.put(eventId, new SL_Trigger_Helper.AccountValues(
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).AccountId, 
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).Name, 
    														mapContactId_Contact.get(map_EventId_WhoId.get(eventId)).Account.Name
    													)
    									  );
    		}
    		//add feed to Contact (in WhoId)
    		SL_Trigger_Helper.createFeedMessage(map_EventIds_Contact, 'Meeting');
    		//add feed to Campany assosiated with Contact(in WhatId)
    		SL_Trigger_Helper.createFeedMessage(map_EventIds_ContactAccount, 'Meeting');
    	}
    	
    } 
}