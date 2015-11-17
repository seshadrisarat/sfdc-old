/**
 * \author Vladimir Dobrelya
 * \date Feb 14, 2014
 * \see https://silverline.jira.com/browse/SLFF-23
 * \test 
 */
trigger SL_Change_Order on Change_Order__c ( before insert, after insert, before update, after update, before delete, after undelete ) {

    SL_Change_Order_Handler handler = new SL_Change_Order_Handler( Trigger.isExecuting, Trigger.size );
    
    if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeInsert( Trigger.new ); 
        } else {
            handler.OnAfterInsert( Trigger.newMap );
        }
    } else if ( trigger.IsUpdate ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeUpdate( Trigger.oldMap, Trigger.newMap );
        } else {    
            handler.OnAfterUpdate( Trigger.oldMap, Trigger.newMap );
        }
    } else if ( trigger.isDelete ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeDelete( Trigger.oldMap );
        } else {
            //handler.OnAfterDelete( Trigger.oldMap );
        }
    } else {
        handler.OnUndelete( trigger.new );
    }
}