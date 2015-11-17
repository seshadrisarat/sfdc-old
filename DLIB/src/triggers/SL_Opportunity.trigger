/**
 * \author Vladimir Dobrelya
 * \date 15 Aug 2012
 * \see https://silverline.jira.com/browse/SILVERLINE-113
 * \test SL_Test_Opportunity_Trigger_Handler
 */
trigger SL_Opportunity on Opportunity ( before insert, after insert, before update, after update, before delete, after undelete ) {

    SL_Opportunity_Trigger_Handler handler = new SL_Opportunity_Trigger_Handler( Trigger.isExecuting, Trigger.size );
     
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