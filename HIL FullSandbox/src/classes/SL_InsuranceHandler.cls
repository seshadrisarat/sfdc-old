/**
* @ClassName    : SL_InsuranceHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Insurance__c.
*/
public with sharing class SL_InsuranceHandler 
{
	/* Start - Constructor */
    public SL_InsuranceHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Insurance__c> lstInsurance)
    {
        updateHousehold(lstInsurance);
    }
    
    public static void onAfterInsert(List<Insurance__c> lstInsurance)
    {
    	createSharingRule(lstInsurance, true);
    }
    
    private static void updateHousehold(List<Insurance__c> lstInsurance)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Insurance__c objInsurance : lstInsurance)
        {
    		if(objInsurance.Client_Prospect__c!=NULL)
    			setAccountIds.add(objInsurance.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Insurance__c objInsurance : lstInsurance)
        {
        	if(objInsurance.Client_Prospect__c!=NULL && mapAccIdToHousehold.containskey(objInsurance.Client_Prospect__c))
        		objInsurance.Primary_Relationship_Group__c = mapAccIdToHousehold.get(objInsurance.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Insurance__c> lstInsurance, Boolean isInsuranceTrigger)
    {
        Map<Id,Id> mapInsuranceIdToHouseHoldId = new Map<Id,Id>();
        
        for(Insurance__c objInsurance : lstInsurance)
        {
        	if(objInsurance.Primary_Relationship_Group__c!=NULL) 
        		mapInsuranceIdToHouseHoldId.put(objInsurance.Id, objInsurance.Primary_Relationship_Group__c);
        }
        
        if(!isInsuranceTrigger)
        	Database.delete([SELECT Id FROM Insurance__Share WHERE ParentId IN : mapInsuranceIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapInsuranceIdToHouseHoldId),false);
    }    
}