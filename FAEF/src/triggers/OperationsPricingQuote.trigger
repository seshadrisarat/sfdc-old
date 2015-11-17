trigger OperationsPricingQuote on Operations_Pricing_Quote__c (before update, after update) {
    if (Trigger.isUpdate){
        if (Trigger.isBefore){
            OperationsPricingQuoteTriggerImpl.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
        else if (Trigger.isAfter){
            OperationsPricingQuoteTriggerImpl.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}