public without sharing class SL_handler_AdministrativeAccounting 
{
	private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public SL_handler_AdministrativeAccounting(boolean isExecuting, integer size)
    {
		m_isExecuting = isExecuting;
		BatchSize = size;
    } 
    
    public void OnAfterInsert(map<Id,Administrative_Accounting__c> newAAs)
    {   
		updateCompany(newAAs.values());
//		updateDeal(newAAs.values());
      updateDeal(new map<Id,Administrative_Accounting__c>(),newAAs);
		// WP-59
    	updateAccount(newAAs);
    }
    public void OnAfterUpdate(map<Id,Administrative_Accounting__c> oldAAs,map<Id,Administrative_Accounting__c> newAAs)
    {   
		updateCompany(newAAs.values());
//		updateDeal(newAAs.values());
      updateDeal(oldAAs,newAAs);
		// WP-59
		updateAccount(newAAs);
    }

    private set<Id> set_del_AA_ids = new set<Id>(); 
    public void OnAfterDelete(map<Id,Administrative_Accounting__c> oldAAs)
    {   
    	updateCompany(oldAAs.values());
//    	updateDeal(oldAAs.values());
   //   updateDeal(oldAAs,new map<Id,Administrative_Accounting__c>());
      	updateDeal(new map<Id,Administrative_Accounting__c>(),oldAAs);     
      
    	// WP-59
    	for(Id AA_id: oldAAs.KeySet())
    	   set_del_AA_ids.add(AA_id);
		updateAccount(oldAAs);
    }


/** 
* \ Trigger for Fund Information field on Account 
* \details Additional 
* \ Trigger on Administrative_Accounting_c on insert/update/delete to maintain Account field Fund_Detailsc with a comma delimited list of Administrative_Accounting.Fundc (C:Administrative_Accounting.Original_Costc, CV:Administrative_Accounting.Carrying_Value_c).
* \author Vlad Gumenyuk 
* \date 12/24/2012
* \see https://silverline.jira.com/browse/WP-59
*/
    private void updateAccount(map<Id,Administrative_Accounting__c> mapAAs)
    {
       set<Id> setDealIds = new set<Id>();
       for(Administrative_Accounting__c aa : mapAAs.values())
       {
         setDealIds.add(aa.Deal__c);
       }
       map<ID, set<Id>> map_acc_id_set_AA_ids = new map<ID, set<Id>>();
       map<Id,Administrative_Accounting__c> map_AA = new map<Id,Administrative_Accounting__c>([SELECT a.Id, a.Deal__c,a.Deal__r.Fund_Details__c, a.Original_Cost__c, a.Fund__r.Name, a.Fund__c, a.Carrying_Value__c, a.Cost__c FROM Administrative_Accounting__c a WHERE Deal__c IN :setDealIds]);
       map<Id,Deal__c> map_update_acc = new map<Id,Deal__c>();
       for(Administrative_Accounting__c AA : map_AA.values()) {
       	if(AA.Deal__c!=null) {
            map_update_acc.put(AA.Deal__c,new Deal__c(id = AA.Deal__c, Fund_Details__c = ''));
         
            if(map_acc_id_set_AA_ids.containsKey(AA.Deal__c))
               map_acc_id_set_AA_ids.get(AA.Deal__c).add(AA.Id);
            else { 
               Set<Id> set_aa_ids = new Set<Id>();
               set_aa_ids.add(AA.Id);	
               map_acc_id_set_AA_ids.put(AA.Deal__c,set_aa_ids);
            }
       	}  
       }
       
       String Fund_Details = '';
       
       List<String> args = new String[]{'0','number','###,###,###.00'};
       for(id deal_id : setDealIds ) {
         Fund_Details = '';
         if(map_acc_id_set_AA_ids.containsKey(deal_id))
         for(Id AA_id: map_acc_id_set_AA_ids.get(deal_id)) {
           if(!set_del_AA_ids.contains(AA_id)) {
//            String fund_detail_str = (map_AA.get(AA_id).Fund__r.Name==null ? '' : map_AA.get(AA_id).Fund__r.Name)+'(C:'+(map_AA.get(AA_id).Original_Cost__c==null ? '' : String.valueOf( (map_AA.get(AA_id).Original_Cost__c).setScale(2) ))+',CV:'+(map_AA.get(AA_id).Carrying_Value__c==null ? '' : String.valueOf( (map_AA.get(AA_id).Carrying_Value__c).setScale(2) ))+')';
//            String fund_detail_str = (map_AA.get(AA_id).Fund__r.Name==null ? '' : map_AA.get(AA_id).Fund__r.Name)+'(C:'+(map_AA.get(AA_id).Cost__c==null ? '' : String.format( (map_AA.get(AA_id).Cost__c).setScale(2).format() , args ) )+',CV:'+(map_AA.get(AA_id).Carrying_Value__c==null ? '' : String.format( (map_AA.get(AA_id).Carrying_Value__c).setScale(2).format() , args ) )+')';
            String stCost = (map_AA.get(AA_id).Cost__c==null ? '' : setAfterPointSigns( String.format( (map_AA.get(AA_id).Cost__c).format() , args ) ) ); 
            String stCarrying_Value = (map_AA.get(AA_id).Carrying_Value__c==null ? '' : setAfterPointSigns( String.format( (map_AA.get(AA_id).Carrying_Value__c).format() , args ) ) ); 
            String fund_detail_str = (map_AA.get(AA_id).Fund__r.Name==null ? '' : map_AA.get(AA_id).Fund__r.Name)+'(C:'+stCost+',CV:'+stCarrying_Value+')';
            if(Fund_Details.length()>0)
                fund_detail_str = ','+ fund_detail_str;
            if(fund_detail_str.length()>1 && (Fund_Details.length()+fund_detail_str.length())<255)
                Fund_Details = Fund_Details + fund_detail_str;
           }    
         }
         if(!map_update_acc.containsKey(deal_id))
            map_update_acc.put(deal_id,new Deal__c(id = deal_id, Fund_Details__c = ''));
         map_update_acc.get(deal_id).Fund_Details__c = Fund_Details;
       }
       if(map_update_acc.size()>0)
         update map_update_acc.values();
    }

    private string setAfterPointSigns(String strIn) {
       if(strIn.indexOf('.') < 0) return strIn+'.00';
       String stBeforePoint = strIn.substring(0,strIn.indexOf('.')); 	
       String stAfterPoint = strIn.substring(strIn.indexOf('.')+1);
       if(stAfterPoint.length()==1) stAfterPoint = stAfterPoint+'0';   
       if(stAfterPoint.length()>2) stAfterPoint = stAfterPoint.substring(0,2);
       return stBeforePoint+'.'+stAfterPoint;
    }
    
//    private void updateDeal(list<Administrative_Accounting__c> listAAs)
    private void updateDeal(map<id,Administrative_Accounting__c> mapAAs_old,map<id,Administrative_Accounting__c> mapAAs)
    {
    	list<Administrative_Accounting__c> listAAs = mapAAs.values();
    	
    	set<Id> setDealIds = new set<Id>();
    	for(Administrative_Accounting__c aa : listAAs)
	    {
	    	setDealIds.add(aa.Deal__c);
	    }
       map<ID, list<Administrative_Accounting__c>> map_DealId_list_AAs = new map<ID, list<Administrative_Accounting__c>>();
	   map<ID, Administrative_Accounting__c> map_DealId_maxDateOfRecord = new map<ID, Administrative_Accounting__c>();
		   
	    if(setDealIds.Size() > 0)
	    {
	    	for(Administrative_Accounting__c item : [	
	    			SELECT 	Id, Date_of_Record__c,	Deal__r.Date_of_Record__c, 
	    					Cost__c,	Deal__r.Current_Cost__c,  
	    					Carrying_Value__c, Deal__r.Carrying_Value__c,
	    					Grills_Value__c, Deal__r.Grills_Value__c,
	    					Grills_Rank__c, Deal__r.Grills_Rank__c,
	    					Original_Cost__c, Deal__r.Original_Cost__c,
	    					WP_Ownership_Basic__c, Deal__r.WP_Ownership_Basic__c,
	    					WP_Ownership_Fully_Diluted__c, Deal__r.WP_Ownership_Fully_Diluted__c,
	    					Realizations_to_Date__c, Deal__r.Realizations_to_Date__c,
	    					Fund__c,Deal__r.Fund__c,Fund__r.Acronym__c,
	    					Exit_Year__c, Deal__r.Exit_Year__c
	    			FROM Administrative_Accounting__c
	    			WHERE Deal__c IN : setDealIds 
	    			ORDER By Deal__c,Date_of_Record__c DESC])
		    {
		    	list<Administrative_Accounting__c> listAA = new list<Administrative_Accounting__c>();
		    	if( map_DealId_list_AAs.containskey(item.Deal__c) ) listAA = map_DealId_list_AAs.get(item.Deal__c);
            	listAA.add(item);
		    	map_DealId_list_AAs.put(item.Deal__c,listAA);
		    	
		    	if(!map_DealId_maxDateOfRecord.containskey(item.Deal__c)) map_DealId_maxDateOfRecord.put(item.Deal__c, item);
                else
                {
                    if(map_DealId_maxDateOfRecord.get(item.Deal__c).Date_of_Record__c < item.Date_of_Record__c)
                    {
                        map_DealId_maxDateOfRecord.put(item.Deal__c, item);
                    }               
                    else if (map_DealId_maxDateOfRecord.get(item.Deal__c).Date_of_Record__c == item.Date_of_Record__c)
                    { 
                    	//we have multiple valuation records from different funds and need to add them together   
                    	
                    	//Cost
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).Cost__c != null && item.Cost__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Cost__c = map_DealId_maxDateOfRecord.get(item.Deal__c).Cost__c + item.Cost__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).Cost__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Cost__c = item.Cost__c;
                    	}      	
              			
              			//Carrying Valie
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).Carrying_Value__c != null && item.Carrying_Value__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Carrying_Value__c = map_DealId_maxDateOfRecord.get(item.Deal__c).Carrying_Value__c + item.Carrying_Value__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).Carrying_Value__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Carrying_Value__c = item.Carrying_Value__c;
                    	} 
                    	
                    	//Grills Value
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Value__c != null && item.Grills_Value__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Value__c = map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Value__c + item.Grills_Value__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Value__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Value__c = item.Grills_Value__c;
                    	}                    	
                                    	
                    	if(item.Grills_Rank__c != null)
                    	{
                    		if(item.Grills_Rank__c > map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Rank__c)
                    		{
                    			map_DealId_maxDateOfRecord.get(item.Deal__c).Grills_Rank__c = item.Grills_Rank__c; 
                    		}
                    	}
                    	                    	
                    	//Original Cost 
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).Original_Cost__c != null && item.Original_Cost__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Original_Cost__c = map_DealId_maxDateOfRecord.get(item.Deal__c).Original_Cost__c + item.Original_Cost__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).Original_Cost__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Original_Cost__c = item.Original_Cost__c;
                    	} 
                    	
	                  	//Ownership basic
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Basic__c != null && item.WP_Ownership_Basic__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Basic__c = map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Basic__c + item.WP_Ownership_Basic__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Basic__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Basic__c = item.WP_Ownership_Basic__c;
                    	} 
                    	
                    	//Ownership fully diluted
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Fully_Diluted__c != null && item.WP_Ownership_Fully_Diluted__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Fully_Diluted__c = map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Fully_Diluted__c + item.WP_Ownership_Fully_Diluted__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Fully_Diluted__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).WP_Ownership_Fully_Diluted__c = item.WP_Ownership_Fully_Diluted__c;
                    	} 
                   	
                    	//Realizations to date
                    	if(map_DealId_maxDateOfRecord.get(item.Deal__c).Realizations_to_Date__c != null && item.Realizations_to_Date__c != null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Realizations_to_Date__c = map_DealId_maxDateOfRecord.get(item.Deal__c).Realizations_to_Date__c + item.Realizations_to_Date__c;
                    	}
                    	else if(map_DealId_maxDateOfRecord.get(item.Deal__c).Realizations_to_Date__c == null)
                    	{
                    		map_DealId_maxDateOfRecord.get(item.Deal__c).Realizations_to_Date__c = item.Realizations_to_Date__c;
                    	}  
                    	
                    	//Exit Year
                    	if(item.Exit_Year__c != null)
                    	{
                    		if(item.Exit_Year__c > map_DealId_maxDateOfRecord.get(item.Deal__c).Exit_Year__c)
                    		{
                    			map_DealId_maxDateOfRecord.get(item.Deal__c).Exit_Year__c = item.Exit_Year__c; 
                    		}
                    	} 
                    }
                }
		    }
		    
		    system.debug('map_CompanyId_maxDateOfRecord = '+map_DealId_maxDateOfRecord);		    
	    }
	    
	    list<Deal__c> listDeal2Update = new list<Deal__c>();
	    map<id,Deal__c> map_deal_id_deal2update = new map<id,Deal__c>(); 
	    Deal__c deal;
	    Administrative_Accounting__c aa;
       String tmpStr = '';
	    
        for(Id dealId : setDealIds)
        {
        	deal = new Deal__c(Id = dealId);
        	if(map_DealId_maxDateOfRecord.containskey(dealId))
        	{
                aa = map_DealId_maxDateOfRecord.get(dealId);
                system.debug('aa>>>>>>>>>>>>>> '+map_DealId_maxDateOfRecord.get(dealId));
                if(
                	aa.Deal__r.Date_of_Record__c != aa.Date_of_Record__c ||
				    
				    aa.Deal__r.Current_Cost__c != aa.Cost__c ||
				    aa.Deal__r.Carrying_Value__c != aa.Carrying_Value__c ||
				    aa.Deal__r.Grills_Value__c != aa.Grills_Value__c ||
				    aa.Deal__r.Grills_Rank__c != aa.Grills_Rank__c ||
				    aa.Deal__r.Exit_Year__c != aa.Exit_Year__c
//				    || aa.Deal__r.Fund__c != aa.Fund__c 
				    )
                {
				    deal.Date_of_Record__c = aa.Date_of_Record__c;
				    deal.Current_Cost__c = aa.Cost__c;
				    deal.Carrying_Value__c = aa.Carrying_Value__c;
				    deal.Grills_Value__c = aa.Grills_Value__c;
				    deal.Grills_Rank__c = aa.Grills_Rank__c;
				    deal.Exit_Year__c = aa.Exit_Year__c;
//				    deal.Fund__c = aa.Fund__c;
				}
                
                // https://silverline.jira.com/browse/WP-48
                deal.Original_Cost__c = aa.Original_Cost__c;
                deal.WP_Ownership_Basic__c = aa.WP_Ownership_Basic__c;
                deal.WP_Ownership_Fully_Diluted__c = aa.WP_Ownership_Fully_Diluted__c;
                deal.Realizations_to_Date__c = aa.Realizations_to_Date__c;
                
                
                listDeal2Update.add(deal);
                map_deal_id_deal2update.put(dealId,deal);
            }
            else
            {
            	deal.Date_of_Record__c = null;
				deal.Current_Cost__c = null;
				deal.Original_Cost__c = null;
				deal.Carrying_Value__c = null;
				deal.Grills_Value__c = null;
				deal.Grills_Rank__c = null;
				deal.WP_Ownership_Basic__c = null;
				deal.WP_Ownership_Fully_Diluted__c = null;
				deal.Realizations_to_Date__c = null;
				deal.Exit_Year__c = null;

//				deal.Fund__c = null;

                listDeal2Update.add(deal);
                map_deal_id_deal2update.put(dealId,deal);
            }
        }

        // generating Deal.Fund string
        set<Id> set_deal_id = new set<Id>();
        // update
