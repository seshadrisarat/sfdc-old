/**
* @TriggerName  : SL_HeldAwayAssetHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger handler to update HouseHold field value on inserted Held_Away_Asset__c.
*/
public without sharing class SL_HeldAwayAssetHandler 
{
	/* Start - Constructor */
    public SL_HeldAwayAssetHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Held_Away_Asset__c> lstHAA)
    {
        updateHousehold(lstHAA);
    }
    
    public static void onAfterInsert(List <Held_Away_Asset__c> lstHAA)
    {
        createSharingRule(lstHAA);
    }
    
    private static void updateHousehold(List<Held_Away_Asset__c> lstHAA)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Held_Away_Asset__c objHAA : lstHAA)
        {
    		setAccountIds.add(objHAA.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Held_Away_Asset__c objHAA : lstHAA)
        {
        	if(mapAccIdToHousehold.containskey(objHAA.Client_Prospect__c))
        		objHAA.Primary_Household__c = mapAccIdToHousehold.get(objHAA.Client_Prospect__c);
        }
    }
    
    private static void createSharingRule(List <Held_Away_Asset__c> lstHAA)
    {
        
    }
}