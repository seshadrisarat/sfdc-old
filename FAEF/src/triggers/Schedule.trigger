trigger Schedule on Schedule__c (before update) {
    ScheduleTriggerImpl.beforeUpdate(Trigger.newMap, Trigger.oldMap);
}