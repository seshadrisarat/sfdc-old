/*
*Trigger: SL_ElectronicService
*Description: This trigger is used to validate the electronic service record transfer.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_ElectronicService on Electronic_Service__c (before update , Before insert) { 
	
	SL_ElectronicService_Handler Handler = new SL_ElectronicService_Handler();// This handler for MIHIN-92 functionality.
    
    //If trigger is before update.
    if(Trigger.isBefore && Trigger.isUpdate)    
    {
        Handler.onBeforeUpdate(Trigger.OldMap, Trigger.NewMap);//Calling the handler class function.
    }
    //Added for MIHIN-108
    if(trigger.isBefore && trigger.isInsert)
    {
        Handler.onBeforeInsert(trigger.new);
    }
}