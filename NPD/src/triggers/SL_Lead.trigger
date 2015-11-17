/**  
* \arg TriggerName		: SL_Lead
* \arg JIRATicket       : NPD-213
* \arg CreatedOn        : 13/Oct/2015
* \arg LastModifiedOn   : 13/Oct/2015
* \arg CreatededBy      : Smriti
* \arg ModifiedBy       : Smriti
* \arg Description      : Trigger on Lead object.
*/
trigger SL_Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Lead.sObjectType);
}