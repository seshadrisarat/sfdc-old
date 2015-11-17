trigger SL_AccAffiliation on Acount_To_Account_Affiliation__c (after insert, after update, after delete, after undelete) {
    SL_Reciprocal handler = new SL_Reciprocal('From_Account__c', 'To_Account__c', 'Related_Affiliation__c', 'Acount_To_Account_Affiliation__c', 'AffSameFlds', 'Type__c', 'Inverse_Affiliation__c', 'Related_Affiliation_Text__c');
    if(Trigger.IsAfter && Trigger.IsInsert) {
        handler.OnAfterInsert(Trigger.newMap);
    } else if(Trigger.IsAfter && trigger.IsUpdate) {
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.newMap);
    } else if(Trigger.IsAfter && trigger.isDelete) {
        handler.OnAfterDelete(Trigger.oldMap);
    } else if(Trigger.IsAfter && trigger.isUnDelete) {
        handler.OnAfterUnDelete(Trigger.newMap);
    }
}