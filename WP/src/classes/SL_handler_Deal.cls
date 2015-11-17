/** 
 * \author Vika Osmak 
 * \date 10/09/2012
 * \see https://silverline.jira.com/browse/WP-5
 * \brief  Update Target Sector(s) Trigger
 * \see https://silverline.jira.com/browse/WP-3
 * \test 
 */
public without sharing class SL_handler_Deal 
{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    Boolean isTriggerActive = true;
    Boolean isExitAndClosedTriggerActive = true;
    /*
    public static Id recTypeIdForPortfolioComp = null; 
    private static Id recTypeIdForOperatingComp;
    private static Id recTypeIdForPortfolioCompany_Deal;
    private static String closedDealRecType = 'Portfolio_Company'; 
    private static map<id,String> mapRTid_SellsideDeals;
    private static map<id,String> buySideDealRT;
    private static map<id,Account> Companies;
    private static map<String,Id> CompanyRecTypes;
    private static map<String,Id> DealRecTypes;
    private static list<Account> AllAccs2Update;
    private static list<Fund_Ownership__c> listFundOwnerships2Update = new list<Fund_Ownership__c>(); 
    */ 
    
    public  Id recTypeIdForPortfolioComp; 
    private Id recTypeIdForOperatingComp;
    private Id recTypeIdForPortfolioCompany_Deal;
    private String closedDealRecType = 'Portfolio_Company'; 
    private map<id,String> mapRTid_SellsideDeals;
    private map<id,String> buySideDealRT;
    private map<id,Account> Companies;
    private map<String,Id> CompanyRecTypes;
    private map<String,Id> DealRecTypes;
    private list<Account> AllAccs2Update;
    public list<Fund_Ownership__c> listFundOwnerships2Update = new list<Fund_Ownership__c>();
    
    public SL_handler_Deal(boolean isExecuting, integer size)
    {
        isTriggerActive = true;
        m_isExecuting = isExecuting;
        BatchSize = size;
        // Task: WP-81
        for(Disable_EMG__c cs_trigger : Disable_EMG__c.getall().values())
        { 
          if(cs_trigger.Name == 'Key Dates') 
          { 
            if(cs_trigger.Disabled__c) 
            { 
              isTriggerActive = false; 
            }             
          }
          
          if (cs_trigger.Name == 'Closed And Exit Dates')
          {
            if(cs_trigger.Disabled__c) 
            { 
              isExitAndClosedTriggerActive = false;
            }            
          }
        }
    } 
    public void OnBeforeInsert(list<Deal__c> newDeals)
    {   
        AllAccs2Update = new list<Account>();
        
        
        //          if(currentDeal.Sector__c==null && currentDeal.Sector__c=='' && currentAccount.Sector__c!=null) currentDeal.Sector__c = currentAccount.Sector__c;
        //    if(currentDeal.Geographies__c==null && currentDeal.Geographies__c=='' && currentAccount.Geographies__c!=null) currentDeal.Geographies__c = currentAccount.Geographies__c;
        
        
        //*************************   WP-54 ***************************
        
        Set<ID> setAccIDs = new Set<ID>();
        for(Deal__c item:newDeals)
        {
            if(item.Company__c!=null){ setAccIDs.add(item.Company__c);}
        }
        if(setAccIDs.size()>0)
        {
            Map<ID,Account> mapAccInfo = new Map<ID, Account>([SELECT Id, Sector__c, Geographies__c FROM Account where ID in :setAccIDs limit 1000]);
            
            for(Deal__c item:newDeals)
            {
                if(item.Company__c!=null && mapAccInfo.containsKey(item.Company__c))
                {
                    if((item.Sector__c==null || item.Sector__c=='') && mapAccInfo.get(item.Company__c).Sector__c!=null) item.Sector__c = mapAccInfo.get(item.Company__c).Sector__c;
                    if((item.Geographies__c==null || item.Geographies__c=='') && mapAccInfo.get(item.Company__c).Geographies__c!=null) item.Geographies__c = mapAccInfo.get(item.Company__c).Geographies__c;
                }
            }
        }
        //*************************   WP-54 ***************************


        SL_Util_Generator.fillExpenseCodeInItems(newDeals, null);
        // Task: WP-3
        // Trigger on Deal to set fields (EMG Paragraph has changed)
//        setEMGfields(newDeals);
        // Task: WP-5
        //setTargetSectors(newDeals);
        // WP-40
        setWPGroup(newDeals);
        
        setSectorSingle(newDeals);
       
        // Task: WP-15 (paragraph 'A')
        setBuySideDeals(null, newDeals);
        
        // Task: WP-16
        setSellsideDeals(null, newDeals);          
        
        if(AllAccs2Update.size()>0){
            update AllAccs2Update;
        }
        
        UpdateFundOwns();

        // Task: WP-81        
        if(isTriggerActive) 
        {
         // Task: WP-75        
         ID uContactId = null;         
         RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
         system.debug('#### ContRecTypeId : '+ContRecTypeId);
         List<Contact> list_uCont = [Select id, RecordTypeId, User_ID__c From Contact where RecordTypeId = :ContRecTypeId.Id AND User_ID__c = :UserInfo.getUserId() limit 1];
         Contact uCont = (!list_uCont.isEmpty()?list_uCont[0]:null);
         system.debug('#### uCont : '+uCont);
         if(uCont != null && uCont.RecordTypeId != null && ContRecTypeId != null && uCont.RecordTypeId == ContRecTypeId.Id)
            uContactId = uCont.Id;
         for(Deal__c item:newDeals)
         {
           // Task: WP-80
           if(item.Key_Dates_Next_Steps__c != null)
           {
               item.Key_Dates_Last_Update_Date__c = Datetime.now();
               if(uContactId != null)
                  item.Key_Dates_Last_Update_By__c = uContactId; 
           }   else {
             item.Key_Dates_Last_Update_Date__c = null;
             item.Key_Dates_Last_Update_By__c = null;
           }
         }
        }
        //Just before Inserting a new Deal - check if it is an Energy Opportunity and notify
        setProcessQueue(newDeals);

    }
    
    public void OnBeforeUpdate(map<Id,Deal__c> oldDeals, map<Id,Deal__c> newDeals)
    {   
        SL_Util_Generator.fillExpenseCodeInItems(newDeals.values(), oldDeals);
        // Task: WP-3
        // Trigger on Deal to set fields when EMG Paragraph has changed
//      checkForEMGParagraphIsChanged(oldDeals, newDeals);
        // Task: WP-5
        //list<Deal__c> updDealsTargetSectors = new list<Deal__c>();
        list<Deal__c> updDealsWPGroups = new list<Deal__c>();
        for(Id dealId : newDeals.keySet())
        {
            //if(newDeals.get(dealId).Target_Sectors__c != oldDeals.get(dealId).Target_Sectors__c ) updDealsTargetSectors.add(newDeals.get(dealId));
            if(newDeals.get(dealId).WP_Groups_picklist__c != oldDeals.get(dealId).WP_Groups_picklist__c )   updDealsWPGroups.add(newDeals.get(dealId));
        }
        //if(updDealsTargetSectors.size() > 0)  setTargetSectors(updDealsTargetSectors);
        // WP-40
        if(updDealsWPGroups.size() > 0)  setWPGroup(updDealsWPGroups); 
        
        setSectorSingle(newDeals.values());      
        
        AllAccs2Update = new list<Account>();
        
        // Task: WP-15 (paragraph 'B')
        setBuySideDeals(oldDeals.values(), newDeals.values());
         
        // Task: WP-16
        setSellsideDeals(oldDeals.values(), newDeals.values());
        
        if(AllAccs2Update.size()>0){
            update AllAccs2Update;
        }
        
        //UpdateFundOwns();
        
        // Task: WP-81        
        if(isTriggerActive) 
        {
         // Task: WP-75        
      ID uContactId = null;         
         RecordType ContRecTypeId = [Select Id,DeveloperName,sObjectType From RecordType where DeveloperName = 'Employee' and sObjectType = 'Contact' limit 1];
         List<Contact> list_uCont = [Select id, RecordTypeId, User_ID__c From Contact where RecordTypeId = :ContRecTypeId.Id AND User_ID__c = :UserInfo.getUserId() limit 1];
         Contact uCont = (!list_uCont.isEmpty()?list_uCont[0]:null);
         if(uCont != null && uCont.RecordTypeId != null && ContRecTypeId != null && uCont.RecordTypeId == ContRecTypeId.Id)
            uContactId = uCont.Id;
         for(Deal__c item : newDeals.values())
         {
            if(
                 (oldDeals.get(item.Id).Key_Dates_Next_Steps__c == null && item.Key_Dates_Next_Steps__c != null) 
              || (oldDeals.get(item.Id).Key_Dates_Next_Steps__c != null && item.Key_Dates_Next_Steps__c == null) 
              || (oldDeals.get(item.Id).Key_Dates_Next_Steps__c != null && item.Key_Dates_Next_Steps__c != null
              && oldDeals.get(item.Id).Key_Dates_Next_Steps__c != item.Key_Dates_Next_Steps__c
                  ) 
              )
            {
               item.Key_Dates_Last_Update_Date__c = Datetime.now();
               if(uContactId != null)
                  item.Key_Dates_Last_Update_By__c = uContactId;
            } else {
              // Task: WP-80
              item.Key_Dates_Last_Update_Date__c = oldDeals.get(item.Id).Key_Dates_Last_Update_Date__c; 
               item.Key_Dates_Last_Update_By__c = oldDeals.get(item.Id).Key_Dates_Last_Update_By__c; 
            }
         }        
        }
        
        if(isExitAndClosedTriggerActive)
        {
          for(Deal__c item : newDeals.values())
           {
             //Updates the closed and exited date based on the status
             //This should be disabled along with the key dates trigger.
             UpdateDealDates(item, oldDeals.get(item.Id));
           }  
        }
        setProcessQueue(newDeals.values());
        
    }
    public void OnAfterUpdate(map<Id,Deal__c> oldDeals, map<Id,Deal__c> newDeals)
    {
        UpdateFundOwns();
        Set<ID> setOld = new Set<ID>(); Set<ID> setNew = new Set<ID>();
        for(Deal__c item : oldDeals.values()) setOld.Add(item.Id);
        for(Deal__c item : newDeals.values()) setNew.Add(item.Id);
      
        if (System.isFuture() || System.isBatch())
        	setDealWPSeniorTeamMemberGroup(setOld,setNew);//oldDeals.values(), newDeals.values());
        else
         	setDealWPSeniorTeamMemberGroupAsync(setOld,setNew);//oldDeals.values(), newDeals.values());
        setEnergyOppData(oldDeals.values(), newDeals.values());                  
    } 
    public void OnAfterInsert(map<Id,Deal__c> newDeals)
    {
        //UpdateFundOwns();
        //setDealWPSeniorTeamMemberGroup(oldDeals.values(), newDeals.values());
        setEnergyOppData(null, newDeals.values());                  
    }
    
    
    
    
    public void OnBeforeDelete(list<Deal__c> oldDealsAr)
    {
        delete_list_Company_Team_Member(oldDealsAr);
        /*
        AllAccs2Update = new list<Account>();
        if(AllAccs2Update.size()>0){
            update AllAccs2Update;
        }
        // Task: WP-15
        setBuySideDeals(oldDealsAr, null);
        
        UpdateFundOwns();
        */
    }
    
    public void OnAfterDelete(list<Deal__c> oldDeals)
    {
        AllAccs2Update = new list<Account>();
        
        // Task: WP-16
        setSellsideDeals(oldDeals,null);
        setBuySideDeals(oldDeals, null);
        
        if(AllAccs2Update.size()>0){
            update AllAccs2Update;
        }
        
        UpdateFundOwns();
    }
    
    private void UpdateFundOwns(){
        if(listFundOwnerships2Update.size() > 0)
            update listFundOwnerships2Update;
    }

    private void getRecTypes()
    {
        if(recTypeIdForPortfolioCompany_Deal == null || recTypeIdForPortfolioComp == null || recTypeIdForOperatingComp == null)
        {
            for(RecordType r :[ SELECT Id,DeveloperName,Name,SobjectType
                                FROM RecordType 
                                WHERE SobjectType IN ('Deal__c','Account')])
                                //WHERE DeveloperName IN ('Portfolio_Company','Operating_Company') AND SobjectType IN ('Deal__c','Account')])
            {
                if(r.DeveloperName == 'Portfolio_Company' &&  r.SobjectType == 'Deal__c') 
                    recTypeIdForPortfolioCompany_Deal = r.Id;
                else if(r.DeveloperName == 'Portfolio_Company' &&  r.SobjectType == 'Account') 
                    recTypeIdForPortfolioComp = r.Id;
                else if(r.DeveloperName == 'Operating_Company' &&  r.SobjectType == 'Account') 
                    recTypeIdForOperatingComp = r.Id;
                
                if(r.SobjectType == 'Account' && r.Id != null){
                    if(CompanyRecTypes == null){
                        CompanyRecTypes = new map <String, Id>();
                    } 
                    CompanyRecTypes.put(r.DeveloperName, r.Id);
                }
                else if(r.SobjectType == 'Deal__c'  && r.Id != null){
                    if(DealRecTypes == null){
                        DealRecTypes = new map <String, Id>();
                    }
                    DealRecTypes.put(r.DeveloperName, r.Id);
                }
            }
            
        }
    }
    
    private void getBuySellSideDeals(){
        getRecTypes();
        if(mapRTid_SellsideDeals == null)
        { 
            mapRTid_SellsideDeals           = new map<id,String>();
            buySideDealRT                   = new map<id,String>();
            
            set<String> listSellsideDeals   = new set<String>();
            set<String> listBuysideDeals    = new set<String>();
            
            list<SL_Buyside_Deals__c> BuysideDeals      = SL_Buyside_Deals__c.getall().values();
            list<SL_Sellside_Deals__c> SellsideDeals    = SL_Sellside_Deals__c.getall().values();
            
            if(SellsideDeals.size() > 0)
            {
                for(SL_Sellside_Deals__c item : SellsideDeals) 
                    listSellsideDeals.add(item.Name);
            }
            if(BuysideDeals.size() > 0)
            {
                for(SL_Buyside_Deals__c item : BuysideDeals) 
                    listBuysideDeals.add(item.Name);
            }
            
            for(RecordType r :[ SELECT Id,DeveloperName,Name FROM RecordType WHERE (DeveloperName IN :listBuysideDeals OR DeveloperName IN :listSellsideDeals)
                                AND SobjectType = 'Deal__c'])
            {
                if(listSellsideDeals.contains(r.DeveloperName))
                    mapRTid_SellsideDeals.put(r.Id, r.DeveloperName);
                if(listBuysideDeals.contains(r.DeveloperName))
                    buySideDealRT.put(r.Id, r.DeveloperName);
            }
        }
    }
    
    private void getSellsideDeals()
    {
        getBuySellSideDeals();
    }
    
    private void getBuysideDeals()
    {
        
        getBuySellSideDeals();
    }
    public void UpdateDealRecType(Deal__c theDeal, String new_name){
        
        if(new_name != Null){
            if(new_name != closedDealRecType){
                if(buySideDealRT.containsKey(theDeal.RecordTypeId) && DealRecTypes.containsKey(new_name)){
                    theDeal.RecordTypeId = DealRecTypes.get(new_name);
                }
            }
            else{
                theDeal.RecordTypeId = recTypeIdForPortfolioCompany_Deal;
            }
        }
    }
    
    private void GetAllCompanies(set<ID> inAccountIDs){
        
        Companies = new map <id, Account>();
        if(inAccountIDs!=null && inAccountIDs.size()>0)
        {
            for(Account Company :[Select a.Name, a.Id, a.RecordTypeId From Account a WHERE a.ID in :inAccountIDs AND a.RecordTypeId IN :CompanyRecTypes.values() limit 1000]){
                if(Company != Null && Company.Id != Null)
                    Companies.put(Company.Id,Company);
            }
        }
    }
    
    private Id UpdateCompanyRecType(Id companyId, String new_name){
        Account company = new Account();
        if(companyId != Null && new_name != Null){
            /*
            if(recTypeIdForPortfolioComp == Null){
                
                List<RecordType> recType = [Select r.Id From RecordType r WHERE r.DeveloperName =:new_name  AND r.SobjectType = 'Account' LIMIT 1];
                if(!recType.isEmpty()){
                    if(recType[0].Id != Null){
                        recTypeIdForPortfolioComp = recType[0].Id;
                    }
                }
            }
            */
            if(Companies == Null || Companies.isEmpty())
            {
                GetAllCompanies(new Set<ID>{companyId});
            }
            if(Companies.containsKey(companyId))
            {
                company = Companies.get(companyId);
                company.RecordTypeId = CompanyRecTypes.get(new_name);
            }
            else{
                company.RecordTypeId = null;
            }
        }
        return company.RecordTypeId;
    }
    
    //Sellside Deals (WP-15)
    private void setBuysideDeals(list<Deal__c> oldDeals, list<Deal__c> newDeals)
    {
        map<ID,Deal__c> mapOldDeals = new  map<ID,Deal__c>();
        if(oldDeals!=null)
        {
            for(Deal__c item:oldDeals) mapOldDeals.put(item.ID,item);
        }
        
        getBuysideDeals();
        getRecTypes();
        if(buySideDealRT != null)
        {
            map<Id,Id> mapAccId_RTypeId = new map<Id,Id>();
            map<Id,Id> mapDeallId_AccId = new map<Id,Id>();
            map<Id,Id> Account2Update = new map<Id,Id>();
            
            if(listFundOwnerships2Update == null)
                listFundOwnerships2Update = new list<Fund_Ownership__c>();
            
            
            if(newDeals != null)
            {
                Set<ID> setDealAccIDs = new Set<ID>();
                for(Deal__c deal : newDeals){ setDealAccIDs.add(deal.Company__c);}
                GetAllCompanies(setDealAccIDs);
            }
            
            if(newDeals != null && oldDeals == null) // insert
            {
                for(Deal__c deal : newDeals)
                {
        if(deal.Stage__c == 'Committed-Deal Closed' && buySideDealRT.containsKey(deal.RecordTypeId) )
                    {
                        mapDeallId_AccId.put(deal.Id,deal.Company__c);
                        //WP-55
                        if(oldDeals==null || mapOldDeals.get(deal.ID).Stage__c!=deal.Stage__c)
                        {
                            mapAccId_RTypeId.put(deal.Company__c,recTypeIdForPortfolioComp);
                        }
                        
                        Account2Update.put(deal.Id,deal.Company__c);
                        if(buySideDealRT.containsKey(deal.RecordTypeId)){
                            //update company Record Type
                            //WP-55
                            if(oldDeals==null || mapOldDeals.get(deal.ID).Stage__c!=deal.Stage__c)
                            {
                                Account2Update.put(deal.Company__c,UpdateCompanyRecType(deal.Company__c, 'Portfolio_Company'));
                            }
                        }
                        deal.RecordTypeId = recTypeIdForPortfolioCompany_Deal;
                    }
                }
            }
            if(newDeals != null && oldDeals != null) // update
            {
                for(Integer i = 0; i < newDeals.size(); i++)
                {
                    if(
                        buySideDealRT.containsKey(newDeals.get(i).RecordTypeId) ||
                        buySideDealRT.containsKey(newDeals.get(i).Prior_Record_Type__c)
                    )
                    {
                        Deal__c new_deal = newDeals.get(i); 
                        if(new_deal.Stage__c != 'Committed-Deal Closed' && new_deal.Stage__c != 'Deal Exited Portfolio'  /* && new_deal.RecordTypeId != recTypeIdForPortfolioCompany_Deal*/)
                        {   
                            //UpdateDealRecType(new_deal, oldDeals.get(i).Prior_Record_Type__c);
                            
                            //update Deal Record Type
                            if(new_deal.Prior_Record_Type__c != Null){
                                if(new_deal.RecordTypeId != new_deal.Prior_Record_Type__c && new_deal.RecordTypeId != recTypeIdForPortfolioCompany_Deal){
                                    new_deal.Prior_Record_Type__c = new_deal.RecordTypeId;
                                }
                                else{
                                    new_deal.RecordTypeId = new_deal.Prior_Record_Type__c;
                                }
                            }
                                
                            if(buySideDealRT.containsKey(new_deal.RecordTypeId)){
                                //update company Record Type
                                
                                // WP-55
                                //Account2Update.put(new_deal.Company__c,UpdateCompanyRecType(new_deal.Company__c, 'Operating_Company'));
                            }
                            // WP-55
                            //mapAccId_RTypeId.put(new_deal.Company__c,recTypeIdForOperatingComp);
                        }
                        else if(new_deal.Stage__c == 'Committed-Deal Closed' || new_deal.Stage__c == 'Deal Exited Portfolio')
                        {   
                            //update company Record Type if Deal is in BuySideDeals & stage is "closed"
                            if(buySideDealRT.containsKey(new_deal.RecordTypeId))
                            {
                                //WP-55
                                if(oldDeals==null || mapOldDeals.get(new_deal.ID).Stage__c!=new_deal.Stage__c)
                                {
                                    Account2Update.put(new_deal.Company__c,UpdateCompanyRecType(new_deal.Company__c, 'Portfolio_Company'));
                                }
                            }
                            
                            //save current RecType to PriorRecordType field
                            if(new_deal.RecordTypeId != recTypeIdForPortfolioCompany_Deal)
                                new_deal.Prior_Record_Type__c = oldDeals.get(i).RecordTypeId;
                            
                            //update Deal RecType
                            UpdateDealRecType(new_deal, closedDealRecType);
                            
                            //WP-55
                            if(oldDeals==null || mapOldDeals.get(new_deal.ID).Stage__c!=new_deal.Stage__c)
                            {
                                mapAccId_RTypeId.put(new_deal.Company__c,recTypeIdForPortfolioComp);
                            }
                        }
                        mapDeallId_AccId.put(newDeals.get(i).Id,newDeals.get(i).Company__c);
                    }
                }
            }
            if(newDeals == null  && oldDeals != null) // delete
            {
                for(Deal__c deal  : oldDeals)
                {
                    if(buySideDealRT.containsKey(deal.RecordTypeId) )
                    {
                        /*
                        if(deal.Prior_Record_Type__c != null)
                            deal.RecordTypeId = deal.Prior_Record_Type__c;
                        */  
                        //Account2Update.put(deal.Company__c,UpdateCompanyRecType(deal.Company__c, 'Operating_Company'));
                        mapDeallId_AccId.put(deal.Id,deal.Company__c);
                        //WP-55
                        //mapAccId_RTypeId.put(deal.Company__c,recTypeIdForPortfolioComp);
                    }
                }
            }
            if(Account2Update.size() > 0)
            {
                list<Account> Acc2Update = new list<Account>();
                for(Account item : [SELECT Id,RecordTypeId FROM Account WHERE Id IN : Account2Update.keySet() limit 5000])
                {
                    item.RecordTypeId = Account2Update.get(item.Id);
                    AllAccs2Update.add(item);
                }
                /*if(Acc2Update.size() > 0) 
                    update Acc2Update;
                    */
            }
            
            if(mapDeallId_AccId.keySet().size() > 0)
            {
                
                system.debug('here---'+mapDeallId_AccId.keySet()); 
                
                Fund_Ownership__c newFO;
                list<Fund_Ownership__c> listFO2Update = new list<Fund_Ownership__c>();
                for(Fund_Ownership__c item : [SELECT Id,Deal__c,Portfolio_Company__c FROM Fund_Ownership__c WHERE Deal__c IN : mapDeallId_AccId.keySet() LIMIT 5000])
                {
                    newFO = new Fund_Ownership__c(Id = item.Id);
                    
                    if( mapAccId_RTypeId.get(mapDeallId_AccId.get(item.Deal__c)) == recTypeIdForPortfolioComp)
                    {
                        newFO.Portfolio_Company__c = mapDeallId_AccId.get(item.Deal__c);
                        listFundOwnerships2Update.add(newFO);
                    }
                    else if(    mapAccId_RTypeId.get(mapDeallId_AccId.get(item.Deal__c)) == recTypeIdForOperatingComp)
                    {
                        newFO.Portfolio_Company__c = null;
                        listFundOwnerships2Update.add(newFO);
                    }
                }
                /*
                if(listFO2Update.size() > 0 ) 
                    update listFO2Update;
                */
            }
        }
    }
    
    //Sellside Deals (WP-16)
    private void setSellsideDeals(list<Deal__c> oldDeals, list<Deal__c> newDeals)
    {
        map<ID,Deal__c> mapOldDeals = new  map<ID,Deal__c>();
        if(oldDeals!=null)
        {
            for(Deal__c item:oldDeals) mapOldDeals.put(item.ID,item);
        }
        
        getSellsideDeals();
        getRecTypes();
        if(mapRTid_SellsideDeals != null)
        {
            map<Id,Id> mapAccId_RTypeId = new map<Id,Id>();
            map<Id,Id> mapDeallId_AccId = new map<Id,Id>();
            
            if(listFundOwnerships2Update == null)
                listFundOwnerships2Update = new list<Fund_Ownership__c>();
                
            if(newDeals != null && oldDeals == null) // insert
            {
                for(Deal__c deal : newDeals)
                {
                    if(deal.Stage__c == 'Committed-Deal Closed' && mapRTid_SellsideDeals.containsKey(deal.RecordTypeId) )
                    {
                        //WP-55
                        if(oldDeals==null || mapOldDeals.get(deal.ID).Stage__c!=deal.Stage__c)
                        {
                            mapAccId_RTypeId.put(deal.Company__c,recTypeIdForOperatingComp);
                        }
                        mapDeallId_AccId.put(deal.Id,deal.Company__c);
                    }
                }
            }
            if(newDeals != null && oldDeals != null) // update
            {
                for(Integer i = 0; i < newDeals.size(); i++)
                {
                    if(mapRTid_SellsideDeals.containsKey(newDeals.get(i).RecordTypeId) )
                    {
                        if(newDeals.get(i).Stage__c == 'Committed-Deal Closed' && oldDeals.get(i).Stage__c != 'Deal Agreed - Deal Closed')
                        {   
                            mapAccId_RTypeId.put(newDeals.get(i).Company__c,recTypeIdForOperatingComp);
                            mapDeallId_AccId.put(newDeals.get(i).Id,newDeals.get(i).Company__c);
                        }
                        else if(newDeals.get(i).Stage__c != 'Committed-Deal Closed' && oldDeals.get(i).Stage__c == 'Deal Agreed - Deal Closed')
                        {   
                            //WP-55
                            //mapAccId_RTypeId.put(newDeals.get(i).Company__c,recTypeIdForPortfolioComp);
                            mapDeallId_AccId.put(newDeals.get(i).Id,newDeals.get(i).Company__c);
                        }
                    }
                }
            }
            if(newDeals == null  && oldDeals != null) // delete
            {
                for(Deal__c deal  : oldDeals)
                {
                    //if(deal.Stage__c != 'Deal Closed' && mapRTid_SellsideDeals.containsKey(deal.RecordTypeId) )
                    if(mapRTid_SellsideDeals.containsKey(deal.RecordTypeId) )
                    {
                        //WP-55
                        //mapAccId_RTypeId.put(deal.Company__c,recTypeIdForPortfolioComp);
                        mapDeallId_AccId.put(deal.Id,deal.Company__c);
                    }
                }
            }
            if(mapAccId_RTypeId.keySet().size() > 0)
            {
                list<Account> Account2Update = new list<Account>();
                for(Account item : [SELECT Id,RecordTypeId FROM Account WHERE Id IN : mapAccId_RTypeId.keySet()])
                {
                    item.RecordTypeId = mapAccId_RTypeId.get(item.Id);
                    AllAccs2Update.add(item);
                }
                //if(Account2Update.size() > 0) update Account2Update;
            }
            if(mapDeallId_AccId.keySet().size() > 0)
            {
                Fund_Ownership__c newFO;
                list<Fund_Ownership__c> listFO2Update = new list<Fund_Ownership__c>();
                for(Fund_Ownership__c item : [  SELECT Id,Deal__c,Portfolio_Company__c FROM Fund_Ownership__c WHERE Deal__c IN : mapDeallId_AccId.keySet() limit 5000 /* AND Portfolio_Company__c IN : mapDeallId_AccId.values() */])
                {
                    newFO = new Fund_Ownership__c(Id = item.Id);
                    if( mapAccId_RTypeId.get(mapDeallId_AccId.get(item.Deal__c)) == recTypeIdForOperatingComp)
                    {
                        
                        newFO.Portfolio_Company__c = null;
                        //listFO2Update.add(newFO);
                        listFundOwnerships2Update.add(newFO);
                    }
                    else if(    mapAccId_RTypeId.get(mapDeallId_AccId.get(item.Deal__c)) == recTypeIdForPortfolioComp)
                    {
                        newFO.Portfolio_Company__c = mapDeallId_AccId.get(item.Deal__c);
                        //listFO2Update.add(newFO);
                        listFundOwnerships2Update.add(newFO);
                    }
                }
                /*
                if(listFO2Update.size() > 0 ) 
                    update listFO2Update;
                */
            }
        }
    }
    
    //Update Target Sector(s)
    /*
    private void setTargetSectors(list<Deal__c> newDeals)
    {
        for(Deal__c deal : newDeals)
        {
            if(deal.Target_Sectors__c != null)
            {
                deal.Target_Sectors_text__c = deal.Target_Sectors__c.replace(';',',');
            }
            else deal.Target_Sectors_text__c = null;
        }
    }
    */
    //Update WP_Groups__c (WP-40)
    private void setWPGroup(list<Deal__c> newDeals)
    {
        for(Deal__c deal : newDeals)
        {
            if(deal.WP_Groups_picklist__c != null)
            {
                deal.WP_Groups__c = deal.WP_Groups_picklist__c.replace(';',',');
            }
            else deal.WP_Groups__c = null;
        }
    }
    
    
    //Update Sector into a single concatenated field.
    private void setSectorSingle(list<Deal__c> newDeals)
    {
        for(Deal__c deal : newDeals)
        {
            if(deal.Sector__c!= null)
            {
                deal.Sector_Single__c = deal.Sector__c.replace(';',',');
            }
            else deal.Sector_Single__c = null;
        }
    }
    
    
    
    // WP-43
    // Unnecessary
    // Moved to the EMG_Paragraph_History logic

    // Task: WP-3
    // Trigger on Deal to set fields when EMG Paragraph has changed 
//    private void checkForEMGParagraphIsChanged(map<Id,Deal__c> oldDeals, map<Id,Deal__c> newDeals){
//      list<Deal__c> list_deal_change_emg = new list<Deal__c>(); 
//      for(Deal__c deal : newDeals.values())
//      {
//          if( (deal.EMG_Paragraph__c != null && oldDeals.get(deal.Id).EMG_Paragraph__c != null && !deal.EMG_Paragraph__c.equals(oldDeals.get(deal.Id).EMG_Paragraph__c) )
//           || (deal.EMG_Paragraph__c == null && oldDeals.get(deal.Id).EMG_Paragraph__c != null)
//           || (deal.EMG_Paragraph__c != null && oldDeals.get(deal.Id).EMG_Paragraph__c == null)
//            )     
//             list_deal_change_emg.add(deal);
//      }
//      if(list_deal_change_emg.size()>0) setEMGfields(list_deal_change_emg);
//    }
//    
//    // Task: WP-3
//    // Trigger logic in Deal on Insert/Update to check if EMG Paragraph has changed to set the "EMG Last Updated By" to currently logged in User Id, and "EMG Last Updated Date" to TODAY(). 
//    private void setEMGfields(list<Deal__c> list_Deals){
//      for(Deal__c deal : list_Deals)
//      {
//          deal.EMG_Last_Updated_Date__c = Date.today();
//          deal.EMG_Last_Updated_By__c = UserInfo.getUserId();
//      }
//    }
     
     
    // Task: WP-8
//    private void delete_list_Company_Team_Member(list<Deal_Team__c> list_Deal_Teams) {
    private void delete_list_Company_Team_Member(list<Deal__c> list_Deals) {
      set<ID> set_compteammemb_ids = new set<ID>(); 
      set<ID> set_deal_team_ids = new set<ID>(); 
      for(Deal_Team__c deal_team : [SELECT ID,Company_Team_Member__c,Deal__c FROM Deal_Team__c WHERE Deal__c IN :list_Deals limit 5000]) {
         set_deal_team_ids.add(deal_team.id);
         if(deal_team.Company_Team_Member__c != null)
          set_compteammemb_ids.add(deal_team.Company_Team_Member__c);
      }
      for(Deal_Team__c dt :[SELECT ID,Deal__c,Employee__c,Company_Team_Member__c FROM Deal_Team__c WHERE Id NOT IN :set_deal_team_ids and Company_Team_Member__c <> null limit 5000]) {
         set_compteammemb_ids.remove( dt.Company_Team_Member__c );
      }
      
      list<Company_Team_Member__c> list_Company_Team_Member = [Select c.Id, c.Status__c, c.Name, c.Deal__c, c.Deal_Name__c, c.Date__c, c.Contact__c, c.Company__c From Company_Team_Member__c c WHERE c.ID in :set_compteammemb_ids limit 5000];
      if(list_Company_Team_Member.size()>0) 
        delete list_Company_Team_Member;
    }    
     
  public void UpdateDealDates(Deal__c newDeal, Deal__c oldDeal)
    {        
        if(newDeal != Null)
        {
          if (newDeal.Stage__c == 'Committed-Deal Closed' && newDeal.Deal_Closed_Date__c == null && oldDeal.Stage__c != 'Deal Exited Portfolio')
          {
            newDeal.Deal_Closed_Date__c = Date.Today();
          }       
          else if(newDeal.Stage__c == 'Deal Exited Portfolio' && newDeal.Deal_Exited_Portfolio_Date__c == null)
          {
            newDeal.Deal_Exited_Portfolio_Date__c = Date.Today();
          }         
          else if(oldDeal.Stage__c == 'Committed-Deal Closed' && newDeal.Stage__c != 'Committed-Deal Closed' && newDeal.Stage__c != 'Deal Exited Portfolio'   )
          {
            newDeal.Deal_Closed_Date__c = null;          
          }
          else if(oldDeal.Stage__c == 'Deal Exited Portfolio' && newDeal.Stage__c != 'Deal Exited Portfolio' && newDeal.Stage__c == 'Committed-Deal Closed' )
          {
            newDeal.Deal_Exited_Portfolio_Date__c = null;          
          }
          else if(oldDeal.Stage__c == 'Deal Exited Portfolio' && newDeal.Stage__c != 'Deal Exited Portfolio' && newDeal.Stage__c != 'Committed-Deal Closed' )
          {
            newDeal.Deal_Exited_Portfolio_Date__c = null;
            newDeal.Deal_Closed_Date__c = null;   
          }          
          else
          {
            //newDeal.Deal_Closed_Date__c = null;
            //newDeal.Deal_Exited_Portfolio_Date__c = null;
          }
        }
  }
  
  @future public static void setDealWPSeniorTeamMemberGroupAsync(Set<Id> oldDealIds, Set<Id> newDealIds)//list<Deal__c> oldDeals, list<Deal__c> newDeals)  //kck
  {
  	SL_handler_Deal dh = new SL_handler_Deal(false,Trigger.size);
  	dh.setDealWPSeniorTeamMemberGroup(oldDealIds,newDealIds);

  }
  
  
  public void setDealWPSeniorTeamMemberGroup(Set<Id> oldDealIds, Set<Id> newDealIds)//list<Deal__c> oldDeals, list<Deal__c> newDeals)  //kck
    {
    	List<Deal__c> oldDeals = [select Id, Name, WP_Groups__c from Deal__c where ID in :oldDealIds limit 1000];
    	List<Deal__c> newDeals = [select Id, Name, WP_Groups__c from Deal__c where ID in :newDealIds limit 1000];
    	//System.debug('zzzzzzzzzzzzzzzzzzzz In call to setDealWPSeniorTeamMemberGroup olddeals:' + oldDeals.size() + '  newdeals:' + newDeals.size());
    	
    	//where ID in :setAccIDs 
    	
      SL_handler_Deal_Team dt_handler = new SL_handler_Deal_Team(false, Trigger.size);
      Set<Id> deal_ids = new Set<Id>(); 
      map<Id,Deal__c> oldDealsMap = new map<Id,Deal__c>(); 
                            
      if(oldDeals != null)
      { 
        for(Deal__c item : oldDeals)
        {
          oldDealsMap.put(item.Id, Item);
        }      
      }        
                
      for(Deal__c item : newDeals)
      {        
        if(oldDealsMap != null && oldDealsMap.size() > 0)
        {                 
          //Only update the team member if the wpGroups have changed
          if(item.WP_Groups__c != oldDealsMap.get(item.id).WP_Groups__c)           
          {  
            deal_ids.add(item.Id);
          }
        }
        else // we have an insert so fire it anyway
        {
          deal_ids.add(item.Id);
        }
      }
    
      dt_handler.updDealWPSeniorTeamMemberByDeal(deal_ids);
    }
  
  
  public void setEnergyOppData(list<Deal__c> oldDeals, list<Deal__c> newDeals)
    {
    	if (System.isBatch()) return;
               	//Boolean bForceRemovedManuallyAddedEnergySharingIfPresent = false;
          Boolean bFoundEnergyInWPGroupsList=false;
          Id grpid = [Select g.Name, g.Id From Group g where Name like '%Energy Group%'  limit 1][0].Id;
          for(Deal__c deal : newDeals){ 
          	if (deal!=null && deal.WP_Groups_picklist__c!=null) {  	
            	String[] tmpString = deal.WP_Groups_picklist__c.split(';');
            	if (tmpString!=null){
					For(String energy : tmpString){
						if (energy=='Energy'){
							bFoundEnergyInWPGroupsList=true;
						}
					}
            	}
          	}
               	
            Boolean bEnergyCheckBoxChecked=deal.Is_Energy_Opportunity__c == 'Yes';
           	Boolean bEnergyManualRowExists = false;
        // kck   	
        System.debug ('eeeeeeee checking for deal share -- userorgrp=' + grpid + ' parentid = '+deal.Id);
           	List<Deal__Share> lstCheck = [Select Id,UserOrGroupId, RowCause from Deal__Share where  RowCause = 'Manual' and UserOrGroupId = :grpid and ParentId = :deal.Id  limit 1]; //and RowCause = 'Manual'
			if (lstCheck != null && lstCheck.size()==1)  bEnergyManualRowExists = true;
           	System.Debug('Energy opportunity status -- manual sharing rule exists:' + bEnergyManualRowExists +     '                energy opp is checked:' +  bEnergyCheckBoxChecked);
           	Boolean bAddManualEnergySharingRule = false;
           	Boolean bDeleteManualEnergySharingRule = false;
           	if (bEnergyCheckBoxChecked && !bEnergyManualRowExists) bAddManualEnergySharingRule=true;
           	
           	if (bFoundEnergyInWPGroupsList==false && bEnergyManualRowExists  && !bEnergyCheckBoxChecked) bDeleteManualEnergySharingRule=true;
           	
           	if (!bAddManualEnergySharingRule && !bDeleteManualEnergySharingRule)  System.Debug('DOOOOOOOOOOOOOOOOo   NOOOOOOOOOOOOOTHING');
				     
           	if (bAddManualEnergySharingRule)
           	{
               	System.Debug('adding manual sharing rule for deal due to energy opportunity checked = true');
               	Deal__Share ds = new Deal__Share();
               	ds.UserOrGroupId = grpid;
               	ds.ParentId = deal.Id;
               	ds.AccessLevel = 'Edit';
               	insert ds;
           	}
           	
           	if (bDeleteManualEnergySharingRule)	
           	{
               	System.Debug('removing manual sharing rule for deal due to energy opportunity checked = false');
               	delete lstCheck;
           	}
       }
    }
    public void setProcessQueue(list<Deal__c> newDeals){
       //check if objectId already exists in Process Queue records. If yes don't create one
       system.debug('1. setProcessQueue - starts here'); 
       String objectName='Deal';
       String objectId;
       String dealName='';
       String domainName='Energy-Opportunity-Notification';
       String action='Send-Email-To';
       Boolean bFoundEnergyInWPGroupsList = false;
       
       String parameters='itappdev@warburgpincus.com';
       
       List<WP_Lookup__c> wplookup = [SELECT id, Type__c, Value__c FROM WP_Lookup__c WHERE Type__c='Energy-Opportunity-Notification-Email'];
       
       if(wplookup.size()==1){
       	parameters = wplookup[0].Value__c;
       }      
       System.debug('rrrrrrrrrrrrrrrrrrrrr here we go');
      if (objectName =='Deal' && domainName=='Energy-Opportunity-Notification'){
        if(newDeals != null) {
        // insert or update - check only for 
        system.debug('1.1 setProcessQueue - newDeal - Not null'); 
           for(Deal__c deal : newDeals){
           	 System.debug('rrrrrrrrrrrrrrrrrrrrr here we go:' + deal.Id);
           if (deal!=null && deal.WP_Groups_picklist__c!=null)
           {
           		String[] tmpString = deal.WP_Groups_picklist__c.split(';');
            	if (tmpString!=null){
					For(String energy : tmpString){
						if (energy=='Energy'){
							bFoundEnergyInWPGroupsList=true;
						}
					}
            	}
           }
           Boolean bEnergyCheckBoxChecked=deal.Is_Energy_Opportunity__c == 'Yes';
           	//Defect 8990:Also make sure the Energy Group is also included in this Evergy Opportunity Deal
           	if (!bFoundEnergyInWPGroupsList && bEnergyCheckBoxChecked) 
           		{
           			deal.WP_Groups_picklist__c +=';Energy';
           			if (deal.WP_Groups__c!=null) {
           				//string sG = deal.WP_Groups__c;
           				System.debug ('rrrrrrrrrrrrrrrrrrrrrr wp groups before is '+deal.WP_Groups__c);
           				if (deal.WP_Groups__c.indexOf('Energy')==-1)
           				{
           					if (deal.WP_Groups__c.length()>0) deal.WP_Groups__c = ',' + deal.WP_Groups__c;
           					deal.WP_Groups__c = 'Energy'+deal.WP_Groups__c;
           				}
           				System.debug ('rrrrrrrrrrrrrrrrrrrrrr wp groups after is ' + deal.WP_Groups__c);
           				
           			}
           			
           		}
           	
          	if(bEnergyCheckBoxChecked )
          	{
            	system.debug('1.2 setProcessQueue - Is Energy Opp - Yes !'); 
            	objectId = deal.Id;
            	dealName = deal.Name;
            	
          	
            	//Defect 8990 ends
            	List<Process_Queue__c> process_queue_list = [SELECT id, Object_Id__c, Domain__c, Action__c, Parameters__c
                FROM Process_Queue__c
                WHERE Object_Id__c =:objectId AND Domain__c =:domainName AND Action__c =:action ];  /*  AND Parameters__c =:parameters*/
                System.debug('objid:' + objectId + '   domain:' + domainName + '  parameters:' + parameters + '      action:' + action);
                if (process_queue_list.size()==0 && objectId!=null && parameters!=null)
                {
                	system.debug('rrrrrrrrrrrr ---- > sending the email:' + parameters);
                //Since no matching records were found, create the process queue object and add other parameters;
                  if ( action=='Send-Email-To' )
                  {            
                	Process_Queue__c process_queue = new Process_Queue__c();
                    process_queue.Object_Id__c = objectId;
                    process_queue.Domain__c = domainName;
                    process_queue.Action__c = action;
                    process_queue.Parameters__c = parameters;
                    system.debug('1.4. before insert process_queue - starts here'); 
                	insert process_queue ;
                	if (action == 'Send-Email-To' && parameters!=null){
                  		sendEnergyOppEmailTo(deal,parameters);
                	}                
                	system.debug('1.5. after insert process_queue - ends here id=' + objectId); 
                  }
                  
               }//list.size
               else system.debug ('1.5.2 process list size is 0');
             }//Is_Energy yes ends
           }//for
        }//deals null ends         
      }//Energy-Opportunity-Notification ends
      system.debug('2. setProcessQueue - ends here'); 
    }
    public void sendEnergyOppEmailTo(Deal__c thisdeal, String emailAddress){      
          String fullDealURL = 'https://warburgpincus.my.salesforce.com/';
            List<WP_Lookup__c> wplookup = [SELECT id, Type__c, Value__c FROM WP_Lookup__c WHERE Type__c='Energy-Opportunity-DealURL'];
       	    if(wplookup.size()==1){
       			fullDealURL = wplookup[0].Value__c;
       		}
          String dealCreatedBy = UserInfo.getName() ;
          String dealCreatedOn = System.today().format();
          //String dealCreatedOn = thisdeal.CreatedDate.format() + '.<br><br>';
          String objectId = thisdeal.Id;
          String dealName = thisdeal.Name;
          String commaStr='';
          Integer commaInx=1;
          String senderName ='';
          //Now also collect all Team Members
          String dealTeamMembers='';
          wplookup = [SELECT id, Type__c, Value__c FROM WP_Lookup__c WHERE Type__c='Energy-Opportunity-Sender-Name'];
       	    if(wplookup.size()==1){
       			senderName = wplookup[0].Value__c;
       		}else{
       			senderName = 'Warburg Pincus Salesforce Notifications<noreply@warburgpincus.com>';
       		}
       
           List<Deal_Team__c> deal_team_list = [SELECT Id, Deal__c, Employee__c,
             Employee__r.Employee_Level_Precedence_Sorter__c,
             Employee__r.Employee_Level__r.Rank__c, 
             Role__c, Employee__r.Full_Name__c, Employee__r.FirstName, Employee__r.LastName, Employee__r.Name
                FROM Deal_Team__c
                WHERE Deal__c =: objectId
                ORDER BY Employee__r.Employee_Level__r.Rank__c DESC NULLS LAST, Role__c ASC NULLS LAST, Employee__r.Employee_Level_Precedence_Sorter__c DESC NULLS LAST    
                ];
                if(deal_team_list.size()>0){
                  Integer totList = deal_team_list.size();
                 for(Deal_Team__c team_item:deal_team_list) {
                   if (commaInx == totList){
                     commaStr='';
                   }else{
                     commaStr=', ';
                   }
                   dealTeamMembers = dealTeamMembers + team_item.Employee__r.FirstName + ' ' + team_item.Employee__r.LastName + commaStr; 
                   commaInx ++;   
                 }                    
                }else{
                  dealTeamMembers = '[None].<br><br>';//UserInfo.getName();
                }      
          dealTeamMembers = 'The deal team members are: ' + dealTeamMembers;
  
          system.debug('3. sendEmailTo - starts here' + emailAddress + ' dealName='+ dealName ); 
          String[] userEmail;
          String subject ='Potential Energy Opportunity Salesforce Notification';
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
          userEmail = new String[] {emailAddress};
          mail.setToAddresses(userEmail);   
          mail.setSenderDisplayName(senderName);
          mail.setSubject(subject);
          mail.setUseSignature(false);    
          String formattedHtml = 'The deal <b><a href=\"' + fullDealURL + objectId + '\">' + dealName + '</a> ' +  '</b> was identified as a Potential Energy Opportunity by '  + dealCreatedBy + ' on ' + dealCreatedOn  + '.<br><br>';
          formattedHtml = formattedHtml + dealTeamMembers;
          //'Deal id =' + did + ' sent email @ ' + System.now() ;
          mail.setHtmlBody(formattedHtml);
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
          system.debug('4. sendEmailTo - ends here' + emailAddress + ' dealName='+ dealName ); 
    }
       
}