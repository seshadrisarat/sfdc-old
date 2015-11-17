/**
* \arg ClassName      		: SL_InterestsHandler
* \arg JIRATicket       	: HIL-21
* \arg CreatedOn        	: 13/OCT/2015
* \arg LastModifiedOn   	: 14/OCT/2015
* \arg CreatededBy      	: Pankaj Ganwani
* \arg LastModifiedBy       : Pankaj Ganwani
* \arg Description      	: Interests trigger Handler for updating the household field value on inserted Interests__c record and creation of sharing records based on the values of Rep Codes.
*/
public without sharing class SL_InterestsHandler 
{
	/* Start - Constructor */
    public SL_InterestsHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Interests__c> lstInterests)
    {
        updateHousehold(lstInterests);
    }
    
    public static void onAfterInsert(List <Interests__c> lstInterests)
    {
        createSharingRule(lstInterests, true);
    }
    
    private static void updateHousehold(List<Interests__c> lstInterests)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Interests__c objInterests : lstInterests)
        {
    		if(objInterests.Client_Prospect__c!=NULL)
    			setAccountIds.add(objInterests.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Interests__c objInterests : lstInterests)
        {
        	if(mapAccIdToHousehold.containskey(objInterests.Client_Prospect__c))
        		objInterests.Household__c = mapAccIdToHousehold.get(objInterests.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Interests__c> lstInterests, Boolean isInterestTrigger)
    {
        Map<Id,Id> mapInterestsIdToHouseHoldId = new Map<Id,Id>();
        
        for(Interests__c objI : lstInterests)
        {
        	if(objI.Household__c!=NULL) 
        		mapInterestsIdToHouseHoldId.put(objI.Id, objI.Household__c);
        }
        
        if(!isInterestTrigger)
        	Database.delete([SELECT Id FROM Interests__Share WHERE ParentId IN : mapInterestsIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapInterestsIdToHouseHoldId),false);
    }
}