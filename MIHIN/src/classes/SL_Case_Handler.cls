/*
*Class: SL_Case_Handler
*Description: This is handler class for case trigger.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
public with sharing class SL_Case_Handler {
	
	
	 /*  
    @MethodName   : onBeforeUpdate
    @param        : Map<Id, Case> mapOldCase and Map<Id, Case> mapNewCase
    @Description  : Method called on event: Before Update
    */
    public void onBeforeUpdate(Map<Id, Case> mapOldCase, Map<Id, Case> mapNewCase)
    {
    	set<Id> setRecordIds = new set<Id>();//To store the contacts where ownerId is changed.
    	set<Id> setErrorRecordIds = new set<Id>();//To store the error records.
    	
    	system.debug('==============');
    	
    	//Collecting records where owner id is changed.
    	for(Case objCase : mapNewCase.values())
    	{
    		if(mapOldCase.get(objCase.Id).OwnerId != mapNewCase.get(objCase.Id).OwnerId)
    				setRecordIds.add(objCase.Id);
    	}
    	  
     	//If set is not empty then calling validatedRecordTranfer class to validate the records.
    	if(!setRecordIds.isEmpty()) {
    		
    		SL_ValidateRecordTransfer objSL_ValidateRecordTransfer = new SL_ValidateRecordTransfer();
    		setErrorRecordIds = objSL_ValidateRecordTransfer.validateUpdatedRecords(setRecordIds);
    		
    		if(!setErrorRecordIds.isEmpty()) {
	    		//Iterating the records and throwing error on records those not satisfied the required conditions.
		    	for(Case objCase : mapNewCase.values())
		    	{
		    		if(setErrorRecordIds.contains(objCase.Id))
		    			objCase.addError(Label.SL_UnauthorizedRecordTransferError);
		    	}
    		}
    	}
    }

}