public without sharing class SL_handler_Bid 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public SL_handler_Bid(boolean isExecuting, integer size)
    {
        m_isExecuting = isExecuting;
        BatchSize = size;
    } 
    
    public void OnAfterInsert(map<Id,Bid__c> newBids)
    {   
    	updateDeals(newBids.values());
    }
    public void OnAfterUpdate(map<Id,Bid__c> oldBids,map<Id,Bid__c> newBids)
    {   
    	updateDeals(newBids.values());
    }
    public void OnAfterDelete(map<Id,Bid__c> oldBids)
    {   
    	updateDeals(oldBids.values());
    }
    
    private void updateDeals(list<Bid__c> listBids)
    {
    	set<Id> setDealIds = new set<Id>();
    	for(Bid__c bid : listBids)
	    {
	    	setDealIds.add(bid.Deal__c);
	    }
	    map<ID, Bid__c> map_DealId_maxBidDate = new map<ID, Bid__c>();
	    if(setDealIds.Size() > 0)
	    {
	    	for(Bid__c item : [	
	    			SELECT 	Bid_Date__c,Deal__r.Bid_Date__c, 
	    					Bid_Stage__c,Deal__r.Bid_Stage__c,
	    					Deal__r.Implied_Ent_Value_High__c,Implied_Ent_Value_High__c,
						    Deal__r.Implied_Ent_Value_Low__c, Implied_Ent_Value_Low__c,
						    WP_Equity_High__c, Deal__r.WP_Equity_Value_High__c, 
	    					WP_Equity_Low__c, Deal__r.WP_Equity_Value__c,
	    					Bid_Comments__c, Deal__r.Bid_Comments__c
	    					
	    					/*
	    					Bid_High__c,Deal__r.Bid_High__c, 
	    					Bid_Low__c,Deal__r.Bid_Low__c,
	    					Comment__c,	
	    					Deal__r.Equity_Value__c,  Deal__r.Equity_Value_High__c,	
	    					Ent_Value_High__c,Deal__r.Enterprise_Value_High__c,	
	    					Ent_Value_Low__c,Deal__r.Enterprise_Value_Low__c,
	    					*/
	    			FROM Bid__c
	    			WHERE Deal__c IN : setDealIds 
	    			ORDER By Deal__c,Bid_Date__c DESC])
		    {
		    	if(!map_DealId_maxBidDate.containskey(item.Deal__c)) map_DealId_maxBidDate.put(item.Deal__c, item);
                else
                {
                    if(map_DealId_maxBidDate.get(item.Deal__c).Bid_Date__c <= item.Bid_Date__c)
                        map_DealId_maxBidDate.put(item.Deal__c, item);
                }
		    }
		    system.debug('map_DealId_maxBidDate = '+map_DealId_maxBidDate);
	    }
	    
	    list<Deal__c> listDeals2Update = new list<Deal__c>();
	    Deal__c deal;
	    Bid__c bid;
        for(Id dId : setDealIds)
        {
        	bid = map_DealId_maxBidDate.get(dId);
        	deal = new Deal__c(Id = dId);
        	if(bid != null)
        	{
                
                if( bid.Deal__r.Bid_Date__c != bid.Bid_Date__c ||
                	bid.Deal__r.Bid_Stage__c != bid.Bid_Stage__c ||
				    bid.Deal__r.Implied_Ent_Value_High__c != bid.Implied_Ent_Value_High__c ||
				    bid.Deal__r.Implied_Ent_Value_Low__c != bid.Implied_Ent_Value_Low__c ||
				    bid.Deal__r.WP_Equity_Value_High__c != bid.WP_Equity_High__c ||
				    bid.Deal__r.WP_Equity_Value__c != bid.WP_Equity_Low__c ||
				    bid.Deal__r.Bid_Comments__c != bid.Bid_Comments__c
                	/*
				    bid.Deal__r.Bid_High__c != bid.Bid_High__c ||
				    bid.Deal__r.Bid_Low__c != bid.Bid_Low__c ||
				    bid.Deal__r.Bid_Stage__c != bid.Bid_Stage__c ||
				    bid.Deal__r.Bid_Comments__c != bid.Comment__c ||
				    bid.Deal__r.Enterprise_Value_High__c != bid.Ent_Value_High__c ||
				    bid.Deal__r.Enterprise_Value_Low__c != bid.Ent_Value_Low__c ||
				    bid.Deal__r.Equity_Value_High__c != bid.WP_Equity_High__c ||
				    bid.Deal__r.Equity_Value__c != bid.WP_Equity_Low__c
				    */
				    )
                {
				    deal.Bid_Date__c = bid.Bid_Date__c;
				    deal.Bid_Stage__c = bid.Bid_Stage__c;
				    deal.Implied_Ent_Value_High__c = bid.Implied_Ent_Value_High__c;
				    deal.Implied_Ent_Value_Low__c = bid.Implied_Ent_Value_Low__c;
				    deal.WP_Equity_Value_High__c = bid.WP_Equity_High__c;
				    deal.WP_Equity_Value__c = bid.WP_Equity_Low__c;
				    deal.Bid_Comments__c = bid.Bid_Comments__c;
				    
				   	/*
				    deal.Bid_High__c = bid.Bid_High__c;
				    deal.Bid_Low__c = bid.Bid_Low__c;
				    deal.Bid_Comments__c = bid.Comment__c;
				    deal.Enterprise_Value_High__c = bid.Ent_Value_High__c;
				    deal.Enterprise_Value_Low__c = bid.Ent_Value_Low__c;
				    deal.Equity_Value_High__c = bid.WP_Equity_High__c; 
				    deal.Equity_Value__c = bid.WP_Equity_Low__c;
				    */

                    listDeals2Update.add(deal);
                }
            }
            else
            {
            	deal.Bid_Date__c = null;
				deal.Bid_Stage__c = null;
				deal.Implied_Ent_Value_High__c = null;
				deal.Implied_Ent_Value_Low__c = null;
				deal.WP_Equity_Value_High__c = null;
				deal.WP_Equity_Value__c = null;
				deal.Bid_Comments__c = null;
            	/*
				deal.Bid_High__c = null;
				deal.Bid_Low__c = null;
				deal.Bid_Stage__c = null;
				deal.Bid_Comments__c = null;
				deal.Enterprise_Value_High__c = null;
				deal.Enterprise_Value_Low__c = null;
				deal.Equity_Value_High__c = null;
				deal.Equity_Value__c = null;
				*/
                listDeals2Update.add(deal);
            }
        }
        system.debug('listDeals2Update = '+listDeals2Update);
        if(listDeals2Update.size() > 0 ) update listDeals2Update;
    }
    
}