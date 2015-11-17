/**
* @ClassName  	: SL_ProductsServicesHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Products_Services__c.
*/
public without sharing class SL_ProductsServicesHandler 
{
	/* Start - Constructor */
    public SL_ProductsServicesHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Products_Services__c> lstPS)
    {
        updateHousehold(lstPS);
    }
    
    public static void onAfterInsert(List <Products_Services__c> lstPS)
    {
        createSharingRule(lstPS, true);
    }
    
    private static void updateHousehold(List<Products_Services__c> lstPS)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Products_Services__c objPS : lstPS)
        {
    		if(objPS.Client_Prospect__c!=NULL)
    			setAccountIds.add(objPS.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Products_Services__c objPS : lstPS)
        {
        	if(mapAccIdToHousehold.containskey(objPS.Client_Prospect__c))
        		objPS.Household__c = mapAccIdToHousehold.get(objPS.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Products_Services__c> lstPS, Boolean isPSTrigger)
    {
        Map<Id,Id> mapPSIdToHouseHoldId = new Map<Id,Id>();
        
        for(Products_Services__c objPS : lstPS)
        {
        	if(objPS.Household__c!=NULL)
        		mapPSIdToHouseHoldId.put(objPS.Id, objPS.Household__c);
        }
        
        if(!isPSTrigger)
        	Database.delete([SELECT Id FROM Products_Services__Share WHERE ParentId IN : mapPSIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapPSIdToHouseHoldId),false);
    }
}