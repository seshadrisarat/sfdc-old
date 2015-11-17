/** 
 * \author Vika Osmak 
 * \date 11/23/2012
 * \see https://silverline.jira.com/browse/WP-34
 * \brief  Update Deal Advisor Trigger
 * \test 
 */
public without sharing class SL_handler_DealAdvisor 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    //private static boolean isDealAdvisorInserted = false;
    //private static boolean isDealAdvisorUpdated = false;
    
     
    public SL_handler_DealAdvisor(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnAfterInsert(map<Id,Deal_Advisor__c> newDealACs)
    {   
        //WP-34
    	setRollUpFields(newDealACs.values());
    }
       
    public void OnAfterUpdate(map<Id,Deal_Advisor__c> oldDealACs, map<Id,Deal_Advisor__c> newDealACs)
    {   
    	
    	//WP-34
    	setRollUpFields(newDealACs.values());
    }
    
    public void OnAfterDelete(list<Deal_Advisor__c> oldDealACs)
    {   
		//WP-34
    	setRollUpFields(oldDealACs);
    }
    
    private void setRollUpFields(list<Deal_Advisor__c> newDealAdvisor)
    {
    	map<Id,set<String>> mapDealId_EmployeeLNs = new map<Id,set<String>> ();
    	Set<Id> dealIds = new Set<Id>();
    	for(Deal_Advisor__c item : newDealAdvisor)
    	{
    		if(item.Deal__c != null) dealIds.add(item.Deal__c);
    	}
    	
    	if(dealIds.size() > 0)
    	{
	    	for(Deal_Advisor__c item : [SELECT ID,Deal__c,Deal_Advisor__c,Deal_Advisor__r.Name FROM Deal_Advisor__c WHERE Deal__c IN : dealIds ])
	    	{
	    		if(item.Deal_Advisor__c != null) 
	    		{
	    			if(!mapDealId_EmployeeLNs.containsKey(item.Deal__c))	mapDealId_EmployeeLNs.put(item.Deal__c,new set<String>());
	    			mapDealId_EmployeeLNs.get(item.Deal__c).add(item.Deal_Advisor__r.Name);
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
    			tmpDeal.Advisor__c = tmpStr;
    			
    			deals2Update.add(tmpDeal);
	    	}
	    	if(deals2Update.size() > 0)	update deals2Update;
    	}
    }
    
    
    
}