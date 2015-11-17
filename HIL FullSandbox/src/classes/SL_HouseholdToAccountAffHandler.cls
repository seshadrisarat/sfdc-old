/**
* @ClassName  	: SL_HouseholdToAccountAffHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Household_To_Account_Affiliation__c.
*/
public without sharing class SL_HouseholdToAccountAffHandler 
{
	/* Start - Constructor */
    public SL_HouseholdToAccountAffHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Household_To_Account_Affiliation__c> lstHAA)
    {
        updateHousehold(lstHAA);
    }
    
    public static void onAfterInsert(List <Household_To_Account_Affiliation__c> lstHAA)
    {
        createSharingRule(lstHAA);
    }
    
    private static void updateHousehold(List<Household_To_Account_Affiliation__c> lstHAA)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Household_To_Account_Affiliation__c objHAA : lstHAA)
        {
    		if(objHAA.Account__c!=NULL)
    			setAccountIds.add(objHAA.Account__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Household_To_Account_Affiliation__c objHAA : lstHAA)
        {
        	if(mapAccIdToHousehold.containskey(objHAA.Account__c))
        		objHAA.Household__c = mapAccIdToHousehold.get(objHAA.Account__c);
        }
    }
    
    private static void createSharingRule(List <Household_To_Account_Affiliation__c> lstHAA)
    {
        
    }
}