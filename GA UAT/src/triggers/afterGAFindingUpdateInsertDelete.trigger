trigger afterGAFindingUpdateInsertDelete on GA_Network_Finding__c (after update, after insert, after delete) {   
    GANetworkFindingManagement.afterGAFindingUpdateInsertDelete(Trigger.New, Trigger.oldMap, Trigger.isInsert, Trigger.isDelete);
}