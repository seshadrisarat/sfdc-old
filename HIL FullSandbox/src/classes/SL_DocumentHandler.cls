/**
* @ClassName  	: SL_DocumentHandler   
* @JIRATicket   : HIL-21
* @CreatedOn    : 13/OCT/2015
* @CreatedBy    : Pankaj Ganwani
* @Description  : Trigger to update HouseHold field value on inserted Document__c.
*/
public without sharing class SL_DocumentHandler 
{
	/* Start - Constructor */
    public SL_DocumentHandler()
    {
        //Do Nothing
    }
    /* End - Constructor */
    
    public static void onBeforeInsert(List <Document__c> lstDocument)
    {
        updateHousehold(lstDocument);
    }
    
    public static void onAfterInsert(List <Document__c> lstDocument)
    {
        createSharingRule(lstDocument, true);
    }
    
    private static void updateHousehold(List<Document__c> lstDocument)
    {
    	Map<Id, Id> mapAccIdToHousehold = new Map<Id, Id>();
        Set<Id> setAccountIds = new Set<Id>();
        
        for(Document__c objDocument : lstDocument)
        {
    		setAccountIds.add(objDocument.Client_Prospect__c);
        }
        
        if(setAccountIds.isEmpty())
        	return;        
        mapAccIdToHousehold = SL_Util_CreateChildSharings.formAccountToHouseholdMapping(setAccountIds);
        
        for(Document__c objDocument : lstDocument)
        {
        	if(mapAccIdToHousehold.containskey(objDocument.Client_Prospect__c))
        		objDocument.Primary_Relationship_Group__c = mapAccIdToHousehold.get(objDocument.Client_Prospect__c);
        }
    }
    
    public static void createSharingRule(List <Document__c> lstDocument, Boolean isDocTrigger)
    {
        Map<Id,Id> mapDocIdToHouseHoldId = new Map<Id,Id>();
        
        for(Document__c objDocument : lstDocument)
        {
        	if(objDocument.Primary_Relationship_Group__c!=NULL) 
        		mapDocIdToHouseHoldId.put(objDocument.Id, objDocument.Primary_Relationship_Group__c);
        }
        
        if(!isDocTrigger)
        	Database.delete([SELECT Id FROM Document__Share WHERE ParentId IN : mapDocIdToHouseHoldId.keyset()],false);
        
        Database.insert(SL_Util_CreateChildSharings.createSharingRecords(mapDocIdToHouseHoldId),false);
    }
}