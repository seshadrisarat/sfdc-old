trigger trCase on Case (after update) {
    if(Trigger.isUpdate && Trigger.isAfter) {
        vf003_Case.tr_After_Update(Trigger.New, Trigger.Old, Trigger.newMap, Trigger.oldMap);
    }
}