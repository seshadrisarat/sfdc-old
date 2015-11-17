trigger SL_Event on Event (after insert, after update, after delete) {
    SL_ActivityHandler handler = new SL_ActivityHandler();
    if (Trigger.isAfter){
        if (Trigger.isInsert){
            handler.onAfterInsert(Trigger.newMap);
        }
        else if (Trigger.isUpdate){
            handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
        else {
            handler.onAfterDelete(Trigger.oldMap);
        }
    }
}