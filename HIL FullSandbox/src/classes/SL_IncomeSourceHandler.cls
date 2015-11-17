/**
* @ClassName  	: SL_IncomeSourceHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger handler to update HouseHold field value on inserted Income_Source__c.
*/
public with sharing class SL_IncomeSourceHandler 
{
	/* Start - Constructor */
    public SL_IncomeSourceHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Income_Source__c> lstIS)
    {
        updateHousehold(lstIS);
    }
    
    public static void onAfterInsert(List <Income_Source__c> lstIS)
    {
        createSharingRule(lstIS,true);
    }
    
    private static void updateHousehold(List<Income_Source__c> lstIS)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Income_Source__c objIS : lstIS)
        {
    		if(objIS.Client_Prospect__c!=NULL)
    			setAccountIds.add(objIS.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Income_Source__c objIS : lstIS)
        {
        	if(mapAccIdToHousehold.containskey(objIS.Client_Prospect__c))
        		objIS.Primary_Relationship_Group__c = mapAccIdToHousehold.get(objIS.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Income_Source__c> lstIS, Boolean isISTrigger)
    {
        Map<Id,Id> mapISIdToHouseHoldId = new Map<Id,Id>();
        
        for(Income_Source__c objIS : lstIS)
        {
        	if(objIS.Primary_Relationship_Group__c!=NULL) 
        		mapISIdToHouseHoldId.put(objIS.Id, objIS.Primary_Relationship_Group__c);
        }
        
        if(!isISTrigger)
        	Database.delete([SELECT Id FROM Income_Source__Share WHERE ParentId IN : mapISIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapISIdToHouseHoldId),false);
    }
}