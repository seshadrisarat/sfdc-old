trigger DealerLocatorRuleTrigger on Dealer_Locator_Rule__c (before insert, before update) {
	if (Trigger.isBefore){
		if (Trigger.isInsert || Trigger.isUpdate){
			DealerLocatorRuleServices.populateUniqueHash(Trigger.new, Trigger.oldMap);
		}
	}
}