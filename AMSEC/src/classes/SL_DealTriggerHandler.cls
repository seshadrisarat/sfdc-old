/**  
* \arg ClassName        : SL_DealTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Handler class for Deal object.
*/
global class SL_DealTriggerHandler extends SL_TriggerHandlerBase {
    
    Id portFolioRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
    Id formerPortfolioRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Former Portfolio').RecordTypeId;
    Id activeDealRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Active Process').RecordTypeId;
    Id purchaseRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Deal__c' AND DeveloperName = 'Buy_Deal' LIMIT 1].Id;
    Id ideaRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Deal__c' AND DeveloperName = 'Idea' LIMIT 1].Id;
    
    private static Boolean isRun = true;
    private Set<String> setOfActiveOrInDevAmsecStatuses;
 
    /*Added by Sanath for AMSEC-664*/
    private set<String> setActiveAmsecStatus = new set<String>();
    /*Added by Sanath for AMSEC-664*/
    
    public SL_DealTriggerHandler(){

        setOfActiveOrInDevAmsecStatuses = new Set<String>();

        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            if((objStatus.Name.startsWith('Active') || objStatus.Name.startsWith('In Development')) && objStatus.Am_Sec_Status__c != NULL){
                setOfActiveOrInDevAmsecStatuses.add(objStatus.Am_Sec_Status__c);
                if(objStatus.Name.startsWith('Active')){
                    setActiveAmsecStatus.add(objStatus.Am_Sec_Status__c);
                }
            }
        }

    }

    public override void beforeInsert(List<SObject> newListGeneric){
        List<Deal__c> newList = (List<Deal__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        if(isRun)
        {
            validateDealOnInsert(newList);
            setAccountRecordType(newList);
        }
        isRun = false;
        /*BEFORE INSERT METHODS END*/
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) oldMapGeneric;
        Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        if(isRun)
            validateDealOnUpdate(oldMap,newMap);
        isRun = false;
        /*BEFORE UPDATE METHODS END*/
    }

    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        
        /*BEFORE DELETE METHODS END*/
    }
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        rollupDealsToCompany(newMap,null);
        creatBoxFolders(newMap);
        /*AFTER INSERT METHODS END*/
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) oldMapGeneric;
        Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        addWGMembersToPortfolioCompany(oldMap,newMap);
        isClosedDeal(newMap,oldMap);
        isDeadDeal(newMap,oldMap);
        rollupDealsToCompany(newMap,oldMap);
        updateFolderNamesInBox(oldMap, newMap);
        updateCompaniesRecordType(oldMap, newMap);
        updateBoxIdOnAccount(oldMap, newMap);
        /*AFTER UPDATE METHODS END*/
    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Deal__c> oldMap = (Map<Id, Deal__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        rollupDealsToCompany(oldMap, null);
        /*AFTER DELETE METHODS END*/
    }
    
    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Deal__c> newMap = (Map<Id, Deal__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/
        
        /*AFTER UNDELETE METHODS END*/
    }
    
    /*Added by Sanath for AMSEC-664*/
    
    /*
        * MethodName : setAccountRecordType
        * Param      : List<Deal__c>(Trigger.new)
        * Description: Updates Salesforce Company RecordType to Active 
    */
    
    private void setAccountRecordType(List<Deal__c> lstDealTriggerNew)
    {
        set<Id> setAccountId = new set<Id>();
        for(Deal__c objDeal : lstDealTriggerNew)
        {
            if(objDeal.Salesforce_Company__c != null && setActiveAmsecStatus.contains(objDeal.Deal_Status__c) )
                setAccountId.add(objDeal.Salesforce_Company__c);
        }
        
        if(!setAccountId.isEmpty())
        {
            List<Account> lstAccountToUpdateRecordType = new List<Account>();
            for(Account objAccount : [Select Id,RecordTypeId from Account where ( RecordTypeId != :formerPortfolioRecTypeId AND RecordTypeId != :portFolioRecTypeId )])
            {
                objAccount.RecordTypeId = activeDealRecTypeId;
                lstAccountToUpdateRecordType.add(objAccount);
            }
            
            if(!lstAccountToUpdateRecordType.isEmpty())
                update lstAccountToUpdateRecordType;
        }
    }
    
    /*Added by Sanath for AMSEC-664*/
    
    /*
        * MethodName : validateDealOnInsert
        * Param      : Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap
        * Description: Only 1 Purchase Deal may be in the Active or In development Status Bucket
    */
    private void validateDealOnInsert(List<Deal__c> newLstDeal) 
    {   
        Set<Id> setAccountIds = new Set<Id>();

        Map<Id, Integer> mapAccIdDealCount = new Map<Id, Integer>();

        for(Deal__c objDeal : newLstDeal){

            if(setOfActiveOrInDevAmsecStatuses.contains(objDeal.Deal_Status__c) && objDeal.Salesforce_Company__c != null && objDeal.RecordTypeId == purchaseRecTypeId){
                setAccountIds.add(objDeal.Salesforce_Company__c);

                if(!mapAccIdDealCount.containsKey(objDeal.Salesforce_Company__c))
                    mapAccIdDealCount.put(objDeal.Salesforce_Company__c, 1);
                else
                    mapAccIdDealCount.put(objDeal.Salesforce_Company__c, mapAccIdDealCount.get(objDeal.Salesforce_Company__c)+1);
            }
        }

        validateDealOnUpsert(newLstDeal, setAccountIds, mapAccIdDealCount);
    } 

    /*
        * MethodName : validateDealOnUpdate
        * Param      : Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap
        * Description: Only 1 Purchase Deal may be in the Active or In development Status Bucket
    */
    private void validateDealOnUpdate(Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap) 
    {   
        Set<Id> setAccountIds = new Set<Id>();

        Map<Id, Integer> mapAccIdDealCount = new Map<Id, Integer>();

        for(Deal__c objDeal : newMap.values()){

            Deal__c objOldDeal = oldMap.get(objDeal.Id);

            if(objDeal.Salesforce_Company__c != null 
                && ((objDeal.Deal_Status__c != objOldDeal.Deal_Status__c && !setOfActiveOrInDevAmsecStatuses.contains(objOldDeal.Deal_Status__c)) 
                || objDeal.Salesforce_Company__c != objOldDeal.Salesforce_Company__c || objDeal.RecordTypeId != objOldDeal.RecordTypeId ) 
                && setOfActiveOrInDevAmsecStatuses.contains(objDeal.Deal_Status__c) && objDeal.RecordTypeId == purchaseRecTypeId){

                    setAccountIds.add(objDeal.Salesforce_Company__c);

                if(!mapAccIdDealCount.containsKey(objDeal.Salesforce_Company__c))
                    mapAccIdDealCount.put(objDeal.Salesforce_Company__c, 1);
                else
                    mapAccIdDealCount.put(objDeal.Salesforce_Company__c, mapAccIdDealCount.get(objDeal.Salesforce_Company__c)+1);
            }
        }

        validateDealOnUpsert(new List<Deal__c>(newMap.values()), setAccountIds, mapAccIdDealCount);
    }

    /*
        * MethodName : validateDealOnUpsert
        * Param      : Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap
        * Description: Only 1 Purchase Deal may be in the Active or In development Status Bucket
    */
    private void validateDealOnUpsert(List<Deal__c> lstDealNew, Set<Id> setAccountIds, Map<Id, Integer> mapAccIdDealCount) {

        for(Deal__c objDeal : [SELECT Id, Salesforce_Company__c FROM Deal__c WHERE Salesforce_Company__c IN :setAccountIds AND RecordTypeId = :purchaseRecTypeId AND Deal_Status__c IN :setOfActiveOrInDevAmsecStatuses]){

            if(!mapAccIdDealCount.containsKey(objDeal.Salesforce_Company__c))
                mapAccIdDealCount.put(objDeal.Salesforce_Company__c, 1);
            else
                mapAccIdDealCount.put(objDeal.Salesforce_Company__c, mapAccIdDealCount.get(objDeal.Salesforce_Company__c)+1);
        }
        
        for(Deal__c objDeal : lstDealNew){
            if(mapAccIdDealCount.get(objDeal.Salesforce_Company__c) != null && mapAccIdDealCount.containsKey(objDeal.Salesforce_Company__c) && mapAccIdDealCount.get(objDeal.Salesforce_Company__c) > 1)
                objDeal.addError('Only 1 Purchase Deal should exist in an Active or In Development status');        
        }

    }

    /*
        * MethodName : updateCompaniesRecordType
        * Param      : Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap
        * Description: Calling to update the Companies RecordType when Deal.Deal_Status__c is changed and belongs to Active records in Status_Buckets__c custom settings and Salesforce_Company is not null
    */
    private void updateCompaniesRecordType(Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap) 
    {
        Set<String> setOfActiveAmsecStatuses = new Set<String>();
        Set<String> setOfInActiveOrInDevAmsecStatuses = new Set<String>();

        Id activeProcessRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'Active_Process' LIMIT 1].Id;
        Id generalRecTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'General' LIMIT 1].Id;
        List<Account> lstAccountToUpdate = new List<Account>(); 
        List<ID> accountIDs = new List<ID>();
        // Collecting all the Active Status values from the custom setting....
        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL){
                setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
            }

            if((objStatus.Name.startsWith('Inactive') || objStatus.Name.startsWith('In Development')) && objStatus.Am_Sec_Status__c != NULL){
                setOfInActiveOrInDevAmsecStatuses.add(objStatus.Am_Sec_Status__c);
            }
        }

        for(Deal__c objDeal : newMap.values()) {

            Deal__c objOldDeal = oldMap.get(objDeal.Id);
            
            // Checking if Deal.Deal_Status__c is changed and belongs to Active records in Status_Buckets__c custom settings and Salesforce_Company is not null
            if(objDeal.Deal_Status__c != objOldDeal.Deal_Status__c && setOfActiveAmsecStatuses.contains(objDeal.Deal_Status__c) 
                && objDeal.Salesforce_Company__c != null){

                lstAccountToUpdate.add(new Account(Id = objDeal.Salesforce_Company__c, RecordTypeId = activeProcessRecTypeId));
                accountIDs.add(objDeal.Salesforce_Company__c);
            }

            // Checking if Deal.Deal_Status__c is changed and belongs to InActiveORInDev records in Status_Buckets__c custom settings and Salesforce_Company is not null
            if(objDeal.Deal_Status__c != objOldDeal.Deal_Status__c && setOfInActiveOrInDevAmsecStatuses.contains(objDeal.Deal_Status__c) 
                 && objDeal.Salesforce_Company__c != null){

                lstAccountToUpdate.add(new Account(Id = objDeal.Salesforce_Company__c, RecordTypeId = generalRecTypeId));
                accountIDs.add(objDeal.Salesforce_Company__c);
            }
        }

        Map<ID,Account> mapAccounts = new Map<ID,Account>([select ID, RecordTypeId from Account where id in:accountIDs]); 
        List<Account> lstAccountToUpdate2 = new List<Account>(); 
        for(Account acc:lstAccountToUpdate)
        {
            if(mapAccounts.get(acc.Id).RecordTypeID!=portFolioRecTypeId && mapAccounts.get(acc.Id).RecordTypeID!=formerPortfolioRecTypeId)
            {
                lstAccountToUpdate2.add(acc);
            }
        }
        if(!lstAccountToUpdate2.isEmpty())
            update lstAccountToUpdate2;
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
        for(Account objAcc : [SELECT Id FROM Account WHERE Id IN:mapCompanyToListOfDeals.keySet() AND (recordtypeId=:activeDealRecTypeId OR recordtypeId =:portFolioRecTypeId)])
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
        Map<Id,String> deactivatedDeals = new Map<Id,String>();
        for(Deal__c objDeal:newMap.values())
        {
            if(setOfInactiveAmsecStatuses.contains(objDeal.Deal_Status__c)&&!setofInactiveAmsecStatuses.contains(oldMap.get(objDeal.Id).Deal_Status__c))
            {
                deactivatedDeals.put(objDeal.ID,'');
            }
            if(objDeal.Deal_Status__c=='Dead'&&oldMap.get(objDeal.ID).Deal_Status__c!='Dead')
            {
                salesforceCompanies.add(objDeal.Salesforce_Company__c);
            }
        }
        List<External_Working_Group_Member__c> wgMembToSync = [SELECT ID,Deal__c,WG_Type__c,Contact__c FROM External_Working_Group_Member__c WHERE deal__c in:deactivatedDeals.keyset()];
         SL_BoxSyncBatch b = new SL_BoxSyncBatch('unSyncFolder',deactivatedDeals, NULL,wgMembToSync);
            if(!Test.isRunningTest())
                Database.executeBatch(b,1);
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
            if(objDeal.Salesforce_Company__c != NULL 
                && oldDeal.Deal_Status__c != objDeal.Deal_Status__c 
                && objDeal.Deal_Status__c == 'Closed')
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
                                                                                                    Original_Deal_ID__c =objWGMember.Deal__c,
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

    /*
        * MethodName : creatBoxFolders
        * Param      : Map<Id,Deal__c> newMap
        * Description: Calling creatBoxFolders to create folders in box.com in a particular folder structure...
    */
    private void creatBoxFolders(Map<Id,Deal__c> newMapDealRecs) {
        // Querying the records to get their parent field's values
        Map<Id,String> folderNameMap = new Map<Id,String>();
        List<Deal__c> lstDealRecordsToUpdate = new List<Deal__c>();
        List<Deal__c> lstDealRecords = new List<Deal__c>();
        
        lstDealRecords = [Select Id, Name, Box_ID__c,Salesforce_Company__r.Box_ID__c, RecordTypeId, Salesforce_Company__r.Name, Salesforce_Company__c, Salesforce_Company__r.Alt_Box_Folder_Name__c 
                           From Deal__c 
                           Where Id IN : newMapDealRecs.keySet() AND (RecordTypeID=:purchaseRecTypeId OR RecordTypeID=:ideaRecTypeId)];
        //*Note*: Do not run Box Integration methods from @future methods. In order to successfully do the box integration you need to run
        // checkauthentication first which updates custom settings with the correct authentication tokens. Methods should always be run in batch
        // with checkauthentication() method run in the start() of the batch which will not affect the DML HTTP Callout collision. 
        // checking the list size.. to execute either batch or Trigger only..
        Boolean needsUpdate = false;
        for(Deal__c objDeal : lstDealRecords ) {
            if(objDeal.Salesforce_Company__r.Box_ID__c!=null)
            {
                objDeal.Box_ID__c = objDeal.Salesforce_Company__r.Box_ID__c;
                needsUpdate = true;
            }
            if(objDeal.Box_ID__c == NULL) {
                String folderName = getFolderName(objDeal);
                folderNameMap.put(objDeal.ID,folderName);
            }
            
        }
        if(needsUpdate)
            update lstDealRecords;
        system.debug('folderNameMap=== AFTER INERT=========>>>' +folderNameMap);

        if(!folderNameMap.isEmpty()) {
            // Calling the Batch
            SL_BoxBatch b = new SL_BoxBatch('createFolder',folderNameMap, new Map<Id, boolean>(),null);
            if(!Test.isRunningTest())
                Database.executeBatch(b,1);
        }
    }   

    /*
        * MethodName : updateFolderNamesInBox
        * Param      : Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap
        * Description: Calling to update the folderName in the Box.com...
    */
    private void updateFolderNamesInBox(Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap) 
    {
        Map<Id,String> folderNameMap = new Map<Id,String>();
        Set<Id> setOfDealIds = new Set<Id>();       // Set to keep those Deal Ids where the Salesforce_COmpany field got changed to get the Folder Name 
        Set<String> setOfActiveAmsecStatuses = new Set<String>();
        Map<Id, boolean> mapOfDealIdToStatusChanged = new Map<Id, Boolean>();
        
        // Collecting all the Active Status values from the custom setting....
        for(Status_Buckets__c objStatus : Status_Buckets__c.getAll().values()) {
            if(objStatus.Name.startsWith('Active') && objStatus.Am_Sec_Status__c != NULL)
                setOfActiveAmsecStatuses.add(objStatus.Am_Sec_Status__c);
        }

        for(Deal__c objDeal : newMap.values()) 
        {
            Deal__c objOldDeal = oldMap.get(objDeal.Id);
            // Checking the Box Id here....
            if(objDeal.Box_ID__c != NULL) {
                /*** 
                ASSUMPTION : If Both Salesforce_Company and Name got changed, we are considering the comany.Name OR comany.Alt_Box_Folder_Name
                ***/
                // If comany got changed adding in to the set and wil get the folderName form the COmapny.Name OR Company.Alt_Box_Folder_Name__c fields.
                if(objDeal.Salesforce_Company__c != NULL && objDeal.Salesforce_Company__c != objOldDeal.Salesforce_Company__c)
                    setOfDealIds.add(objDeal.Id);
                // If Name got changed directly adding in to the map
                else if(objDeal.Name != NULL && ((objDeal.Deal_Status__c != objOldDeal.Deal_Status__c) ||  (objDeal.Salesforce_Company__c != objOldDeal.Salesforce_Company__c) || ( objDeal.Name != objOldDeal.Name))) 
                    setOfDealIds.add(objDeal.Id);
            }

            // Checking the Amsec. Status got changed to a active STATUS as per the custom settingor not for a Deal record.
            if(setOfActiveAmsecStatuses.contains(objDeal.Deal_Status__c) && objDeal.Deal_Status__c != objOldDeal.Deal_Status__c){
                mapOfDealIdToStatusChanged.put(objDeal.Id, TRUE);
            }
        }

        // Collecting the Deal records and updating the Fodler Names in Box.com...
        if(!setOfDealIds.isEmpty()) {
            // Querying the Updated Salesforce_Company related field to get the folder Name to update in Box.com
            for(Deal__c objDeal : [Select Id, Name, RecordTypeId, Salesforce_Company__r.Name, Salesforce_Company__c, Salesforce_Company__r.Alt_Box_Folder_Name__c 
                                    From Deal__c 
                                    Where Id IN : setOfDealIds ]  ) {
                String folderName = getFolderName(objDeal);
                folderNameMap.put(objDeal.ID,folderName);
            }
        }

        system.debug('folderNameMap====>>>>' +folderNameMap);

        // calling the Batch
        if(!folderNameMap.isEmpty())
        {
            SL_BoxBatch b = new SL_BoxBatch('moveFolder',folderNameMap, mapOfDealIdToStatusChanged,null);
            if(!Test.isRunningTest())
                Database.executeBatch(b,1);
        }
    }

    /*
        * MethodName : getFolderName
        * Param      : Deal__c objDeal
        * Description: Calling to get the folder Name for the Deal..
    */
    public string getFolderName(Deal__c objDeal) {
        String folderName = '';
                
        // ForderName will be the RELATED COMPANY's Alt_Box_Folder_Name__c field value..
        if(objDeal.Salesforce_Company__c != NULL && objDeal.Salesforce_Company__r.Alt_Box_Folder_Name__c != null) {
            folderName = objDeal.Salesforce_Company__r.Alt_Box_Folder_Name__c;
        }
        // ForderName will be the RELATED COMPANY NAME..
        else if( objDeal.Salesforce_Company__c != null && objDeal.Salesforce_Company__r.Alt_Box_Folder_Name__c == null) {
            folderName = objDeal.Salesforce_Company__r.Name;    
        }
        // ForderName will be it's OWN NAME..
        else if(objDeal.Salesforce_Company__c == null) { 
            folderName = objDeal.Name;
        }

        return folderName;
    }
    
     /*
        * MethodName : updateBoxIdOnAccount
        * Param      : old and new version of Deal records
        * Description: Calling to update the Box Id on Account.
    */
    private void updateBoxIdOnAccount(Map<Id, Deal__c> oldMap, Map<Id, Deal__c> newMap)
    {
        Map<Id, Integer> mapAccIdToDealCount = new Map<Id, Integer>();
        Set<Id> setOldAccountIds = new Set<Id>();
        Set<Id> setNewAccountIds = new Set<Id>();
        Set<Id> setUpdatedDeals = new Set<Id>();
        Map<Id, Account> mapIdToAccount = new Map<Id, Account>();
        
        for(Deal__c objDeal : newMap.values())
        {
            Deal__c objOldDeal = oldMap.get(objDeal.Id);
            if(objDeal.Salesforce_Company__c!=objOldDeal.Salesforce_Company__c)
            {
                setUpdatedDeals.add(objDeal.Id);
                if(objDeal.Salesforce_Company__c==NULL)
                {
                    if(objOldDeal.Salesforce_Company__c!=NULL)
                    setOldAccountIds.add(objOldDeal.Salesforce_Company__c);
                }
                else
                    setNewAccountIds.add(objDeal.Salesforce_Company__c);
            }
        }
        
        Set<Id> setAllAccounts = new Set<Id>();
        setAllAccounts.addAll(setOldAccountIds);
        setAllAccounts.addAll(setNewAccountIds);
        
        for(Account objAccount : [Select Id, (Select Id From Deals2__r WHERE Box_ID__c!=NULL AND Id NOT IN : setUpdatedDeals) From Account WHERE Id IN : setAllAccounts])
        {
            mapAccIdToDealCount.put(objAccount.Id, objAccount.Deals2__r.size());
        }
        
        for(Deal__c objDeal : newMap.values())
        {
            Deal__c objOldDeal = oldMap.get(objDeal.Id);
            if(objDeal.Salesforce_Company__c!=objOldDeal.Salesforce_Company__c)
            {
                if(objDeal.Salesforce_Company__c==NULL)
                {
                    if(objOldDeal.Salesforce_Company__c!=NULL && mapAccIdToDealCount.containskey(objOldDeal.Salesforce_Company__c) && mapAccIdToDealCount.get(objOldDeal.Salesforce_Company__c) == 0)
                        mapIdToAccount.put(objOldDeal.Salesforce_Company__c , new Account(Id = objOldDeal.Salesforce_Company__c, Box_ID__c = NULL));
                }
                else
                {
                    mapIdToAccount.put(objDeal.Salesforce_Company__c ,new Account(Id = objDeal.Salesforce_Company__c, Box_ID__c = mapAccIdToDealCount.containskey(objDeal.Salesforce_Company__c) && mapAccIdToDealCount.get(objDeal.Salesforce_Company__c) == 0 ? NULL : objDeal.Box_ID__c));
                }
            }
        }
        
        update mapIdToAccount.values();
    }
}