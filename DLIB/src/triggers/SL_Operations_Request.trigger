/**
 * @Author		: Edward Rivera
 * @ClassName   : SL_Operations_Request
 * @CreatedOn   : 20 Oct 2014
 * @Test		: SL_Test_Operations_Request
 * @Description : This is the trigger for the TopicAssignment object.
 */
trigger SL_Operations_Request on Operations_Request__c (before insert, before delete, before update, after insert, after delete, after update, after undelete){

    SL_Operations_Request_Handler handler = new  SL_Operations_Request_Handler( Trigger.isExecuting, Trigger.size );
     
    if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeInsert( Trigger.new ); 
        } else {
            //handler.OnAfterInsert( Trigger.new, Trigger.newMap );
        }
    } else if ( trigger.isDelete) {
        if ( trigger.IsBefore ) {
        //    handler.OnBeforeDelete( Trigger.oldMap );
        } else {
        //    handler.OnAfterDelete( Trigger.old, Trigger.oldMap );
    	}
    } else if (trigger.isUpdate){
    	if ( trigger.IsBefore ) {
            //handler.OnBeforeUpdate( Trigger.newMap, Trigger.oldMap );
        } else {
            handler.OnAfterUpdate( Trigger.newMap, Trigger.oldMap );
    	}
    } else {
        //handler.OnUndelete( Trigger.newMap );
    }

}