/**
 * A one time job to geocode owner accounts (dealer assignment with no email)
 */
global class AccountsBulkGeocodeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

	private Integer recordLimit = null;
	
	global AccountsBulkGeocodeBatch() {
	}
	
	global AccountsBulkGeocodeBatch(Integer maxRecords) {
		this();
		this.recordLimit = maxRecords;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		if (recordLimit != null) {
			return Database.getQueryLocator([
				select id
				from Account
				where RecordType.name = 'Owner' and GeoLocation__longitude__s = null and Brand__c = 'SR'
				order by Id
				limit :recordLimit]);
		}
		return Database.getQueryLocator([
			select id
			from Account
			where RecordType.name = 'Owner' and  GeoLocation__longitude__s = null and Brand__c = 'SR'
			order by Id]);
	}

	global void execute(Database.BatchableContext BC, List<sObject> accountList){
		Set<Id> accountIds = new Set<Id>();

		for(sObject obj : accountList){
			accountIds.add(obj.Id);
		}
		
		DealerRouter.doNotSendEmail = true; 
		OwnerServices.populateOwnerGeoFields(accountIds);
	}

	global void finish(Database.BatchableContext context){
		// Get the ID of the AsyncApexJob representing this batch job
		// from Database.BatchableContext.
		// Query the AsyncApexJob object to retrieve the current job's information.
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
			TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob WHERE Id =
			:context.getJobId()];
		// Send an email to the Apex job's submitter notifying of job completion.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('AccountsBulkGeocodeBatch status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
			' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}