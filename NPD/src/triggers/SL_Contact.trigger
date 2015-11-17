/**  
* \arg TriggerName		: SL_Contact
* \arg JIRATicket       : NPD-212
* \arg CreatedOn        : 09/Oct/2015
* \arg LastModifiedOn   : 09/Oct/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : Lodhi
* \arg Description      : Trigger on Contact object.
*/
trigger SL_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(Contact.sObjectType);
}