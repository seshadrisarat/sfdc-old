/**  
* \arg ClassName        : SL_Unit
* \arg JIRATicket       : HCRP-38
* \arg CreatedOn        : 28/July/2015
* \arg LastModifiedOn   : -
* \arg CreatededBy      : Pankaj Ganwani
* \arg ModifiedBy       : -
* \arg Description      : This trigger is used to update the Replaced__c field on corresponding previous Lease record of updated Unit record.
*/
trigger SL_Unit on Unit__c (after update) 
{
	if(trigger.isAfter && trigger.isUpdate)
	{
		SL_UnitHandler handler = new SL_UnitHandler();
		handler.onAfterUpdate (trigger.newmap, trigger.oldmap); 
	}
}