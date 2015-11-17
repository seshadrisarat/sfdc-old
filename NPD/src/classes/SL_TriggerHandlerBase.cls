/**
* @date 11/9/2014
* @description This class implements the ITriggerDispatcher and acts as an adapter to avoid implementing all the 
*				ITriggerDispatcher methods.
*/
public abstract class SL_TriggerHandlerBase implements SL_ITriggerHandler { 
	
	private static Map<String, Boolean> isProcessing = new Map<String, Boolean>();

	private String sObjectTypeName;

    public SL_TriggerHandlerBase(){
    	if (Trigger.old != null){
    		sObjectTypeName = Trigger.old[0].getSObjectType().getDescribe().getName();
    	}
    	else {
    		sObjectTypeName = Trigger.new[0].getSObjectType().getDescribe().getName();
    	}
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
    public abstract void beforeInsert(List<SObject> newList);

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be updated during a BEFORE trigger.
	*/
    public abstract void beforeUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap);

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be deleted during a BEFORE trigger.
	*/
    public abstract void beforeDelete(Map<Id, SObject> oldMap);

    /** 
	* @date 11/9/2014
	* @description This method is called for records inserted during an AFTER trigger. Always put field validation 
	*				in the 'After' methods in case another trigger has modified any values. The record is 'read only' 
	*				at this point.
	*/
    public abstract void afterInsert(Map<Id, SObject> newMap); 

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record updated during an AFTER trigger.
	*/
    public abstract void afterUpdate(Map<Id, SObject> oldMap, Map<Id, SObject> newMap);

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record deleted during an AFTER trigger.
	*/
    public abstract void afterDelete(Map<Id, SObject> oldMap);
    
    /** 
	* @date 11/9/2014
	* @description This method is called prior to execution of a AFTER UNDELETE trigger. 
	*/
    public abstract void afterUnDelete(Map<Id, SObject> newMap);
    
    /** 
	* @date 11/9/2014
	* @description This method is called for records to be inserted during a BEFORE trigger.
	*/
    public virtual void beforeInsertRecursive(List<SObject> newList) { beforeInsert(newList); }

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be updated during a BEFORE trigger.
	*/
    public virtual void beforeUpdateRecursive(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) { beforeUpdate(oldMap, newMap); }

    /** 
	* @date 11/9/2014
	* @description This method is called for records to be deleted during a BEFORE trigger.
	*/
    public virtual void beforeDeleteRecursive(Map<Id, SObject> oldMap) { beforeDelete(oldMap); }

    /** 
	* @date 11/9/2014
	* @description This method is called for records inserted during an AFTER trigger. Always put field validation 
	*				in the 'After' methods in case another trigger has modified any values. The record is 'read only' 
	*				at this point.
	*/
    public virtual void afterInsertRecursive(Map<Id, SObject> newMap) { afterInsert(newMap); } 

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record updated during an AFTER trigger.
	*/
    public virtual void afterUpdateRecursive(Map<Id, SObject> oldMap, Map<Id, SObject> newMap) { afterUpdate(oldMap, newMap); }

    /** 
	* @date 11/9/2014
	* @description This method is called iteratively for each record deleted during an AFTER trigger.
	*/
    public virtual void afterDeleteRecursive(Map<Id, SObject> oldMap) { afterDelete (oldMap); }
    
    /** 
	* @date 11/9/2014
	* @description This method is called prior to execution of a AFTER UNDELETE trigger. 
	*/
    public virtual void afterUnDeleteRecursive(Map<Id, SObject> newMap) { afterDelete (newMap); }

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
   	public void execute(SL_TriggerParameters tp, String context) {
   		Boolean inProgress = isProcessing.get(sObjectTypeName+context);
   		// Standard Entry
    	if(inProgress != true) {
			isProcessing.put(sObjectTypeName+context, true);
			SL_DiagnosticsInstrumentation.Push(sObjectTypeName + 'TriggerDispatcher.'+context);
			if (context=='beforeInsert'){
				beforeInsert(tp.newList);
			}
			else if (context=='beforeUpdate'){
				beforeUpdate(tp.oldMap, tp.newMap);
			}
			else if (context=='beforeDelete'){
				beforeDelete(tp.oldMap);
			}
			else if (context=='afterInsert'){
				afterInsert(tp.newMap);
			}
			else if (context=='afterUpdate'){
				afterUpdate(tp.oldMap, tp.newMap);
			}
			else if (context=='afterDelete'){
				afterDelete(tp.oldMap);
			}
			else if (context=='afterUndelete'){
				afterUndelete(tp.newMap);
			}
			SL_DiagnosticsInstrumentation.Pop();
			isProcessing.put(sObjectTypeName+context, false);
		}
		// Recursive Entry
		else {
			SL_DiagnosticsInstrumentation.Push(sObjectTypeName + 'TriggerDispatcher.'+context+'Recursion');
			if (context=='beforeInsert'){
				beforeInsertRecursive(tp.newList);
			}
			else if (context=='beforeUpdate'){
				beforeUpdateRecursive(tp.oldMap, tp.newMap);
			}
			else if (context=='beforeDelete'){
				beforeDeleteRecursive(tp.oldMap);
			}
			else if (context=='afterInsert'){
				afterInsertRecursive(tp.newMap);
			}
			else if (context=='afterUpdate'){
				afterUpdateRecursive(tp.oldMap, tp.newMap);
			}
			else if (context=='afterDelete'){
				afterDeleteRecursive(tp.oldMap);
			}
			else if (context=='afterUndelete'){
				afterUndeleteRecursive(tp.newMap);
			}	
			SL_DiagnosticsInstrumentation.Pop();
		}
    }
}