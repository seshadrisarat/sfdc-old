/**  
* \arg TriggerName      : SL_NPD_Account_Team
* \arg JIRATicket       : NPD-83
* \arg CreatedOn        : 08/26/2015
* \arg LastModifiedOn   : 
* \arg CreatededBy      : Sandeep
* \arg ModifiedBy       : 
* \arg Description      : Trigger for NPD_Account_Team object.
*/
trigger SL_NPD_Account_Team on NPD_Account_Team__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	SL_TriggerFactory.createTriggerHandler(NPD_Account_Team__c.sObjectType);
}