trigger SL_Contact on Contact (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
     
    SL_handler_Contact handler = new SL_handler_Contact(Trigger.isExecuting, Trigger.size);
    SL_handler_TickSheetValidation tickSheetValidationHandler = new SL_handler_TickSheetValidation();
     
    if(trigger.IsInsert){
        if(trigger.IsBefore){
            handler.OnBeforeInsert(Trigger.new);
            tickSheetValidationHandler.OnBeforeInsert( Trigger.new );
        }
        else{
            handler.OnAfterInsert(Trigger.newMap);
            //SL_handler_Contact.OnAfterInsertAsync(trigger.newMap.keySet());
        }
    }
     
    else if(trigger.IsUpdate){
        if(trigger.IsBefore){
            handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
            tickSheetValidationHandler.OnBeforeUpdate( Trigger.oldMap,Trigger.newMap );
        }
        else{        	
            handler.OnAfterUpdate(Trigger.oldMap,Trigger.newMap);
      //    SL_handler_Contact.OnAfterUpdateAsync(trigger.newMap.keySet());
        }
    }   
     
    else if(trigger.isDelete){
        if(trigger.IsBefore){
            handler.OnBeforeDelete(Trigger.oldMap);
        }
        else{
            handler.OnAfterDelete(Trigger.oldMap);
      //    SL_handler_Contact.OnAfterDeleteAsync(trigger.newMap.keySet());
        }
    }
     
    else{
        handler.OnUndelete(trigger.new);
    }
             
}