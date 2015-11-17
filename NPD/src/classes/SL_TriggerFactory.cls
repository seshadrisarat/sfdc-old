/**
* @date 11/9/2014
* @description This factory creates the correct handler and dispatches the trigger event(s) to the appropriate 
*				event handler(s). The handlers are automatically created using the Type API, hence handler 
*				registration is not required for each handler.
*/
public with sharing class SL_TriggerFactory
{

    public static Boolean FakeException = false;
    public static Boolean KillSwitchEnabled = SL_AppConfigSupport.KillSwitchEnabled;
    public static String KillList = SL_AppConfigSupport.KillList;

    /** 
	* @date 11/9/2014
	* @description Creates the appropriate handler and dispatches the trigger event to the handler's event handler method.
	* @param Schema.sObjectType Object type to process (SObject.sObjectType)
	*/
    public static void createTriggerHandler(Schema.sObjectType soType){
        String soTypeName = soType.getDescribe().getName();
        Set<String> deactivatedObjects = new Set<String>();
        if (KillList != null && KillList != ''){
            deactivatedObjects = new Set<String>(KillList.split('\n'));
        }
        Set<String> deactivatedObjectsNoWhitespace = new Set<String>();
        for (String s: deactivatedObjects){
            deactivatedObjectsNoWhitespace.add(s.deleteWhitespace());
        }

        
        if (!(KillSwitchEnabled || (KillList != null ? deactivatedObjectsNoWhitespace.contains(soTypeName) : false))){
            // Initial Push to Diagnostic Log
            String beforeOrAfter = 'before';
            if (Trigger.isAfter)
                beforeOrAfter = 'after';
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
            SL_DiagnosticsInstrumentation.Push(beforeOrAfter + dmlState + ' Trigger for ' + soTypeName + ' Object');
            try{
                SL_ITriggerHandler handler = getTriggerHandler(soType);
                if (handler == null || FakeException)
                    throw new SL_FrameworkException('No Trigger handler registered for Object Type: ' + soType);
                execute(handler, soTypeName, beforeOrAfter+dmlState);
                // Final Pop from Diagnostic Log
                SL_DiagnosticsInstrumentation.Pop();
            }
            catch(Exception ex){
                SL_DiagnosticsInstrumentation.DebugException(ex);
                SL_DiagnosticsInstrumentation.PopAll();
                if (!SL_AppConfigSupport.DiagnosticsEnabled && SL_AppConfigSupport.ThrowExceptions){
                    throw ex;
                }
            }
        }
    }

    /** 
    * @date 11/9/2014
    * @description Dispatches to the handler's event handlers.
    * @param ITriggerhandler A Trigger handler that dispatches to the appropriate handlers
    */ 
    private static void execute(SL_ITriggerHandler handler, String soTypeName, String context){
        SL_TriggerParameters tp = new SL_TriggerParameters(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap,
                                    Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, 
                                    Trigger.isInsert, Trigger.isUpdate, Trigger.isUnDelete, Trigger.isExecuting);
        // Handle before trigger events
        if (Trigger.isBefore) {
            SL_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.bulkBefore');
            handler.bulkBefore();
            SL_DiagnosticsInstrumentation.Pop();
        }
        // Handle after trigger events
        else {
            SL_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.bulkAfter');
            handler.bulkAfter();
            SL_DiagnosticsInstrumentation.Pop();
        }

        handler.execute(tp, context);

        SL_DiagnosticsInstrumentation.Push(soTypeName + 'Triggerhandler.andFinally');
        handler.andFinally();
        SL_DiagnosticsInstrumentation.Pop();
    } 

    /** 
    * @date 11/9/2014
    * @description Gets the appropriate handler based on the SObject. It constructs the instance of the handler
    *               dynamically using the Type API. The name of the handler has to follow this format:
    *               <ObjectName>Triggerhandler. For e.g. for the Account object, the handler has to be named
    *               as AccountTriggerhandler. For the custom object Custom__c, the name should be CustomTriggerhandler.
    * @param Schema.sObjectType Object type to create the handler
    * @return SL_ITriggerhandler A trigger handler if one exists, otherwise null.
    */
    private static SL_ITriggerHandler getTriggerHandler(Schema.sObjectType soType){
        String originalTypeName = soType.getDescribe().getName();
        String handlerTypeName = null;
        String handlerName;
        if (originalTypeName.toLowerCase().endsWith('__c')) {
            Integer index = originalTypeName.toLowerCase().indexOf('__c');
            handlerName = originalTypeName.substring(0, index);
        }
        else {
            handlerName = originalTypeName;
        }
        if (handlerName.length() > 23){
            handlerName = handlerName.substring(0,23);
        }
        handlerTypeName = 'SL_' + handlerName + 'TriggerHandler';    

        Type obType = Type.forName(handlerTypeName);
        SL_ITriggerHandler handler = (obType == null) ? null : (SL_ITriggerHandler)obType.newInstance();
        return handler;
    }
}