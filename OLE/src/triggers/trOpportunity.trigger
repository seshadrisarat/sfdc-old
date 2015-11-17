trigger trOpportunity on Opportunity (before update, before insert) {
    if(Trigger.isUpdate && Trigger.isBefore) {
        vf004_Opportunity.tr_Before_Update(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
    } else if(Trigger.isInsert && Trigger.isBefore) {
        vf004_Opportunity.tr_Before_Insert(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
    }
}