/*
Developer   : Poundarik, Shruti
Company     : Bluewolf LLC

Modified By : Angela
Date : 08/25/2012
changes : call method populateLeadGeoFields on insert and update

Modified By : Ruivo, Tiago 
Date : 12/12/2013
Changes : Added funtionality to update consumer action's boat_owner__c when lead is converted
          Call methods after update
*/

trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
	
	if (LeadServices.disableTriggerProcessing || 
		LeadSetBatchFlagsJob.isBulkLeadBulkUpdate || 
		LeadResetBatchFlagsJob.isBulkLeadBulkUpdate ||
		UserUtil.isImportingLeads()) {
		system.debug('Disabling lead trigger handling'); 
		return;
  	} 
  	
  	new LeadTriggerHandler().run();
}