public with sharing class SL_DealTriggerHandlerOld {
    Id portFoliRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
    Id activeDealRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Active Process').RecordTypeId;

    // Constrcutor
    public SL_DealTriggerHandlerOld() {
        // Please put the methods you want to do onLoad of this class...
    }
    
    /*
        * MethodName : isAfterUpdate
        * Param      : Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap
        * Description: Calling isDeadDeal,addWGMembersToPortfolioCompany,rollupDealsToCompany methods for various prospective
    */ 
    public void isAfterUpdate(Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap)
    {
        /*addWGMembersToPortfolioCompany(oldMap,newMap);
        isClosedDeal(newMap,oldMap);
        isDeadDeal(newMap,oldMap);
        rollupDealsToCompany(newMap,oldMap);*/
    }
    
    /*
        * MethodName : onAfterInsert
        * Param      : Map<Id,Deal__c> newMap
        * Description: Calling rollupDealsToCompany method to roll up
    */ 
    public void onAfterInsert(Map<Id,Deal__c> newMap)
    {
       // rollupDealsToCompany(newMap,null);
    }
   
    /*
        * MethodName : onAfterDelete
        * Param      : Map<Id,Deal__c> oldMap
        * Description: Calling rollupDealsToCompany method to roll up
    */  
    public void onAfterDelete(Map<Id,Deal__c> oldMap)
    {
       // rollupDealsToCompany(oldMap, null);
    }
    
    /*
        * MethodName : rollupDealsToCompany
        * Param      : Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap
        * Description: Calling SL_RollupHelper class to roll up the Inv_Opp_Team__c from the Deal to parent Account
    */ 
    private void rollupDealsToCompany(Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap)
    {
        Map <Id, List <Deal__c>> mapCompanyToListOfDeals= new Map <Id, List <Deal__c>>();
        Map<Id, Deal__c> mapOfUpdateDeals = new Map<Id, Deal__c>();
        mapOfUpdateDeals = newMap;
        List <Deal__c> lstDeals = new List <Deal__c>(); 
        // Iterating on the New Map values...
        for(Deal__c objDeal : mapOfUpdateDeals.values())
        {
            if(objDeal.Salesforce_Company__c != NULL && (oldMap == NULL  || (oldMap != NULL && ( oldMap.get(objDeal.Id).AS_Team_Rollup__c != objDeal.AS_Team_Rollup__c || oldMap.get(objDeal.Id).Salesforce_Company__c != objDeal.Salesforce_Company__c))))
            {
                if(!mapCompanyToListOfDeals.containsKey(objDeal.Salesforce_Company__c))
                    mapCompanyToListOfDeals.put(objDeal.Salesforce_Company__c, new List<Deal__c>()); 
                
                // Adding Deal records to the Map..
                mapCompanyToListOfDeals.get(objDeal.Salesforce_Company__c).add(objDeal);
            }
        }
        // Collecting the deal records...
        for(Account objAcc : [SELECT Id FROM Account WHERE Id IN:mapCompanyToListOfDeals.keySet() AND (recordtypeId=:activeDealRecTypeId OR recordtypeId =:portFoliRecTypeId)])
        {
            lstDeals.addAll(mapCompanyToListOfDeals.get(objAcc.Id));
        }
        
        if(!lstDeals.isEmpty())
            SL_RollupHelper.rollupTextField(lstDeals, 'AS_Team_Rollup__c', 'Inv_Opp_Team__c', 'Salesforce_Company__c', 'Account', 'Deals2__r', ',',true);
    }
    
    public void isClosedDeal(Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap)
    {
        List<ID> closedDeals = new List<ID>();
        for(Deal__c objDeal:newMap.values())
        {
            if(objDeal.Deal_Status__c=='Closed'&&oldMap.get(objDeal.ID).Deal_Status__c!='Closed')
            {
                closedDeals.add(objDeal.ID);
            }
        }
        if(closedDeals.size()>0)
        {
            updateWGMemb(closedDeals);
        }
    }

    public void updateWGMemb(List<ID> dealIDs)
    {
        List<External_Working_Group_Member__c> wgMembList = [SELECT ID, End_Date__c FROM External_Working_Group_Member__c where Deal__c in: dealIDs];
        for(External_Working_Group_Member__c wg: wgMembList)
        {
            if(wg.End_Date__c==null ||wg.End_Date__c>Date.today())
            {
                wg.End_Date__c = Date.today();
            }
        }
        update wgMembList;
    }

    public void isDeadDeal(Map<Id,Deal__c> newMap, Map<Id,Deal__c> oldMap)
    {
        List<Id> salesforceCompanies = new List<Id>();
        Set<String> setOfInactiveAmsecStatuses = new Set<String>();
        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            if(objStatus.Name.startsWith('Inactive') && objStatus.Am_Sec_Status__c != NULL)
                setOfInactiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
        }
        for(Deal__c objDeal:newMap.values())
        {
            if(setOfInactiveAmsecStatuses.contains(objDeal.Deal_Status__c)&&!setofInactiveAmsecStatuses.contains(oldMap.get(objDeal.Id).Deal_Status__c))
            {

            }
            if(objDeal.Deal_Status__c=='Dead'&&oldMap.get(objDeal.ID).Deal_Status__c!='Dead')
            {
                salesforceCompanies.add(objDeal.Salesforce_Company__c);
            }
        }
        updateCompanies(salesforceCompanies);
    }
    public ID getRecordType(String objType)
    {
        List<RecordType> recType = [SELECT ID FROM RecordType where Name =:objType limit 1];
        if(recType.size()>0)
        {
            return recType[0].ID;
        }
        return null; 
    }
    public void updateCompanies(List<ID> companyIds)
    {
        ID activeDealRTID = getRecordType('Active Process');
        ID generalRTID = getRecordType('General');
        if(activeDealRTID!=null && generalRTID!=null)
        {
            List<Account> companyRecords = [SELECT ID,RecordTypeID FROM Account where Id in:companyIDs];
            for(Account acc:companyRecords)
            {
                if(acc.RecordTypeId==activeDealRTID)
                    acc.RecordTypeId=generalRTID;
            }
            update companyRecords;
        }
    }
 
    /* Creting WG Members */
    public static boolean WGMembersCreated = false;
    private static void addWGMembersToPortfolioCompany(Map<id,Deal__c> mapOldDeals,Map<Id,Deal__c> mapNewDeals)
    {             
        if (WGMembersCreated) return;  
        //change the RecordTypeId of the relevant Deal__c.Account to "Portfolio Company"
        Id portFolioCompany_RT_Id = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
        List<Account> lstAccToUpdate = new List<Account>(); 
        Set<Id> dealsToProcess = new Set<id>();

        for(Deal__c objDeal : mapNewDeals.values())
        {
            Deal__c oldDeal = mapOldDeals.get(objDeal.id);
            String strDealProcessStatus = objDeal.Deal_Process__c != NULL ? String.valueOf(objDeal.Deal_Process__c) : '';
            
            if(objDeal.Salesforce_Company__c != NULL 
                && oldDeal.Deal_Status__c != objDeal.Deal_Status__c 
                && objDeal.Deal_Status__c == 'Closed' 
                && ((strDealProcessStatus.contains('Auction') || (strDealProcessStatus.contains('Limited Auction')) || (strDealProcessStatus.contains('Exclusive')))))
            {                
                lstAccToUpdate.add(new Account(Id = objDeal.Salesforce_Company__c, RecordTypeId = portFolioCompany_RT_Id));
                dealsToProcess.add(objDeal.Id);
            }
        } 
        if(lstAccToUpdate.size()>0)
        {
         //Copy the Active WG Members of with their Account set to "Portfolio Company" Accounts.
        
            List<External_Working_Group_Member__c> lstWGMembersToBeCreated = new List<External_Working_Group_Member__c>();
            
            integer i = 0;
            //Querying all the fields of WG Member records
            List<External_Working_Group_Member__c> objWGMemberList = [SELECT Deal__r.Salesforce_Company__c, 
                                                                        Contact__c, 
                                                                        End_Date__c,
                                                                        Contribution_Value__c,
                                                                        Original_Company__c,
                                                                        Deal__c,
                                                                        Role__c,
                                                                        Initial_Participation_Date__c,
                                                                        Contribution_Value_Comments__c,
                                                                        Notes__c,
                                                                        AS_Team_Leader__c,
                                                                        Primary_Idea_Source__c,
                                                                        Sell_Side_Lead_Advisor__c,
                                                                        Sell_Side_CoAdvisor__c,
                                                                        Lender__c,
                                                                        ECM__c,
                                                                        DCM__c,
                                                                        Primary_Company_Source__c,
                                                                        Mgmt_Intro_Offered__c,
                                                                        Mgmt_Intro_Desired__c,
                                                                        Mgmt_Intro_Delivered__c,
                                                                        CEO_Intro_Offered__c,
                                                                        CEO_Intro_Desired__c,
                                                                        CEO_Intro_Delivered__c,
                                                                        Other_Key_Intro_Offered__c,
                                                                        Other_Key_Intro_Desired__c,
                                                                        Other_Key_Intro_Delivered__c,
                                                                        Date_Validated__c,
                                                                        Last_Prepared_for_Analysis__c,
                                                                        WG_Member_Id__c,
                                                                        Upload_ID__c
                                                                FROM External_Working_Group_Member__c 
                                                                WHERE Deal__c IN:dealsToProcess AND (End_Date__c >= TODAY OR End_Date__c= null)];
            for(External_Working_Group_Member__c objWGMember : objWGMemberList)
            {    
                External_Working_Group_Member__c newWGMember = new External_Working_Group_Member__c(Company__c = objWGMember.Deal__r.Salesforce_Company__c, 
                                                                                                    Contact__c = objWGMember.Contact__c, 
                                                                                                    End_Date__c = objWGMember.End_Date__c,
                                                                                                    Original_Company__c = objWGMember.Original_Company__c,
                                                                                                    //Deal__c = objWGMember.Deal__c,
                                                                                                    Role__c = objWGMember.Role__c,
                                                                                                    Initial_Participation_Date__c = objWGMember.Initial_Participation_Date__c,
                                                                                                    Contribution_Value__c = objWGMember.Contribution_Value__c,
                                                                                                    Notes__c = objWGMember.Notes__c,
                                                                                                    AS_Team_Leader__c = objWGMember.AS_Team_Leader__c,
                                                                                                    Primary_Idea_Source__c = objWGMember.Primary_Idea_Source__c,
                                                                                                    Sell_Side_Lead_Advisor__c = objWGMember.Sell_Side_Lead_Advisor__c,
                                                                                                    Sell_Side_CoAdvisor__c = objWGMember.Sell_Side_CoAdvisor__c,
                                                                                                    Lender__c = objWGMember.Lender__c,
                                                                                                    ECM__c = objWGMember.ECM__c,
                                                                                                    DCM__c = objWGMember.DCM__c,
                                                                                                    Primary_Company_Source__c = objWGMember.Primary_Company_Source__c,
                                                                                                    Mgmt_Intro_Offered__c = objWGMember.Mgmt_Intro_Offered__c,
                                                                                                    Mgmt_Intro_Desired__c = objWGMember.Mgmt_Intro_Desired__c,
                                                                                                    Mgmt_Intro_Delivered__c = objWGMember.Mgmt_Intro_Delivered__c,
                                                                                                    CEO_Intro_Offered__c = objWGMember.CEO_Intro_Offered__c,
                                                                                                    CEO_Intro_Desired__c = objWGMember.CEO_Intro_Desired__c,
                                                                                                    CEO_Intro_Delivered__c = objWGMember.CEO_Intro_Delivered__c,
                                                                                                    Other_Key_Intro_Offered__c = objWGMember.Other_Key_Intro_Offered__c,
                                                                                                    Other_Key_Intro_Desired__c = objWGMember.Other_Key_Intro_Desired__c,
                                                                                                    Other_Key_Intro_Delivered__c = objWGMember.Other_Key_Intro_Delivered__c,
                                                                                                    Date_Validated__c = objWGMember.Date_Validated__c,
                                                                                                    Last_Prepared_for_Analysis__c = objWGMember.Last_Prepared_for_Analysis__c,                                                                                                
                                                                                                    Upload_ID__c = objWGMember.Upload_ID__c);
                /*if(objWGMember.End_Date__c>Date.today()||objWGMember.End_Date__c==null)
                {
                    objWGMember.End_Date__c = Date.today();
                }*/
                lstWGMembersToBeCreated.add(newWGMember);            
            }
            insert lstWGMembersToBeCreated;
            //update objWGMemberList;
            update lstAccToUpdate;
            //Inserting the copy of WG member records
            
            WGMembersCreated = true;
        }
    }
}