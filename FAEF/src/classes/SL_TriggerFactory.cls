/**
* @author Scott Covert
* @date 11/9/2014
* @description This factory creates the correct dispatcher and dispatches the trigger event(s) to the appropriate 
*				event handler(s). The dispatchers are automatically created using the Type API, hence dispatcher 
*				registration is not required for each dispatchers.
*/
public with sharing class SL_TriggerFactory
{

    public static Boolean FakeException = false;
    public static Boolean KillSwitchEnabled = SL_AppConfigSupport.KillSwitchEnabled;

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Creates the appropriate dispatcher and dispatches the trigger event to the dispatcher's event handler method.
	* @param Schema.sObjectType Object type to process (SObject.sObjectType)
	*/
    public static void createTriggerDispatcher(Schema.sObjectType soType)
    {
        if (!KillSwitchEnabled){
            // Initial Push to Diagnostic Log
            String beforeOrAfter = 'Before ';
            if (Trigger.isAfter)
                beforeOrAfter = 'After ';
            String dmlState = 'Insert';
            if (Trigger.isUpdate){
                dmlState = 'Update';
            }
            else if (Trigger.isDelete){
                dmlState = 'Delete';
            }
            else if (Trigger.isUndelete){
                dmlState = 'Undelete';
            }
            String soTypeName = soType.getDescribe().getName();
            SL_DiagnosticsInstrumentation.Push(beforeOrAfter + dmlState + ' Trigger for ' + soTypeName + ' Object');
            try{
                SL_ITriggerDispatcher dispatcher = getTriggerDispatcher(soType);
                if (dispatcher == null || FakeException)
                    throw new SL_CustomException('No Trigger dispatcher registered for Object Type: ' + soType);
                execute(dispatcher,soTypeName);
                // Final Pop from Diagnostic Log
                SL_DiagnosticsInstrumentation.Pop();
            }
            catch(Exception ex){
                SL_DiagnosticsInstrumentation.DebugException(ex);
                SL_DiagnosticsInstrumentation.PopAll();
            }
        }
    }

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Dispatches to the dispatcher's event handlers.
	* @param ITriggerDispatcher A Trigger dispatcher that dispatches to the appropriate handlers
	*/ 
    private static void execute(SL_ITriggerDispatcher dispatcher, String soTypeName)
    {
    	SL_TriggerParameters tp = new SL_TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
									Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, 
									Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
        // Handle before trigger events
        if (Trigger.isBefore) {
           SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.bulkBefore');
            dispatcher.bulkBefore();
           SL_DiagnosticsInstrumentation.Pop();
            if (Trigger.isDelete){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeDelete');
                dispatcher.beforeDelete(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isInsert){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeInsert');
                dispatcher.beforeInsert(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUpdate){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.beforeUpdate');
                dispatcher.beforeUpdate(tp);      
                SL_DiagnosticsInstrumentation.Pop();   
            }
        }
        else	// Handle after trigger events
        {
            SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.bulkAfter');
            dispatcher.bulkAfter();
            SL_DiagnosticsInstrumentation.Pop();
            if (Trigger.isDelete){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterDelete');
                dispatcher.afterDelete(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isInsert){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterInsert');
                dispatcher.afterInsert(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUpdate){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterUpdate');
                dispatcher.afterUpdate(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
            else if (Trigger.isUnDelete){
                SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.afterUnDelete');
                dispatcher.afterUnDelete(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
        }
        SL_DiagnosticsInstrumentation.Push(soTypeName + 'TriggerDispatcher.andFinally');
        dispatcher.andFinally();
        SL_DiagnosticsInstrumentation.Pop();
    } 

    /** 
	* @author Scott Covert
	* @date 11/9/2014
	* @description Gets the appropriate dispatcher based on the SObject. It constructs the instance of the dispatcher
	*				dynamically using the Type API. The name of the dispatcher has to follow this format:
	*				<ObjectName>TriggerDispatcher. For e.g. for the Account object, the dispatcher has to be named
	*				as AccountTriggerDispatcher. For the custom object Custom__c, the name should be CustomTriggerDispatcher.
	* @param Schema.sObjectType Object type to create the dispatcher
	* @return SL_ITriggerDispatcher A trigger dispatcher if one exists, otherwise null.
	*/
    private static SL_ITriggerDispatcher getTriggerDispatcher(Schema.sObjectType soType)
    {
    	String originalTypeName = soType.getDescribe().getName();
    	String dispatcherTypeName = null;
    	if (originalTypeName.toLowerCase().endsWith('__c')) {
    		Integer index = originalTypeName.toLowerCase().indexOf('__c');
            // this is where we'd add the SL_
    		dispatcherTypeName = 'SL_' + originalTypeName.substring(0, index) + 'TriggerDispatcher';
    	}
    	else
            // and here
    		dispatcherTypeName = 'SL_' + originalTypeName + 'TriggerDispatcher';

		Type obType = Type.forName(dispatcherTypeName);
		SL_ITriggerDispatcher dispatcher = (obType == null) ? null : (SL_ITriggerDispatcher)obType.newInstance();
    	return dispatcher;
    }
}