/**
 * \author Vladimir Dobrelya
 * \date Feb 17, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 */
trigger SL_CO_Line_Item on CO_Line_Item__c ( after insert, before update, before delete ) {

    SL_CO_Line_Item_Handler handler = new SL_CO_Line_Item_Handler( Trigger.isExecuting, Trigger.size );
     
    if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            //handler.OnBeforeInsert( Trigger.new ); 
        } else {
            handler.OnAfterInsert( Trigger.newMap );
        }
    } else if ( trigger.IsUpdate ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeUpdate( Trigger.oldMap, Trigger.newMap );
        } else {    
            //handler.OnAfterUpdate( Trigger.oldMap, Trigger.newMap );
        }
    } else if ( trigger.isDelete ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeDelete( Trigger.oldMap );
        } else {
            //handler.OnAfterDelete( Trigger.oldMap );
        }
    } else {
        //handler.OnUndelete( trigger.new );
    }
}