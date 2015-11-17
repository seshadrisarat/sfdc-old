/** 
 * \author Vika Osmak 
 * \date 06/16/11
 * \see 
 * \brief Help class is used in classes: SL_Deal_Trigger_Handler,SL_PBI_Trigger_Handler,SL_CallLogRelated_Trigger_Handler
 * \test 
 */
public class SL_Trigger_Helper 
{
	public static void createFeedMessage(map<ID, SL_Trigger_Helper.AccountValues> newMap_Id_AccountValues, String activity)
	{
		string BaseURL = URL.getSalesforceBaseUrl().getProtocol()+'://'+URL.getSalesforceBaseUrl().getHost();
		list<FeedItem> listFeedItemToAdd = new list<FeedItem>();
    	for(Id ID: newMap_Id_AccountValues.keySet())
    	{
    		//Adding a Link post
			FeedItem post = new FeedItem();
			post.ParentId = newMap_Id_AccountValues.get(ID).objectId;
			post.Body = UserInfo.getName()+' has created a '+activity+' with '+newMap_Id_AccountValues.get(ID).objectName;
			if(newMap_Id_AccountValues.get(ID).objectNameAdditional != null) post.Body += ' from '+newMap_Id_AccountValues.get(ID).objectNameAdditional;
			post.LinkUrl = BaseURL+'/'+ID;
			listFeedItemToAdd.add(post);
    		if(listFeedItemToAdd.size() == 100 ) 
    		{	
    			insert listFeedItemToAdd;
    			listFeedItemToAdd = new list<FeedItem>(); 
    		}
    	}
    	if(listFeedItemToAdd.size() > 0 ) insert listFeedItemToAdd;
	}
	
	public static void createFeedMessageMulty(map<ID, list<SL_Trigger_Helper.AccountValues>> newMap_Id_AccountValues, String activity)
	{
		string BaseURL = URL.getSalesforceBaseUrl().getProtocol()+'://'+URL.getSalesforceBaseUrl().getHost();
		list<FeedItem> listFeedItemToAdd = new list<FeedItem>();
    	for(Id ID: newMap_Id_AccountValues.keySet())
    	{
    		if(newMap_Id_AccountValues.get(ID) != null )
    		{
    			for(SL_Trigger_Helper.AccountValues obj : newMap_Id_AccountValues.get(ID))
    			{
    				//Adding a Link post
					FeedItem post = new FeedItem();
					post.ParentId = obj.objectId;
					post.Body = UserInfo.getName()+' has created a '+activity+' with '+obj.objectName;
					if(obj.objectNameAdditional != null) post.Body += ' from '+obj.objectNameAdditional;
					post.LinkUrl = BaseURL+'/'+ID;
					listFeedItemToAdd.add(post);
		    		if(listFeedItemToAdd.size() == 100 ) 
		    		{	
		    			insert listFeedItemToAdd;
		    			listFeedItemToAdd = new list<FeedItem>(); 
		    		}
    			}
    		}
    		
    	}
    	if(listFeedItemToAdd.size() > 0 ) insert listFeedItemToAdd;
	}
	
	public static void createFeedMessageForContactsOfAccount(map<Id, Id> map_objId_AccountId, String activity)
	{
		system.debug('map_objId_AccountId = '+map_objId_AccountId);
		list<Id> listAccountIds = map_objId_AccountId.values();
		map<Id, list<Contact>> map_AccountId_Contacts = new map<Id, list<Contact>>();
    	for(Contact item :[	SELECT Id,Account.Name,Name, AccountId
    						FROM Contact
    						WHERE AccountId IN : listAccountIds])
    	{
    		if(!map_AccountId_Contacts.keySet().contains(item.AccountId)) map_AccountId_Contacts.put(item.AccountId, new list<Contact>());
    		map_AccountId_Contacts.get(item.AccountId).add(item);
    	}
    	//system.debug('map_AccountId_Contacts = '+map_AccountId_Contacts);
    	map<Id, list<SL_Trigger_Helper.AccountValues>> map_objId_ContactAccount = new map<Id, list<SL_Trigger_Helper.AccountValues>>();
    	for(Id objId : map_objId_AccountId.keySet())
    	{
    		//system.debug('map_objId_AccountId.get(dealId) = '+map_objId_AccountId.get(objId));
    			//system.debug('map_AccountId_Contacts.get(map_objId_AccountId.get(dealId)) = '+map_AccountId_Contacts.get(map_objId_AccountId.get(objId)));
    			
    		if(map_objId_AccountId.get(objId) != null && map_AccountId_Contacts.get(map_objId_AccountId.get(objId)) != null )
    		{
    			for(Contact itemContact : map_AccountId_Contacts.get(map_objId_AccountId.get(objId)))
    			{
    				if(!map_objId_ContactAccount.keySet().contains(objId)) map_objId_ContactAccount.put(objId,new list<SL_Trigger_Helper.AccountValues>());
    				map_objId_ContactAccount.get(objId).add(new SL_Trigger_Helper.AccountValues(itemContact.Id,itemContact.Name,itemContact.Account.Name));
    			}
    		}
    	}
    	//system.debug('map_objId_ContactAccount = '+map_objId_ContactAccount);
    	string BaseURL = URL.getSalesforceBaseUrl().getProtocol()+'://'+URL.getSalesforceBaseUrl().getHost();
		list<FeedItem> listFeedItemToAdd = new list<FeedItem>();
    	for(Id objId : map_objId_ContactAccount.keySet())
    	{
    		for(SL_Trigger_Helper.AccountValues item : map_objId_ContactAccount.get(objId))
	    	{
	    		//Adding a Link post
				FeedItem post = new FeedItem();
				post.ParentId = item.objectId;
				post.Body = UserInfo.getName()+' has created a '+activity+' with '+item.objectName+' from '+item.objectNameAdditional;
				post.LinkUrl = BaseURL+'/'+objId;
				listFeedItemToAdd.add(post);
	    		if(listFeedItemToAdd.size() == 100 ) 
	    		{	
	    			insert listFeedItemToAdd;
	    			listFeedItemToAdd = new list<FeedItem>(); 
	    		}
	    	}
    	}
    	if(listFeedItemToAdd.size() > 0 ) insert listFeedItemToAdd;
    	//SL_Trigger_Helper.createFeedMessage(map_objId_ContactAccount, activity);
	}
	
	public class AccountValues
	{
		public Id objectId { get; set; }
		public String objectName { get; set; }
		public String objectNameAdditional { get; set; }
		public AccountValues(Id p_objectId,String p_objectName)
		{
			this.objectId = p_objectId;
			this.objectName = p_objectName;
		}
		public AccountValues(Id p_objectId,String p_objectName,String p_objectNameAdditional)
		{
			this.objectId = p_objectId;
			this.objectName = p_objectName;
			this.objectNameAdditional = p_objectNameAdditional;
		}
	}
}