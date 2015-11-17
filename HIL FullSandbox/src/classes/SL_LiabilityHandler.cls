/**
* @ClassName  	: SL_LiabilityHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger handler to update HouseHold field value on inserted Liability__c.
*/
public with sharing class SL_LiabilityHandler 
{
	/* Start - Constructor */
    public SL_LiabilityHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Liability__c> lstLiability)
    {
        updateHousehold(lstLiability);
    }
    
    public static void onAfterInsert(List <Liability__c> lstLiability)
    {
        createSharingRule(lstLiability, true);
    }
    
    private static void updateHousehold(List<Liability__c> lstLiability)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Liability__c objLiability : lstLiability)
        {
    		setAccountIds.add(objLiability.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Liability__c objLiability : lstLiability)
        {
        	if(mapAccIdToHousehold.containskey(objLiability.Client_Prospect__c))
        		objLiability.Primary_Household__c = mapAccIdToHousehold.get(objLiability.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Liability__c> lstLiability, Boolean isLTrigger)
    {
         Map<Id,Id> mapLIdToHouseHoldId = new Map<Id,Id>();
        
        for(Liability__c objL : lstLiability)
        {
        	if(objL.Primary_Household__c!=NULL) 
        		mapLIdToHouseHoldId.put(objL.Id, objL.Primary_Household__c);
        }
        
        if(!isLTrigger)
        	Database.delete([SELECT Id FROM Liability__Share WHERE ParentId IN : mapLIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapLIdToHouseHoldId),false);
    }
}