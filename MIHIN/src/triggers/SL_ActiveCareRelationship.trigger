/*
Generic trigger for the Active_Care_Relationship__c object
*Copyright 2014 Michigan Health Information Network Shared Services MuffiN Confidential Proprietary Restricted
*/
trigger SL_ActiveCareRelationship on Active_Care_Relationship__c (before insert, before update, after insert, after update) {
	
	SL_ActiveCareRelationshipHandler objACRHandler = new SL_ActiveCareRelationshipHandler(Trigger.isExecuting, Trigger.size);

	if(Trigger.isAfter && Trigger.isUpdate){
        objACRHandler.onAfterUpdate(Trigger.OldMap, Trigger.NewMap);
    }
}