trigger trIntegration_Log on Integration_Log__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore) {
        vf002_Integration_Log.tr_Before_Insert(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
    }
}