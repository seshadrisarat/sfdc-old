/**
* @date 11/9/2014
* @description This class implements the ITriggerDispatcher and acts as an adapter to avoid implementing all the 
*				ITriggerDispatcher methods.
*/
public virtual class SL_TriggerDispatcherBase implements SL_ITriggerDispatcher { 
	
	private static SL_ITriggerHandler beforeInserthandler;
	private static SL_ITriggerHandler beforeUpdatehandler;
	private static SL_ITriggerHandler beforeDeleteHandler;
	private static SL_ITriggerHandler afterInserthandler;
	private static SL_ITriggerHandler afterUpdatehandler;
	private static SL_ITriggerHandler afterDeleteHandler;
	private static SL_ITriggerHandler afterUndeleteHandler;

    private String sObjectType;

    public SL_TriggerDispatcherBase(String sObjectType){
        this.sObjectType=sObjectType;
    }
	
    /** 
	* @date 11/9/2014
	* @description This method is called prior to execution of a before trigger event. If you want 
	*				to load any lookup data or cache the data, then this is the place that you need 
	*				to put your code. 
	*/
    public virtual void bulkBefore() {}

    /** 
	* @date 11/9/2014
	* @description This method is called prior to execution of an after trigger event. 
	*/
    public virtual void bulkAfter() {}

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be inserted during a BEFORE trigger.
	*/
    public virtual void beforeInsert(SL_TriggerParameters tp) {}

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be updated during a BEFORE trigger.
	*/
    public virtual void beforeUpdate(SL_TriggerParameters tp) {}

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be deleted during a BEFORE trigger.
	*/
    public virtual void beforeDelete(SL_TriggerParameters tp) {}

    /** 
	* @date 11/9/2014
	* @description This method is called for records inserted during an AFTER trigger. Always put field validation 
	*				in the 'After' methods in case another trigger has modified any values. The record is 'read only' 
	*				at this point.
	*/
    public virtual void afterInsert(SL_TriggerParameters tp) {} 

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record updated during an AFTER trigger.
	*/
    public virtual void afterUpdate(SL_TriggerParameters tp) {}

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record deleted during an AFTER trigger.
	*/
    public virtual void afterDelete(SL_TriggerParameters tp) {}
    
    /** 
	* @date 11/9/2014
	* @description This method is called prior to execution of a AFTER UNDELETE trigger. 
	*/
    public virtual void afterUnDelete(SL_TriggerParameters tp) {}
    
    public virtual void andFinally() {}
    
    /** 
	* @date 11/9/2014
	* @description Called by the event handlers. If this is the first call in the context, then this method will create a new 
	*				instance of the appropriate handler and execute the mainEntry method. If there is an existing call runing 
	*				on the same context, then this method will use the existing handler instance created by the original call
	*				and execute the inProgressEntry method.
	* @param ITriggerHandler The trigger handler instance. The dispatcher need to pass an instance of the trigger handler, such
	*							as AccountAfterInsertTriggerHandler if this is the first call in a given context. If it is retry,
	*							then the dispatcher will need to pass null.
	* @param SL_TriggerParameters The trigger parameters passed by the framework.
	* @param SL_TriggerParameters.TriggerEvent The trigger event.
	*/
   	protected void execute(SL_ITriggerHandler handlerInstance, SL_TriggerParameters tp, SL_TriggerParameters.TriggerEvent tEvent) {
    	String context='';
        if(handlerInstance != null) {
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeInsert){
    			beforeInsertHandler = handlerInstance;
                context='BeforeInsert';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeUpdate){
    			beforeUpdateHandler = handlerInstance;
                context='BeforeUpdate';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeDelete){
    			beforeDeleteHandler = handlerInstance;
                context='BeforeDelete';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterInsert){
    			afterInsertHandler = handlerInstance;
                context='AfterInsert';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterUpdate){
    			afterUpdateHandler = handlerInstance;
                context='AfterUpdate';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterDelete){
    			afterDeleteHandler = handlerInstance;
                context='AfterDelete';
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterUnDelete){
    			afterUndeleteHandler = handlerInstance;
                context='AfterUndelete';
            }
    		else {
                SL_DiagnosticsInstrumentation.Push(sObjectType+context+'TriggerHandler.mainEntry');
    			handlerInstance.mainEntry(tp);
                SL_DiagnosticsInstrumentation.Pop();
    		}
    		handlerInstance.updateObjects();
    	}
    	else {
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeInsert){
                beforeInsertHandler.inProgressEntry(tp);
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeUpdate){
                beforeUpdateHandler.inProgressEntry(tp);
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.beforeDelete){
                beforeDeleteHandler.inProgressEntry(tp);
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterInsert){
                afterInsertHandler.inProgressEntry(tp);
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterUpdate){
                context='AfterUpdate';
                SL_DiagnosticsInstrumentation.Push(sObjectType+context+'TriggerHandler.inProgressEntry');
    			afterUpdateHandler.inProgressEntry(tp);
                SL_DiagnosticsInstrumentation.Pop();
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterDelete){
                afterDeleteHandler.inProgressEntry(tp);
            }
    		if(tEvent == SL_TriggerParameters.TriggerEvent.afterUnDelete){
                afterUndeleteHandler.inProgressEntry(tp);
            }
    	}
    }
}