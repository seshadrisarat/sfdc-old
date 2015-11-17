/**
 * @Author		: Edward Rivera
 * @ClassName   : SL_TopicAssignment_Handler
 * @CreatedOn   : 3 Sep 2014
 * @Test		: SL_Test_TopicAssignment
 * @Description : This is the trigger for the TopicAssignment object.
 */
trigger SL_TopicAssignment on TopicAssignment (before insert, before delete, after insert, after delete){

    SL_TopicAssignment_Handler handler = new SL_TopicAssignment_Handler( Trigger.isExecuting, Trigger.size );
     
    if ( trigger.IsInsert ) {
        if ( trigger.IsBefore ) {
            handler.OnBeforeInsert( Trigger.new ); 
        } else {
            handler.OnAfterInsert( Trigger.new, Trigger.newMap );
        }
    } else {
        if ( trigger.IsBefore ) {
            handler.OnBeforeDelete( Trigger.oldMap );
        } else {
            handler.OnAfterDelete( Trigger.old, Trigger.oldMap );
    	}
    }
}