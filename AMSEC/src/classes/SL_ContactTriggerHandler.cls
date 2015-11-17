/**  
* \arg ClassName        : SL_ContactTriggerHandler
* \arg JIRATicket       : AMSEC-627
* \arg CreatedOn        : 07/Oct/15
* \arg LastModifiedOn   : 07/Oct/15
* \arg CreatededBy      : Praful Gadge
* \arg ModifiedBy       : Praful Gadge
* \arg Description      : Handler class for Contact object.
*/
global class SL_ContactTriggerHandler extends SL_TriggerHandlerBase {
	public override void beforeInsert(List<SObject> newListGeneric){
        List<Contact> newList = (List<Contact>) newListGeneric;
        /*BEFORE INSERT METHODS START*/
        
        /*BEFORE INSERT METHODS END*/
    } 
    
    public override void beforeUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*BEFORE UPDATE METHODS START*/
        
        /*BEFORE UPDATE METHODS END*/
    }
    
    public override void beforeDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        /*BEFORE DELETE METHODS START*/
        
        /*BEFORE DELETE METHODS END*/
    } 
    
    public override void afterInsert(Map<Id, SObject> newMapGeneric){
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER INSERT METHODS START*/
    	upsertOutlookSync(new Set<Id>(newMap.keySet()));
        /*AFTER INSERT METHODS END*/
    } 
    
    public override void afterUpdate(Map<Id, SObject> oldMapGeneric, Map<Id, SObject> newMapGeneric){
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER UPDATE METHODS START*/
       	updateOutlookSync(newMap, oldMap); 
        /*AFTER UPDATE METHODS END*/
    }
    
    public override void afterDelete(Map<Id, SObject> oldMapGeneric){
        Map<Id, Contact> oldMap = (Map<Id, Contact>) oldMapGeneric;
        /*AFTER DELETE METHODS START*/
        
        /*AFTER DELETE METHODS END*/
    }
    
    public override void afterUndelete(Map<Id, SObject> newMapGeneric){
        Map<Id, Contact> newMap = (Map<Id, Contact>) newMapGeneric;
        /*AFTER UNDELETE METHODS START*/
        
        /*AFTER UNDELETE METHODS END*/
    }

    private void updateOutlookSync(Map<Id, Contact> newMap, Map<Id, Contact> oldMap) {

    	Set<Id> setContactIds = new Set<Id>();

    	for(Contact objC : newMap.values()){
    		if(objC.AccountId != oldMap.get(objC.Id).AccountId)
    			setContactIds.add(objC.Id);
    	}

    	if(!setContactIds.isEmpty())
    		upsertOutlookSync(setContactIds);
    }

    private void upsertOutlookSync(Set<Id> setContactIds) {

        Set<Id> setContIds = new Set<Id>();
        Set<Id> setAllContactIds = new Set<Id>();
        Map<String, Outlook_Sync__c> mapContactKeyToOutlookSychToUpsert = new Map<String, Outlook_Sync__c>();
    
        Map<String, Id> mapAccIdToContactId = new Map<String, Id>();
    
        Id accountId = [SELECT AccountId FROM Contact WHERE Id IN :setContactIds AND Account.Name = 'American Securities LLC' LIMIT 1].AccountId;
    
        for(Contact objCon : [SELECT Id, AccountId FROM Contact WHERE AccountId = :accountId AND Id NOT IN :setContactIds]){
            setContIds.add(objCon.Id);
            for(Id cId : setContactIds){
                mapContactKeyToOutlookSychToUpsert.put(cId+'_'+objCon.Id, new Outlook_Sync__c(Id=null, Contact__c=cId, AS_Person__c=objCon.Id));                
                mapContactKeyToOutlookSychToUpsert.put(objCon.Id+'_'+cId, new Outlook_Sync__c(Id=null, Contact__c=objCon.Id, AS_Person__c=cId));                
            }
        }
    
        setAllContactIds.addAll(setContIds);
        setAllContactIds.addAll(setContactIds);
        
        for(Outlook_Sync__c objOS : [SELECT Id, Contact__c, AS_Person__c FROM Outlook_Sync__c WHERE Contact__c IN :setAllContactIds AND AS_Person__c IN :setAllContactIds]){
            
            if(mapContactKeyToOutlookSychToUpsert.containsKey(objOS.Contact__c+'_'+objOS.AS_Person__c) && mapContactKeyToOutlookSychToUpsert.get(objOS.Contact__c+'_'+objOS.AS_Person__c) != null)
                mapContactKeyToOutlookSychToUpsert.get(objOS.Contact__c+'_'+objOS.AS_Person__c).Id = objOS.Id;
                
            if(mapContactKeyToOutlookSychToUpsert.containsKey(objOS.AS_Person__c+'_'+objOS.Contact__c) && mapContactKeyToOutlookSychToUpsert.get(objOS.AS_Person__c+'_'+objOS.Contact__c) != null)
                mapContactKeyToOutlookSychToUpsert.get(objOS.AS_Person__c+'_'+objOS.Contact__c).Id = objOS.Id;    
        }
    
        if(!mapContactKeyToOutlookSychToUpsert.isEmpty())
            upsert mapContactKeyToOutlookSychToUpsert.values();

    }
}