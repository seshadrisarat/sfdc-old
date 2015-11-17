/**  
* \arg ClassName        : SL_AS_ProjectTriggerHandler
* \arg JIRATicket       : 
* \arg CreatedOn        : 
* \arg LastModifiedOn   : 
* \arg CreatededBy      : 
* \arg ModifiedBy       : 
* \arg Description      : Handler class for AS_Project object.
*/
global class SL_AS_ProjectTriggerHandler extends SL_TriggerHandlerBase {
    Id portFoliRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Portfolio Company').RecordTypeId;
    Id activeDealRecTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Active Process').RecordTypeId;
    
    public override void beforeInsert(List<SObject> newListGeneric){
        List<AS_Project__c> newList = (List<AS_Project__c>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        
        /*BEFORE INSERT METHODS END*/
    }
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, AS_Project__c> oldMap = (Map<Id, AS_Project__c>) oldMapGeneric;
        Map<Id, AS_Project__c> newMap = (Map<Id, AS_Project__c>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        
        /*BEFORE UPDATE METHODS END*/
    }
    
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, AS_Project__c> oldMap = (Map<Id, AS_Project__c>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        rollupProjectsToCompany(NULL, oldMap);
        /*BEFORE DELETE METHODS END*/
    }
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, AS_Project__c> newMap = (Map<Id, AS_Project__c>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
        rollupProjectsToCompany(NULL, newMap);
        /*AFTER INSERT METHODS END*/
    }
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, AS_Project__c> oldMap = (Map<Id, AS_Project__c>) oldMapGeneric;
        Map<Id, AS_Project__c> newMap = (Map<Id, AS_Project__c>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
        rollupProjectsToCompany(oldMap, newMap);
        /*AFTER UPDATE METHODS END*/
    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, AS_Project__c> oldMap = (Map<Id, AS_Project__c>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        
        /*AFTER DELETE METHODS END*/
    }
    
    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, AS_Project__c> newMap = (Map<Id, AS_Project__c>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/
        
        /*AFTER UNDELETE METHODS END*/
    }
    
    // Method to rollup the field from child AS_Projects to Parent Company with either 'Portfolio' OR 'Active Process' recordType...
    private void rollupProjectsToCompany(Map<Id, AS_Project__c> oldMap, Map<Id,AS_Project__c> newMap) {
        List<AS_Project__c> lstUpdateProjects = new List<AS_Project__c>();
        Map<Id, List<AS_Project__c>> mapOfCompanyIdToLstOfPRojects = new Map<Id, List<AS_Project__c>>();
        Map<Id, AS_Project__c> mapOfNewProjectMap = new Map<Id, AS_Project__c>();
        mapOfNewProjectMap = newMap;

        // Iterating over the NewMap values
        for(AS_Project__c objASPRoject : mapOfNewProjectMap.values()) {
            if(oldMap == NULL ||  (oldMap != NULL && (objASPRoject.AS_Project_Team__c != oldMap.get(objASPRoject.Id).AS_Project_Team__c || objASPRoject.Portfolio_Company__c != oldMap.get(objASPRoject.Id).Portfolio_Company__c) ))
            {
                if(!mapOfCompanyIdToLstOfPRojects.containsKey(objASPRoject.Portfolio_Company__c))
                    mapOfCompanyIdToLstOfPRojects.put(objASPRoject.Portfolio_Company__c, new List<AS_Project__c>());

                // Adding the values here.
                mapOfCompanyIdToLstOfPRojects.get(objASPRoject.Portfolio_Company__c).add(objASPRoject);
            }
        }

        // Considering only 'Portfolio Company' OR 'Active Process' recordType Companies
        for(Account objAcc : [SELECT Id FROM Account WHERE Id IN:mapOfCompanyIdToLstOfPRojects.keySet() AND (recordtypeId=:portFoliRecTypeId OR recordtypeId =:activeDealRecTypeId)]) {
            lstUpdateProjects.addAll(mapOfCompanyIdToLstOfPRojects.get(objAcc.Id));
        }

        // if no Values added in to the lst then do nothing
        if(lstUpdateProjects.isEmpty())
            return;

        // Calling this class to update the Rollup field on Parent....
        SL_RollupHelper.rollupTextField(lstUpdateProjects, 'AS_Project_Team__c', 'RG_Team_Members__c', 'Portfolio_Company__c', 'Account', 'AS_Projects__r', ',', true);
    }
}