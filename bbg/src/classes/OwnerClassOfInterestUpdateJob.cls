/**
 * A job to update owner accounts boat class of interest based on previously owned boats.
 */
global class OwnerClassOfInterestUpdateJob  implements Database.Batchable<sObject> {

	private Integer recordLimit = 10;
	private String brandCode = 'SR';
	
	global OwnerClassOfInterestUpdateJob(String brandCode, Integer maxRecords) {
		this.recordLimit = maxRecords;
		this.brandCode = brandCode;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
			return Database.getQueryLocator([
				Select id,
					(Select HIN_Number__r.Boat_Class__c, Purchase_Date__c, Status__c From Owner_Boat_Relationships__r order by Purchase_Date__c desc)
				From Account a
				where recordtype.name = 'Owner'
					and brand__c = :brandCode 
					and Boat_Category_of_Interest__pc = null
				order by id
				limit :recordLimit]);
	}
	
	
	global void execute(Database.BatchableContext BC, List<sObject> ownerList){
		BoatServices.disableTriggerProcessing = true;
		List<Account> accountsToUpdate = new List<Account>();
		
		for (sObject sobj : ownerList) {
			Account owner = (Account)sobj;
			String boatClass = getBoatClassOfInterest(owner);
			system.debug('Found boatClass: ' + boatClass + ' for owner ' + owner.id);
			if (boatClass != null) {
				owner.Boat_Category_of_Interest__pc = boatClass;
				accountsToUpdate.add(owner);
			}
			else {
				system.debug('Unable to find boat class for owner: ' + owner.id);
			}
		}
		
		if (!accountsToUpdate.isEmpty()) {
			update accountsToUpdate;
		}
	}
	
	/**
	 * Gets the boat class of interest for the user based on the most recently purchased boat.
	 * Expects the owner_boat_relationships to be sorted by most recently purchased first.
	 * It will return the first active owner boat relationship to determine boat class.
	 * If an active owner boat relationship is not found then it will use the most recently
	 * purchased inactive boat's class.
	 */
	private String getBoatClassOfInterest(Account owner) {
		String mostRecentInactiveBoatClass = null;
		for (Owner_Boat_Relationship__c obr : owner.owner_boat_relationships__r) {
			if (obr.status__c == 'Active') {
				return obr.HIN_Number__r.Boat_Class__c;
			}
			// else this is an Inactive OBR --- set the mostRecentInactiveBoatClass if not already set
			else if (mostRecentInactiveBoatClass == null) {
				mostRecentInactiveBoatClass = obr.HIN_Number__r.Boat_Class__c;
			}
		}
		// no active OBR found -- return the mostRecentInactiveBoatClass
		return mostRecentInactiveBoatClass;
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
		mail.setSubject('OwnerClassOfInterestUpdateJob status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
			' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
	
}