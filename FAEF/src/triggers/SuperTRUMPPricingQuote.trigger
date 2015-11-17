trigger SuperTRUMPPricingQuote on IST__SuperTRUMP_Pricing_Quote__c (before insert, before update) {
    if (Trigger.isInsert){
        if (Trigger.isBefore){
            SuperTRUMPPricingQuoteTriggerImpl.beforeInsert(Trigger.new);
        }
    }
    else if (Trigger.isUpdate){
        if (Trigger.isBefore){
            SuperTRUMPPricingQuoteTriggerImpl.beforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}