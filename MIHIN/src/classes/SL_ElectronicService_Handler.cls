/*
*Class: SL_ElectronicService_Handler
*Description: This is handler class.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_ElectronicService_Handler {

	private static Set<String> setobjectFields = Schema.SObjectType.Electronic_Service__c.fields.getMap().keySet(); //Added for MIHIN-108
	
	/*  
    @MethodName   : onBeforeUpdate
    @param        : Map<Id, Electronic_Service__c> mapOldES and Map<Id, Electronic_Service__c> mapNewES
    @Description  : Method called on event: Before Update
    */
    public void onBeforeUpdate(Map<Id, Electronic_Service__c> mapOldES, Map<Id, Electronic_Service__c> mapNewES)
    {
    	set<Id> setRecordIds = new set<Id>();//To store the contacts where ownerId is changed.
    	set<Id> setErrorRecordIds = new set<Id>();//To store the contacts those are having errors
    	
    	serviceDestinationUpdate(mapNewES.values()); //Added for MIHIN-108
    	
    	//Collecting the record Ids where owner id is changed.
    	for(Electronic_Service__c objES : mapNewES.values())
    	{
    		if(mapOldES.get(objES.Id).OwnerId != mapNewES.get(objES.Id).OwnerId)
				setRecordIds.add(objES.Id);
    	}
    	
    	//If set is not Empty then checking the access level and profile of loggedin user.
    	if(!setRecordIds.isEmpty()) {
    		
    		SL_ValidateRecordTransfer objSL_ValidateRecordTransfer = new SL_ValidateRecordTransfer();
    		setErrorRecordIds = objSL_ValidateRecordTransfer.validateUpdatedRecords(setRecordIds);//Calling the method to get the Error record Ids.
    		
    		if(!setErrorRecordIds.isEmpty()) {
    			//Iterating the records and throwing error.
		    	for(Electronic_Service__c objES : mapNewES.values())
		    	{
		    		if(setErrorRecordIds.contains(objES.Id))
		    			objES.addError(Label.SL_UnauthorizedRecordTransferError);//Adding the error message to show.
		    	}
    		}
    		
    	}
    }
    
    /*  
            @MethodName   : onBeforeInsert
            @param        : List<Electronic_Service__c>(trigger.new)
            @Description  : Method called on event: Before insert
    */
    
    public void onBeforeInsert(List<Electronic_Service__c> lstElectronicServiceHandlerlst)
    {
        serviceDestinationUpdate(lstElectronicServiceHandlerlst); //Added for MIHIN-108
    }
    
    /*  
            @MethodName   : serviceDestinationUpdate
            @param        : List<Electronic_Service__c>(trigger.new)
            @Description  : Method called on event: Before insert to populate Service_Destinations__c
    */
    
    private void serviceDestinationUpdate(List<Electronic_Service__c> lstElectronicServiceHandlerlst) //Added for MIHIN-108
    {
        List<Electronic_Service_Mapping__c> lstElectronicServiceMapping = new List<Electronic_Service_Mapping__c>();
        lstElectronicServiceMapping = Electronic_Service_Mapping__c.getAll().values();
        if(!lstElectronicServiceMapping.isEmpty())
            for(Electronic_Service__c objElectronicService : lstElectronicServiceHandlerlst)
            {
                objElectronicService.Service_Destinations__c = '';
                for(Electronic_Service_Mapping__c customSetting : lstElectronicServiceMapping)
                {
                    if(setobjectFields.contains(customSetting.API_Name__c.toLowerCase()) && objElectronicService.get(customSetting.API_Name__c) == true)
                    {
                        objElectronicService.Service_Destinations__c += customSetting.Name+';';
                    }
                }
            }
    }
	
}