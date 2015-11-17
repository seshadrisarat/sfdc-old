/*
*Trigger: SL_Case
*Description: This trigger is used to validate the Case record transfer.
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Case on Case (before update) {
	
	SL_Case_Handler Handler = new SL_Case_Handler();// This handler for MIHIN-92 functionality.
    
    //If trigger is before update then calling the handler class method.
    if(Trigger.isBefore && Trigger.isUpdate)    
    {
        Handler.onBeforeUpdate(Trigger.OldMap, Trigger.NewMap);
    }

}