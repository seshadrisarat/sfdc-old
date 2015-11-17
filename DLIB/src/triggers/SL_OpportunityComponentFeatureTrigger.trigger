trigger SL_OpportunityComponentFeatureTrigger on Opportunity_Component_Feature__c (after insert, after update, after delete) {

	SL_OpptyComponentFeatureHandler handler = new SL_OpptyComponentFeatureHandler();

	if(trigger.isBefore) {
		
	} else if (trigger.isAfter) {
		if(trigger.isInsert) {
			handler.afterInsert( trigger.new);
		} else if(trigger.isUpdate){
			handler.afterUpdate(trigger.old, trigger.new);
		} else if(trigger.isDelete) {
			handler.afterDelete(trigger.old);
		}
	}


}