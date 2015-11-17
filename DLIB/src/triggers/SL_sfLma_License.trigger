/**
 * \author Liza Romanenko
 * \date 07 Dec 2011
 * \see http://silverline.jira.com/browse/SILVERLINE-26
 * \brief trigger process Active sfLma__License__c
 * \test SL_Test_sfLma_License_TriggerHandler
 */
trigger SL_sfLma_License on sfLma__License__c (after insert, after update, before insert/*, before update, before delete, after delete, after undelete*/ ) {
    try {
        SL_sfLma_License_TriggerHandler handler = new SL_sfLma_License_TriggerHandler( Trigger.isExecuting, Trigger.size );
         
        if ( trigger.IsInsert ) {
            if ( trigger.IsBefore ) {
                handler.OnBeforeInsert( Trigger.new );
            } else {
                handler.OnAfterInsert( Trigger.newMap );
                //SL_sfLma_License_TriggerHandler.OnAfterInsertAsync( trigger.newMap.keySet() );
            }
        } else if ( trigger.IsUpdate ) {
            if ( trigger.IsBefore ) {
                //handler.OnBeforeUpdate(Trigger.oldMap,Trigger.newMap);
            } else {   
                handler.OnAfterUpdate( Trigger.oldMap, Trigger.newMap );
          //    SL_sfLma_License_TriggerHandler.OnAfterUpdateAsync( trigger.newMap.keySet() );
            }
        } /*else if ( trigger.isDelete ) {
            if ( trigger.IsBefore ) {
                handler.OnBeforeDelete( Trigger.oldMap );
            } else {
                handler.OnAfterDelete( Trigger.oldMap );
          //    SL_sfLma_License_TriggerHandler.OnAfterDeleteAsync( trigger.newMap.keySet() );
            }
        } else{
            handler.OnUndelete(trigger.new);
        }*/
    } catch( Exception e ) {
        //throws the exception if we are running tests because we want to see it in that case and the email from exception handler will not go out.
        if ( Test.isRunningTest() ) {
            throw e;
        }
        SL_ExceptionHandler.BuildExceptionMessage( e, trigger.old, trigger.new );
    }
}