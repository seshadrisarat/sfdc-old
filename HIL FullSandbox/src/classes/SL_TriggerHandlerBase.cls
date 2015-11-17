/**
* @date 11/9/2014
* @description This class implements the ITriggerHandler to provide abstract/virtual methods for the interface methods
*				and so that the trigger handlers need to implement only the method that they have to. The only exception
*				is the mainEntry, which is mandatory for the trigger handlers to implement.
*/
public abstract class SL_TriggerHandlerBase implements SL_ITriggerHandler {
	protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();

	/** 
	* @date 11/9/2014
	* @description Called for the first time in the execution context. The trigger handlers need to implement
	*				this method.
	* @param SL_TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public abstract void mainEntry(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called for the subsequent times in the same execution context. The trigger handlers can chose
	*				to ignore if they don't need the reentrant feature.
	* @param SL_TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void inProgressEntry(SL_TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @date 11/9/2014
	* @description Called by batch apex. The trigger handlers can choose to ignore this method.
	* @param SL_TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void batchEntry(SL_TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @date 11/9/2014
	* @description Called by asynchronous function. The trigger handlers can choose to ignore this method.
	* @param SL_TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void futureEntry(SL_TriggerParameters tp) {
		mainEntry(tp);
	}

	/** 
	* @date 11/9/2014
	* @description Called by scheduled apex. The trigger handlers can choose to ignore this method.
	* @param SL_TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void scheduledEntry(SL_TriggerParameters tp) {
		mainEntry(tp);
	}
	
	/** 
	* @date 11/9/2014
	* @description Updates the objects, if any.
	*/
	public virtual void updateObjects() {
		if(sObjectsToUpdate.size() > 0)
			update sObjectsToUpdate.values();
	}
}