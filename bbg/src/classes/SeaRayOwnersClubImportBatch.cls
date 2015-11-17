global class SeaRayOwnersClubImportBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
	global static final string QUERY = 'Select s.Customer_Wants_Mailings__c, s.Opt_out_of_Sea_Ray_Living__c, s.Zip_Code__c, s.Work_Phone__c, s.SystemModstamp, s.State__c, s.SROC_Welcome_Kit_Status__c, ' +
								's.SROC_Sales_Total__c, s.SROC_Purchased_Dealer_Number__c, s.SROC_Purchased_Dealer_Name__c, s.SROC_Purchase_Date__c, ' +
								's.SROC_Points_Total__c, s.SROC_Ownership_Status__c, s.SROC_Membership_Status__c, s.SROC_Member_ID__c, ' +
								's.SROC_Join_Date__c, s.SROC_Enrollment_Level__c, s.SROC_Cancellation_Date__c, s.OwnerId, s.New_or_Used__c, ' +
								's.Name_Suffix__c, s.Name, s.NCOA_Validation_Date__c, s.NCOA_Status__c, s.NCOA_Address_Status__c, ' +
								's.Middle_Initial__c, s.Last_Name__c, s.LastViewedDate, s.LastReferencedDate, s.LastModifiedDate, ' +
								's.LastModifiedById, s.LastActivityDate, s.IsDeleted, s.Id, s.Home_Phone__c, s.HIN__c, s.First_Name__c, ' +
								's.Entry_Source__c, s.Email__c, s.Email_Opt_In__c, s.CreatedDate, ' + 
								's.CreatedById, s.Country__c, s.Country_Name__c, s.Comments__c, s.Co_Owner__c, s.City__c, s.Brand__c, ' +
								's.Boat_Model__c, s.Boat_Model_Year__c, s.Birth_Date__c, s.Address__c, s.SROC_Enrollment_Status__c ' +
								'From SROC__c s where s.Is_Processed__c=false and s.Is_Processing_Error__c=false ' +
								'order by s.SROC_Join_Date__c asc';
	
	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(QUERY);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		system.debug('Running batch SROC');
		SeaRayOwnersClubImportService service = new SeaRayOwnersClubImportService();
		
		BoatServices.disableTriggerProcessing = true;
		OwnerBoatRelationshipServices.disableTriggerProcessing = true;
		for(sObject obj : scope){
			SROC__c ocData = (SROC__c)obj;
			
			try {
				system.debug('Processing SROC - ' + ocData.Id + ' for HIN ' + ocData.HIN__c);
				service.processOwnersClubData(ocData);
				system.debug('Done processing SROC data');
			}
			catch(Exception exp) {
				system.debug('Encountered exception in batch');
				system.debug('Exception = ' + exp.getMessage());
			}
		}
		
		BoatServices.disableTriggerProcessing = false;
		OwnerBoatRelationshipServices.disableTriggerProcessing = false;
	}
	
	// Schedulable function
	global void execute(SchedulableContext sc){
		SeaRayOwnersClubImportBatch batch= new SeaRayOwnersClubImportBatch();
		Database.executeBatch(batch, 25);
	}

	global void finish(Database.BatchableContext BC){
	}
}