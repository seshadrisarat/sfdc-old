/**
* @TriggerName  : SL_FinancialPlanHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Financial_Plan__c.
*/
public with sharing class SL_FinancialPlanHandler 
{
	/* Start - Constructor */
    public SL_FinancialPlanHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Financial_Plan__c> lstFP)
    {
        updateHousehold(lstFP);
    }
    
    public static void onAfterInsert(List <Financial_Plan__c> lstFP)
    {
        createSharingRule(lstFP, true);
    }
    
    private static void updateHousehold(List<Financial_Plan__c> lstFP)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Financial_Plan__c objFP : lstFP)
        {
    		if(objFP.Client_Prospect__c!=NULL)
    			setAccountIds.add(objFP.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Financial_Plan__c objFP : lstFP)
        {
        	if(mapAccIdToHousehold.containskey(objFP.Client_Prospect__c))
        		objFP.Relationship_Group__c = mapAccIdToHousehold.get(objFP.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Financial_Plan__c> lstFP, Boolean isFPTrigger)
    {
        Map<Id,Id> mapFPIdToHouseHoldId = new Map<Id,Id>();
        
        for(Financial_Plan__c objFP : lstFP)
        {
        	if(objFP.Relationship_Group__c!=NULL) 
        		mapFPIdToHouseHoldId.put(objFP.Id, objFP.Relationship_Group__c);
        }
        
        if(!isFPTrigger)
        	Database.delete([SELECT Id FROM Financial_Plan__Share WHERE ParentId IN : mapFPIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapFPIdToHouseHoldId),false);
    }
}