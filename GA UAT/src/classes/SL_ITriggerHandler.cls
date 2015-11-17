/**
* @date 11/9/2014
* @description Defines the interface for trigger handlers. Logic for the first time events are placed under the mainEntry 
*				method and the logic for the subsequent events raised on the same transaction (reentrant) are placed under 
*				the inProgressEntry method.
*/
public interface SL_ITriggerHandler {
	/** 
	* @date 11/9/2014
	* @description Called for the first time in the execution context.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void mainEntry(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Called for the subsequent times in the same execution context.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void inProgressEntry(SL_TriggerParameters tp);

	/** 
	* @date 11/9/2014
	* @description Called by batch apex
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void batchEntry(SL_TriggerParameters tp);

	/** 
	* @date 11/9/2014
	* @description Called by asynchronous function
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void futureEntry(SL_TriggerParameters tp);

	/** 
	* @date 11/9/2014
	* @description Called by scheduled apex
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	void scheduledEntry(SL_TriggerParameters tp);
	
	/** 
	* @date 11/9/2014
	* @description Updates the objects, if any.
	*/
	void updateObjects();
}