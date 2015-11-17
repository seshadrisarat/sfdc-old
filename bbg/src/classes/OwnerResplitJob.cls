global class OwnerResplitJob implements Database.Batchable<sObject>, Database.Stateful {

	private Integer recordLimit = 10;
	
	
	global OwnerResplitJob(Integer maxRecords) {
		this.recordLimit = maxRecords;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
			return Database.getQueryLocator([
				Select id, brand__c,
					(Select owner__r.id,
						hin_number__r.brand_del__C,
						HIN_Number__c,
						Purchase_Date__c,
						Status__c,
						Entry_Source__c,
						Customer_Wants_Mailings__c,
						NCOA_Address_Status__c,
						NCOA_Status__c,
						NCOA_Validation_Date__c,
						New_or_Used__c,
						SROC_Cancellation_Date__c,
						SROC_Enrollment_Level__c,
						SROC_Enrollment_Status__c,
						SROC_Join_Date__c,
						SROC_Member_ID__c,
						SROC_Membership_Status__c,
						SROC_Ownership_Status__c,
						SROC_Points_Total__c,
						SROC_Purchased_Dealer_Name__c,
						SROC_Purchased_Dealer_Number__c,
						SROC_Purchase_Date__c,
						SROC_Sales_Total__c,
						SROC_Welcome_Kit_Status__c,
						SROC_Comments__c,
						Opt_Out_of_Sea_Ray_Living__c,
						Email_Opt_in__c
						From Owner_Boat_Relationships__r order by Purchase_Date__c desc)
				From Account a
				where recordtype.name = 'Owner'
					and Number_of_Boat_Relationships__c > 1
				order by id
				limit :recordLimit]);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> ownerList){
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		AccountServices.disableTriggerProcessing = true;
		BoatServices.disableTriggerProcessing = true;
		
		Set<Id> accountsToSplit = new Set<Id>();
		Map<Id, Account> accountIdToAccountWithObrMap = new Map<Id, Account>();
		
		// determine which accounts will be cloned
		for (sObject sobj : ownerList) {
			Account owner = (Account)sobj;
			if (ownsMultipleBrands(owner)) {
				accountsToSplit.add(owner.id);
				accountIdToAccountWithObrMap.put(owner.id, owner);
			}
		}
		
		if (accountsToSplit.isEmpty()) {
			system.debug('No accounts to split in batch');
			return;
		}
		
		// get the full Salesforce object for the accounts that will be cloned
		String soql = getCreatableFieldsSOQL('Account', 'Id in :accountsToSplit');
		List<Account> accountsToClone = Database.query(soql);
		Map<Id, Account> accountIdToFullObjectMap = new Map<Id, Account>();
		for (Account full : accountsToClone) {
			accountIdToFullObjectMap.put(full.id, full);
		}
		
		
		// create de clones senior 
		Map<Id, Map<String, Account>> brandCodeToCloneMap = new Map<Id, Map<String, Account>>();
		for (Id ownerToSplitId : accountsToSplit) {
			Account full = accountIdToFullObjectMap.get(ownerToSplitId);
			Account accountWithObrs = accountIdToAccountWithObrMap.get(ownerToSplitId);
			for (Owner_Boat_Relationship__c obr : accountWithObrs.Owner_Boat_Relationships__r) {
				if (!brandCodeToCloneMap.containsKey(ownerToSplitId)) {
					brandCodeToCloneMap.put(ownerToSplitId, new Map<String, Account>());
				}
				Map<String, Account> brandToCloneMap = brandCodeToCloneMap.get(ownerToSplitId);
				String brand = obr.hin_number__r.brand_del__C;
				
				// create a clone if the brand of the obr isn't the brand of the owner and a clone hasn't already been created
				if (brand != full.brand__c && !brandToCloneMap.containsKey(brand)) {
					Account brandClone = full.clone(false,true);
					brandClone.brand__c = brand;
					brandToCloneMap.put(brand, brandClone);
				}
			}
		}
		
		// insert the new accounts so we'll have an id for the new OBR to reference
		List<Account> newClonedAccounts = new List<Account>();
		for (Map<String, Account> brandAccountMap : brandCodeToCloneMap.values()) {
			for (Account a : brandAccountMap.values()) {
				newClonedAccounts.add(a);
			}
		}
		if (!newClonedAccounts.isEmpty()) {
			insert newClonedAccounts;
		}
		
		// now go back and clean up the OBRs...
		List<Owner_Boat_Relationship__c> obrsToInsert = new List<Owner_Boat_Relationship__c>();
		List<Owner_Boat_Relationship__c> obrsToDelete = new List<Owner_Boat_Relationship__c>();
		for (Account owner : accountIdToAccountWithObrMap.values()) {
			String ownerBrand = owner.brand__c;
			for (Owner_Boat_Relationship__c obr : owner.Owner_Boat_Relationships__r) {
				String obrBrand = obr.hin_number__r.brand_del__C;
				boolean obrIsToBrandDifferentFromOwner = ownerBrand != obrBrand;
				if (obrIsToBrandDifferentFromOwner) {
					// need to find the newly created clone and set the OBR to the clone for the brand
					Map<String, Account> cloneBrandMap = brandCodeToCloneMap.get(owner.id);
					Account brandClone = cloneBrandMap.get(obrBrand);
					Owner_Boat_Relationship__c obrClone = obr.clone(false,true);
					obrClone.owner__c = brandClone.id;
					obrsToInsert.add(obrClone);
					obrsToDelete.add(obr);
				}
			}
		}
		if (!obrsToInsert.isEmpty()) {
			system.debug('Inserting ' + obrsToInsert.size() + ' new owner boat relationships');
			insert obrsToInsert;
		}
		if (!obrsToDelete.isEmpty()) {
			system.debug('Deleting ' + obrsToDelete.size() + ' owner boat relationships');
			delete obrsToDelete;
		}
	}
	
	
	private boolean ownsMultipleBrands(Account owner) {
		Set<String> brands = new Set<String>();
		for (Owner_Boat_Relationship__c obr : owner.Owner_Boat_Relationships__r) {
			brands.add(obr.hin_number__r.brand_del__C);
		}
		return brands.size() > 1;
	}
	
	// Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
	// taken from http://sfdc.arrowpointe.com/2011/03/28/cloning-records-in-apex/
    private String getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable() && fd.getName() != 'Name'){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
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
		mail.setSubject('OwnerResplitJob status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
			' batches with '+ a.NumberOfErrors + ' failures.');
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}