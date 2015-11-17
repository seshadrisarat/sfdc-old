/** 
 * \author Vika Osmak 
 * \date 10/09/2012
 * \see https://silverline.jira.com/browse/WP-6
 * \brief  Update Deal Advisor Trigger
 * \test SL_test_handlerDealAdvisorContact
 */
public without sharing class SL_handler_DealAdvisorContact 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    //private static boolean isDealAdvisorInserted = false;
    //private static boolean isDealAdvisorUpdated = false;
    
     
    public SL_handler_DealAdvisorContact(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(list<Deal_Advisor_Contact__c> newDealACs)
    {   
        //if(!isDealAdvisorInserted)
        ///{
            //isDealAdvisorInserted = true;
            setDealAdvisor_CompaniesUNIQUE_INS(newDealACs);
        //}
    }
    public void OnAfterInsert(map<Id,Deal_Advisor_Contact__c> newDealACs)
    {   
        //WP-34
    	setRollUpFields(newDealACs.values());
    }
       
    public void OnAfterUpdate(map<Id,Deal_Advisor_Contact__c> oldDealACs, map<Id,Deal_Advisor_Contact__c> newDealACs)
    {   
    	
    	//WP-34
    	setRollUpFields(newDealACs.values());
    	/*
        if(!isDealAdvisorUpdated)
        {
            isDealAdvisorUpdated = true;
            list<Deal_Advisor_Contact__c> oldlistDealsAC = new list<Deal_Advisor_Contact__c>();
			list<Deal_Advisor_Contact__c> newlistDealsAC = new list<Deal_Advisor_Contact__c>();
            for(Id itemId : newDealACs.keySet())
            {
            	//if(	newDealACs.get(itemId).Contact__c != oldDealACs.get(itemId).Contact__c ||
            	///	newDealACs.get(itemId).Deal__c != oldDealACs.get(itemId).Deal__c)
            	//{
            		newlistDealsAC.add(newDealACs.get(itemId));
            		oldlistDealsAC.add(oldDealACs.get(itemId));
            	//}
            }
            if(newlistDealsAC.size() > 0) setDealAdvisor_CompaniesUNIQUE_UPD(newlistDealsAC, oldlistDealsAC);
        }
        */
    }
    
    public void OnAfterDelete(list<Deal_Advisor_Contact__c> oldDealACs)
    {   
		//WP-34
    	setRollUpFields(oldDealACs);
		//setDealAdvisor_CompaniesUNIQUE_DEL(oldDealACs);
    }
    
    private void setRollUpFields(list<Deal_Advisor_Contact__c> newDealAdvisorContact)
    {
    	map<Id,set<String>> mapDealId_EmployeeLNs = new map<Id,set<String>> ();
    	Set<Id> dealIds = new Set<Id>();
    	for(Deal_Advisor_Contact__c item : newDealAdvisorContact)
    	{
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	
    	if(dealIds.size() > 0)
    	{
	    	for(Deal_Advisor_Contact__c item : [SELECT ID,Deal__c,Contact__c,Contact__r.LastName FROM Deal_Advisor_Contact__c WHERE Deal__c IN : dealIds ])
	    	{
	    		if(item.Contact__c != null) 
	    		{
	    			if(!mapDealId_EmployeeLNs.containsKey(item.Deal__c))	mapDealId_EmployeeLNs.put(item.Deal__c,new set<String>());
	    			mapDealId_EmployeeLNs.get(item.Deal__c).add(item.Contact__r.LastName);
	    		}
	    	}
	    	system.debug('mapDealId_EmployeeLNs = '+mapDealId_EmployeeLNs);
	    	
	    	list<Deal__c> deals2Update = new list<Deal__c>();
	    	Deal__c tmpDeal;
	    	String tmpStr = '';
	    	for(Id dealId : dealIds)
	    	{
	    		tmpDeal = new Deal__c(Id = dealId);
    			tmpStr = '';
    			if(mapDealId_EmployeeLNs.get(dealId) != null && mapDealId_EmployeeLNs.get(dealId).size() > 0)
    			{
	    			for(String EmpLN : mapDealId_EmployeeLNs.get(dealId)) tmpStr += ','+EmpLN;
	    			if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
	    			if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
    			}
    			tmpDeal.Advisor_Contact__c = tmpStr;
    			
    			deals2Update.add(tmpDeal); 
	    	}
	    	if(deals2Update.size() > 0)	update deals2Update;
    	}
    }
    
    
    
    
    //Deal Advisors will contain the UNIQUE list of companies contained in Deal Advisor Contacts.
    private void setDealAdvisor_CompaniesUNIQUE_INS(list<Deal_Advisor_Contact__c> newDealsAC)
    {
    	
    	map<Id, Id> mapContactId_AccountId = new map<Id, Id>();
    	String strDealIdAccId = '';
    	map<String,Id> map_strDealIdAccId_DealAdvisorId_existed = new map<String,Id>();
    	set<Id> setDealId = new set<Id>();
    	set<String> setDealContact = new set<String>();
    	set<String> setDealContact_existed= new set<String>();
    	Boolean isError = false;
    	if(newDealsAC != null && newDealsAC.size() > 0)
    	{
	    	for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    	{
	    		if(dealAC.Contact__c != null && dealAC.Deal__c != null)	
	    		{
	    			mapContactId_AccountId.put(dealAC.Contact__c, null);
	    			setDealId.add(dealAC.Deal__c);
	    			
	    			if(setDealContact.contains(dealAC.Deal__c+'_'+dealAC.Contact__c)) 
	    				isError = true;//dealAC.addError('Error: Duplicate contacts for the same deal.');
	    			setDealContact.add(dealAC.Deal__c+'_'+dealAC.Contact__c);
	    		}
	    	}
	    	
    	} 
    	
    	if(mapContactId_AccountId.keySet().size() > 0)
    	{
    			for(Contact item: [
    						SELECT ID,AccountId
    						FROM Contact
    						WHERE ID IN : mapContactId_AccountId.keySet()])
    			{
    				mapContactId_AccountId.put(item.Id, item.AccountId);
    			}
    			//system.debug('mapContactId_AccountId='+mapContactId_AccountId);
    			for(Deal_Advisor__c item: [
    						SELECT ID,Deal__c,Deal_Advisor__c
    						FROM Deal_Advisor__c
    						WHERE Deal__c IN : setDealId AND Deal_Advisor__c IN : mapContactId_AccountId.values()])
    			{
    				map_strDealIdAccId_DealAdvisorId_existed.put(item.Deal__c +'_'+ item.Deal_Advisor__c,item.Id);
    			}
    			
    			for(Deal_Advisor_Contact__c item: [
    						SELECT ID,Deal__c,Contact__c
    						FROM Deal_Advisor_Contact__c
    						WHERE Deal__c IN : setDealId AND Contact__c IN : mapContactId_AccountId.keySet()])
    			{
    				setDealContact_existed.add(item.Deal__c+'_'+item.Contact__c);
    			}
    			
    	}
    	//system.debug('map_strDealIdAccId_DealAdvisorId_existed='+map_strDealIdAccId_DealAdvisorId_existed);
    	
    	// inserting
    	if(newDealsAC.size() > 0)
    	{	
    		list<Deal_Advisor__c> listDealAdvisor2Insert = new list<Deal_Advisor__c>();
    		for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    	{
	    		if(dealAC.Contact__c != null && dealAC.Deal__c != null)	
	    		{
	    			if(	setDealContact_existed.contains(dealAC.Deal__c+'_'+dealAC.Contact__c)) 
	    			{
	    				isError = true;
	    				//setDealContact_error.add(dealAC.Deal__c+'_'+dealAC.Contact__c);
	    			}
	    		}
	    	}
    		for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    	{
	    		if(isError)	dealAC.addError('Error: Duplicate contacts for the same deal.');
	    		else
	    		{
		    		if(dealAC.Deal__c != null && mapContactId_AccountId.get(dealAC.Contact__c) != null)
		    		{
		    			strDealIdAccId = dealAC.Deal__c +'_'+ mapContactId_AccountId.get(dealAC.Contact__c);
		    			if(map_strDealIdAccId_DealAdvisorId_existed.containsKey(strDealIdAccId))
		    				dealAC.Deal_Advisor__c = map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId);
		    			else 
		    			{
		    				map_strDealIdAccId_DealAdvisorId_existed.put(strDealIdAccId, null);
		    				listDealAdvisor2Insert.add(new Deal_Advisor__c(Deal__c = dealAC.Deal__c, Deal_Advisor__c = mapContactId_AccountId.get(dealAC.Contact__c)));
		    			}
		    		}
	    		}
	    	}
	    	//system.debug('listDealAdvisor2Insert 1 = '+listDealAdvisor2Insert);
    		if(!isError && listDealAdvisor2Insert.size() > 0)
    		{
    			insert listDealAdvisor2Insert;
    			for(Deal_Advisor__c item : listDealAdvisor2Insert)
    			{
    				if(	map_strDealIdAccId_DealAdvisorId_existed.containsKey(item.Deal__c +'_'+ item.Deal_Advisor__c) && 
    					map_strDealIdAccId_DealAdvisorId_existed.get(item.Deal__c +'_'+ item.Deal_Advisor__c) == null
    					)	map_strDealIdAccId_DealAdvisorId_existed.put(item.Deal__c +'_'+ item.Deal_Advisor__c,item.Id);
    			}
    			//system.debug('listDealAdvisor2Insert 2 = '+listDealAdvisor2Insert);
    			for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    		{
		    		if(	dealAC.Deal_Advisor__c == null &&
		    			dealAC.Deal__c != null && 
		    			mapContactId_AccountId.get(dealAC.Contact__c) != null)
		    		{
		    			strDealIdAccId = dealAC.Deal__c +'_'+ mapContactId_AccountId.get(dealAC.Contact__c);
		    			if(map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId) != null)
	    					dealAC.Deal_Advisor__c = map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId);
		    		}
		    		if(dealAC.Deal_Advisor__c == null) dealAC.addError('Deal Advisor field is Empty!');
	    		}
    		}
    	}
    	
    } 
    
    /*
    private void setDealAdvisor_CompaniesUNIQUE_DEL(list<Deal_Advisor_Contact__c> oldDealsAC)
    {
    	set<ID> setDealAdvisorIds = new set<ID>();
    	set<ID> setDealAdvisorContactIds = new set<ID>();
    	map<ID, Integer> map_DealAdvisorId_countContacts = new map<ID, Integer>();
    	if(oldDealsAC.size() > 0)
    	{
	    	for(Deal_Advisor_Contact__c dealAC : oldDealsAC)
	    	{
	    		if(dealAC.Deal_Advisor__c != null) map_DealAdvisorId_countContacts.put(dealAC.Deal_Advisor__c,0); 
	    	}
	    	if(map_DealAdvisorId_countContacts.keySet().size() > 0)
	    	{
	    		for(Deal_Advisor_Contact__c item: [
    						SELECT ID,Deal__c,Contact__c,Deal_Advisor__c
    						FROM Deal_Advisor_Contact__c
    						WHERE Deal_Advisor__c IN : map_DealAdvisorId_countContacts.keySet()])
    			{
    				map_DealAdvisorId_countContacts.put(item.Deal_Advisor__c,map_DealAdvisorId_countContacts.get(item.Deal_Advisor__c) + 1);
    			}
	    		list<Deal_Advisor__c> DealAdvisor2Delete = new list<Deal_Advisor__c>();
	    		for(Deal_Advisor_Contact__c dealAC : oldDealsAC)
	    		{
	    			if(	dealAC.Deal_Advisor__c != null && map_DealAdvisorId_countContacts.get(dealAC.Deal_Advisor__c) == 0) 
	    			{
	    				Deal_Advisor__c dealA2Delete = new Deal_Advisor__c(Id = dealAC.Deal_Advisor__c);
	    				DealAdvisor2Delete.add(dealA2Delete);
	    			}  
	    		}
	    		if(DealAdvisor2Delete.size() > 0) delete DealAdvisor2Delete;
	    	}
    	}
    	system.debug('map_DealAdvisorId_countContacts='+map_DealAdvisorId_countContacts);
    } 
    */
    
    
    /*
    private void setDealAdvisor_CompaniesUNIQUE_UPD(list<Deal_Advisor_Contact__c> oldDealsAC,list<Deal_Advisor_Contact__c> newDealsAC)
    {
    	
    	map<Id, Id> mapContactId_AccountId = new map<Id, Id>();
    	
    	String strDealIdAccId = '';
    	map<String,Id> map_strDealIdAccId_DealAdvisorId_existed = new map<String,Id>();
    	
    	map<Id,String> map_DealAdvisorContactId_newDealIdAccId = new map<Id,String>();
    	//map<String,Id> map_newDealIdAccId_oldDealAdvisorId = new map<String,Id>();
    	//map<String,set<Id>> map_newDealIdAccId_setDealAdvisorContactId = new map<String,set<Id>>();
    	map<Id,set<Id>> map_oldDealAdvisorId_setDealAdvisorContactId = new map<Id,set<Id>>();
    	
    	
    	
    	set<Id> setDealId = new set<Id>();
    	//map<Id, Id> map_DealAdvisorContactId_oldDealAdvisorId = new map<Id, Id>();
    	if(newDealsAC != null && newDealsAC.size() > 0)
    	{
	    	for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    	{
	    		if(dealAC.Contact__c != null && dealAC.Deal__c != null)	
	    		{
	    			mapContactId_AccountId.put(dealAC.Contact__c, null);
	    			setDealId.add(dealAC.Deal__c);
	    		}
	    		//if(dealAC.Deal_Advisor__c != null) 
	    		//{
	    			//map_DealAdvisorContactId_oldDealAdvisorId.put(dealAC.Id,dealAC.Deal_Advisor__c);
	    		//}
	    	}
    	}
    	
    	
    	
    	
    	if(mapContactId_AccountId.keySet().size() > 0)
    	{
    		for(Contact item: [
    						SELECT ID,AccountId
    						FROM Contact
    						WHERE ID IN : mapContactId_AccountId.keySet()])
    		{
    				mapContactId_AccountId.put(item.Id, item.AccountId);
    		}
    			system.debug('mapContactId_AccountId='+mapContactId_AccountId);
    			
    		for(Deal_Advisor__c item: [
    						SELECT ID,Deal__c,Deal_Advisor__c
    						FROM Deal_Advisor__c
    						WHERE Deal__c IN : setDealId AND Deal_Advisor__c IN : mapContactId_AccountId.values()])
    		{
    				map_strDealIdAccId_DealAdvisorId_existed.put(item.Deal__c +'_'+ item.Deal_Advisor__c,item.Id);
    		}
    	}
    	system.debug('map_strDealIdAccId_DealAdvisorId_existed='+map_strDealIdAccId_DealAdvisorId_existed);
    	//
    	
    	
    	
    	
    	
    	// inserting
    	if(newDealsAC != null && newDealsAC.size() > 0)
    	{	
    		list<Deal_Advisor__c> listDealAdvisor2Insert = new list<Deal_Advisor__c>();
    		
    		set<Id> setAllDACIdsForCheck = new set<Id>();
    		for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    	{
	    		if(dealAC.Deal__c != null && mapContactId_AccountId.get(dealAC.Contact__c) != null)
	    		{
	    			strDealIdAccId = dealAC.Deal__c +'_'+ mapContactId_AccountId.get(dealAC.Contact__c);
	    			//map_DealAdvisorContactId_newDealIdAccId.put(dealAC.Id,strDealIdAccId);
	    			//map_newDealIdAccId_oldDealAdvisorId.put(strDealIdAccId, dealAC.Deal_Advisor__c);
	    			
	    			
	    			
	    			if(map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId) != null)
	    			{
	    				if(map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId) != dealAC.Deal_Advisor__c )
	    				{
	    					setAllDACIdsForCheck.add(dealAC.Id);
	    					
	    					if(!map_oldDealAdvisorId_setDealAdvisorContactId.containsKey(dealAC.Deal_Advisor__c)) 
			    				map_oldDealAdvisorId_setDealAdvisorContactId.put(dealAC.Deal_Advisor__c, new set<Id>());
			    			map_oldDealAdvisorId_setDealAdvisorContactId.get(dealAC.Deal_Advisor__c).add(dealAC.Id);
			    			
	    					dealAC.Deal_Advisor__c = map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId);
	    				}
	    			}
	    			else 
	    				listDealAdvisor2Insert.add(new Deal_Advisor__c(Deal__c = dealAC.Deal__c, Deal_Advisor__c = mapContactId_AccountId.get(dealAC.Contact__c)));
	    		}
    			
	    	}
	    	
	    	map<ID, Integer> map_DealAdvisorId_countDAContacts = new map<ID, Integer>();
	    	if(map_oldDealAdvisorId_setDealAdvisorContactId.keySet().size() > 0)
	    	{
	    		for(Deal_Advisor_Contact__c item: [
    						SELECT ID,Deal__c,Contact__c,Deal_Advisor__c
    						FROM Deal_Advisor_Contact__c
    						WHERE Deal_Advisor__c IN : map_oldDealAdvisorId_setDealAdvisorContactId.keySet() ])
    			{
    			//	map_strDealIdAccId_DealAdvisorId_existed.put(item.Deal__c +'_'+ item.Deal_Advisor__c,item.Id);
    				if(!map_oldDealAdvisorId_setDealAdvisorContactId.get(item.Deal_Advisor__c).contains(item.Deal_Advisor__c))
    				{
    					if(!map_DealAdvisorId_countDAContacts.keySet().contains(item.Deal_Advisor__c)) map_DealAdvisorId_countDAContacts.put(item.Deal_Advisor__c,0);
    					map_DealAdvisorId_countDAContacts.put(item.Deal_Advisor__c,map_DealAdvisorId_countDAContacts.get(item.Deal_Advisor__c) + 1);
    				}
    			}
	    		list<Deal_Advisor__c> DealAdvisor2Delete = new list<Deal_Advisor__c>();
	    		for(Deal_Advisor_Contact__c dealAC : oldDealsAC)
	    		{
	    			if(	dealAC.Deal_Advisor__c != null && map_DealAdvisorId_countDAContacts.get(dealAC.Deal_Advisor__c) == 0) 
	    			{
	    				Deal_Advisor__c dealA2Delete = new Deal_Advisor__c(Id = dealAC.Deal_Advisor__c);
	    				DealAdvisor2Delete.add(dealA2Delete);
	    			}  
	    		}
	    		if(DealAdvisor2Delete.size() > 0) delete DealAdvisor2Delete;
	    }
	    
    	system.debug('map_DealAdvisorId_countDAContacts='+map_DealAdvisorId_countDAContacts);
	    	
	    	
	    system.debug('listDealAdvisor2Insert='+listDealAdvisor2Insert);
    		if(listDealAdvisor2Insert.size() > 0)
    		{
    			insert listDealAdvisor2Insert;
    			map_strDealIdAccId_DealAdvisorId_existed = new map<String,Id>();
    			for(Deal_Advisor__c item : listDealAdvisor2Insert)
    			{
    				map_strDealIdAccId_DealAdvisorId_existed.put(item.Deal__c +'_'+ item.Deal_Advisor__c,item.Id);
    			}
    			for(Deal_Advisor_Contact__c dealAC : newDealsAC)
	    		{
		    		if(	dealAC.Deal_Advisor__c == null &&
		    			dealAC.Deal__c != null && 
		    			mapContactId_AccountId.get(dealAC.Contact__c) != null)
		    		{
		    			strDealIdAccId = dealAC.Deal__c +'_'+ mapContactId_AccountId.get(dealAC.Contact__c);
		    			if(map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId) != null)
	    					dealAC.Deal_Advisor__c = map_strDealIdAccId_DealAdvisorId_existed.get(strDealIdAccId);
		    		}
		    		if(dealAC.Deal_Advisor__c == null) dealAC.addError('Deal Advisor field is Empty!');
	    		}
    		}
    		
    		
    	}
    } 
    */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}