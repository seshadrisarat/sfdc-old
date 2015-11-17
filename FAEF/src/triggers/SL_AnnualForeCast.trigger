/*Trigger on insert of Note
* Trigger Name  : SL_AnnualForeCast 
* JIRA Ticket   : FAEF-32
* Created on    : 11/Sep/2014
* Created by    : Harsh
* Description   : Implement a trigger on insert, Update and undelete of AnnualForeCast
*/
trigger SL_AnnualForeCast on Annual_Forecast__c (after undelete, before insert, before update) {
	
	//Handler class for calling functions based on event
	SL_AnnualForeCast_Handler objForeCastHandler = new SL_AnnualForeCast_Handler();
	
	// calling functions of handler class on Before events of AnnualForecast records
	if(trigger.isBefore)
	{
		// calling functions of handler class on Insert of AnnualForecast records
		if(trigger.isInsert)
			objForeCastHandler.onBeforeInsert(trigger.new);

		// calling functions of handler class on upadte of AnnualForecast records 
		if(trigger.isUpdate)
			objForeCastHandler.onBeforeUpdate(trigger.oldMap, trigger.newMap);
	} 
	
	if(trigger.isAfter && trigger.isUnDelete)
	{
		// calling functions of handler class on after undelete of AnnualForecast records
		objForeCastHandler.onAfterUndelete(Trigger.newMap);  
	} 
}