/*        if(mapAAs.size() > 0 && mapAAs_old.size() > 0) {
            for(Administrative_Accounting__c  aac : mapAAs.values()) {
               if((aac.Fund__c != null && mapAAs_old.get(aac.id).Fund__c != null
                   && aac.Fund__c != mapAAs_old.get(aac.id).Fund__c)
               || (aac.Fund__c == null && mapAAs_old.get(aac.id).Fund__c != null) 
               || (aac.Fund__c != null && mapAAs_old.get(aac.id).Fund__c == null) 
                 ) set_deal_id.add(aac.Deal__c);
            }
        }
    
        // insert
        if(mapAAs_old.size() == 0) {
            for(Administrative_Accounting__c  aac : mapAAs.values())
               set_deal_id.add(aac.Deal__c); 
        }
        // delete
        if(mapAAs.size() == 0) {
            for(Administrative_Accounting__c  aac : mapAAs_old.values())
               set_deal_id.add(aac.Deal__c); 
        } */
        
        //Always update the deal on delete, update and insert
        for(Administrative_Accounting__c  aac : mapAAs.values())
               set_deal_id.add(aac.Deal__c); 
        

        map_DealId_list_AAs = new map<ID, list<Administrative_Accounting__c>>();
        if(set_deal_id.Size() > 0)
        {
         for(Administrative_Accounting__c item : [ 
               SELECT   Id, Date_of_Record__c,  Deal__r.Date_of_Record__c, 
                     Cost__c, Deal__r.Current_Cost__c,  
                     Carrying_Value__c, Deal__r.Carrying_Value__c,
                     Grills_Value__c, Deal__r.Grills_Value__c,
                     Grills_Rank__c, Deal__r.Grills_Rank__c,
                     Original_Cost__c, Deal__r.Original_Cost__c,
                     WP_Ownership_Basic__c, Deal__r.WP_Ownership_Basic__c,
                     WP_Ownership_Fully_Diluted__c, Deal__r.WP_Ownership_Fully_Diluted__c,
                     Realizations_to_Date__c, Deal__r.Realizations_to_Date__c,
                     Fund__c,Deal__r.Fund__c,Fund__r.Acronym__c,
                     Exit_Year__c, Deal__r.Exit_Year__c
               FROM Administrative_Accounting__c
               WHERE Deal__c IN : set_deal_id])
          {
            list<Administrative_Accounting__c> listAA = new list<Administrative_Accounting__c>();
            if( map_DealId_list_AAs.containskey(item.Deal__c) ) listAA = map_DealId_list_AAs.get(item.Deal__c);
            listAA.add(item);
            map_DealId_list_AAs.put(item.Deal__c,listAA);
          }
        }
     
        for(Id dealId : set_deal_id) {
        	      if( map_deal_id_deal2update.containskey(dealId) ) 
        	        deal = map_deal_id_deal2update.get(dealId);
        	      else  
        	        deal = new Deal__c(Id = dealId);
        	      
               list<Administrative_Accounting__c> listAA = new list<Administrative_Accounting__c>();
               set<id> set_fund_ids = new set<id>();  
               if( map_DealId_list_AAs.containskey(dealId) ) listAA = map_DealId_list_AAs.get(dealId);
            
               tmpStr = '';
               if(map_DealId_list_AAs.get(dealId) != null && map_DealId_list_AAs.get(dealId).size() > 0)
               {
                  for(Administrative_Accounting__c AAFundN : map_DealId_list_AAs.get(dealId)) {
                  	//Only update the funds for the most current records dates
                  	if(map_DealId_maxDateOfRecord.get(dealId).Date_of_Record__c == AAFundN.Date_of_Record__c) {                  	
	                     if(AAFundN.Fund__r.Acronym__c != null && AAFundN.Fund__c != null && !set_fund_ids.contains(AAFundN.Fund__c)) 
	                        tmpStr += ','+AAFundN.Fund__r.Acronym__c;
	                     if(AAFundN.Fund__c != null) 
	                        set_fund_ids.add(AAFundN.Fund__c); 
                  	}  
                  }      
                  if(tmpStr.length() > 0) tmpStr = tmpStr.substring(1, tmpStr.length());
                  if(tmpStr.length() > 254) tmpStr = tmpStr.substring(0, 254);
               }
               deal.Fund__c = tmpStr;
               map_deal_id_deal2update.put(dealId,deal);
        }
      
        
        system.debug('listCompany2Update = '+listDeal2Update);
