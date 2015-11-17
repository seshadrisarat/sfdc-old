/*
Generic trigger for the Affiliation object
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_OrganizationAffiliation on Organization_Affiliation__c (before insert, before update, after insert, after update) {
	
	SL_OrganizationAffiliationHandler objAffiliationHandler = new SL_OrganizationAffiliationHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isAfter && Trigger.isUpdate){
        objAffiliationHandler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }
}