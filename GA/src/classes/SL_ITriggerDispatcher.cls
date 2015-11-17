/**
* @date 11/9/2014
* @description Defines the interface for the trigger dispatching architecture.
*/
public interface SL_ITriggerDispatcher {
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the bulk operations.
	*/
	void bulkBefore();
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the bulk operations.
	*/
	void bulkAfter();
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after completing the bulk operations.
	*/
	void andFinally();
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting inserted.
	*/
	void beforeInsert(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are updated. 
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting updated.
	*/
	void beforeUpdate(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that is getting deleted.
	*/
	void beforeDelete(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records are inserted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got inserted.
	*/
	void afterInsert(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions before the records are updated.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got updated.
	*/
	void afterUpdate(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records got deleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got deleted.
	*/
	void afterDelete(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called by the trigger framework to carry out the actions after the records are undeleted.
	* @param TriggerParameters Contains the trigger parameters which includes the records that got undeleted.
	*/
	void afterUnDelete(SL_TriggerParameters tp);
}