//        if(listDeal2Update.size() > 0 ) update listDeal2Update;
        if(map_deal_id_deal2update.size() > 0 ) update map_deal_id_deal2update.values();
    	
    }
    
    private void updateCompany(list<Administrative_Accounting__c> listAAs)
    {
    	/*
    	set<Id> setCompanyIds = new set<Id>();
    	for(Administrative_Accounting__c aa : listAAs)
	    {
	    	setCompanyIds.add(aa.Portfolio_Company__c);
	    }
	    map<ID, Administrative_Accounting__c> map_CompanyId_maxDateOfRecord = new map<ID, Administrative_Accounting__c>();
	    if(setCompanyIds.Size() > 0)
	    {
	    	for(Administrative_Accounting__c item : [	
	    			SELECT 	Id,Date_of_Record__c,	Portfolio_Company__r.Date_of_Record__c, 
	    					Cost__c,	Portfolio_Company__r.Cost__c,  
	    					Carrying_Value__c, Portfolio_Company__r.Carrying_Value__c,
	    					Grills_Value__c, Portfolio_Company__r.Grills_Value__c,
	    					Grills_Rank__c, Portfolio_Company__r.Grills_Rank__c,
	    					Original_Cost__c, Portfolio_Company__r.Original_Cost__c,
	    					WP_Ownership_Basic__c, Portfolio_Company__r.WP_Ownership_Basic__c,
	    					WP_Ownership_Fully_Diluted__c, Portfolio_Company__r.WP_Ownership_Fully_Diluted__c,
	    					Realizations_to_Date__c, Portfolio_Company__r.Realizations_to_Date__c,
	    					Fund__c,Portfolio_Company__r.Fund__c
	    			FROM Administrative_Accounting__c
	    			WHERE Portfolio_Company__c IN : setCompanyIds 
	    			ORDER By Portfolio_Company__c,Date_of_Record__c  DESC])
		    {
		    	if(!map_CompanyId_maxDateOfRecord.containskey(item.Portfolio_Company__c)) map_CompanyId_maxDateOfRecord.put(item.Portfolio_Company__c, item);
                else
                {
                    if(map_CompanyId_maxDateOfRecord.get(item.Portfolio_Company__c).Date_of_Record__c <= item.Date_of_Record__c)
                        map_CompanyId_maxDateOfRecord.put(item.Portfolio_Company__c, item);
                }
		    }
		    system.debug('map_CompanyId_maxDateOfRecord = '+map_CompanyId_maxDateOfRecord);
	    }
	    
	    list<Account> listCompany2Update = new list<Account>();
	    Account acc;
	    Administrative_Accounting__c aa;
        for(Id aId : setCompanyIds)
        {
        	aa = map_CompanyId_maxDateOfRecord.get(aId);
        	acc = new Account(Id = aId);
        	if(aa != null)
        	{
                
                if( aa.Portfolio_Company__r.Date_of_Record__c != aa.Date_of_Record__c ||
				    aa.Portfolio_Company__r.Cost__c != aa.Cost__c ||
				    aa.Portfolio_Company__r.Carrying_Value__c != aa.Carrying_Value__c ||
				    aa.Portfolio_Company__r.Grills_Value__c != aa.Grills_Value__c ||
				    aa.Portfolio_Company__r.Grills_Rank__c != aa.Grills_Rank__c ||
				    aa.Portfolio_Company__r.Fund__c != aa.Fund__c 
				    )
                {
				    acc.Date_of_Record__c = aa.Date_of_Record__c;
				    acc.Cost__c = aa.Cost__c;
				    acc.Carrying_Value__c = aa.Carrying_Value__c;
				    acc.Grills_Value__c = aa.Grills_Value__c;
				    acc.Grills_Rank__c = aa.Grills_Rank__c;
				    acc.Fund__c = aa.Fund__c;
                }
                
                // https://silverline.jira.com/browse/WP-48
                acc.Original_Cost__c = aa.Original_Cost__c;
                acc.WP_Ownership_Basic__c = aa.WP_Ownership_Basic__c;
                acc.WP_Ownership_Fully_Diluted__c = aa.WP_Ownership_Fully_Diluted__c;
                acc.Realizations_to_Date__c = aa.Realizations_to_Date__c;
                
                
                listCompany2Update.add(acc);
            }
            else
            {
            	acc.Date_of_Record__c = null;
				acc.Cost__c = null;
				acc.Carrying_Value__c = null;
				acc.Grills_Value__c = null;
				acc.Grills_Rank__c = null;
				acc.Fund__c = null;

                listCompany2Update.add(acc);
            }
        }
        system.debug('listCompany2Update = '+listCompany2Update);
        if(listCompany2Update.size() > 0 ) update listCompany2Update;
        */
    }
    

}