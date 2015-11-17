/*
Generic trigger for the Affiliation object
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_Affiliation on Affiliation__c (before insert, before update, after insert, after update) {
	
	SL_AffiliationHandler objAffiliationHandler = new SL_AffiliationHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isAfter && Trigger.isUpdate){
        objAffiliationHandler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }
}