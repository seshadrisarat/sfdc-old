global class LeadSetBatchFlagsJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	public static boolean isBulkLeadBulkUpdate = false;
    private DateTime startDateTime = DateTime.now();
	
    private static Id meridianLeadRecordTypeId {
        get{
            
            if (meridianLeadRecordTypeId == null){
                meridianLeadRecordTypeId = [Select Id From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Meridian_Yachts_Lead'].Id;
            }
            system.debug('Meridian yachts lead record type id: ' + meridianLeadRecordTypeId);
            return meridianLeadRecordTypeId;
        }
        set;
    } 
    
    private static Id searayLeadRecordTypeId {
        get{
            
            if (searayLeadRecordTypeId == null){
                searayLeadRecordTypeId = [Select Id From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Sea_Ray_Lead'].Id;
            }
            system.debug('Sea Ray lead record type id: ' + searayLeadRecordTypeId);
            return searayLeadRecordTypeId;
        }
        set;
    }
	
	global Database.QueryLocator start(Database.BatchableContext context){
		system.debug('In QueryLocator.getQueryLocator');
		if(Test.isRunningTest()) {
			return Database.getQueryLocator([Select l.PostalCode, l.Lead_Emails_Sent__c, l.LastName, l.Id, l.Geonames_Retry__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.FirstName, l.County__c, l.Country_ISO_Code__c, l.Country, l.City, l.Brand_Interest__c, l.Brand_Code__c, l.Assigned_Dealer_2_txt__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_1_txt__c, l.Assigned_Dealer_1__c, l.RecordTypeId From Lead l Where (l.RecordTypeId = :meridianLeadRecordTypeId Or l.RecordTypeId = :searayLeadRecordTypeId) And l.Country_ISO_Code__c = 'US' And MismatchDealerState__c = true And IsConverted = False And IsDeleted = False LIMIT 20]);
		} else {
			return Database.getQueryLocator([Select l.PostalCode, l.Lead_Emails_Sent__c, l.LastName, l.Id, l.Geonames_Retry__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.FirstName, l.County__c, l.Country_ISO_Code__c, l.Country, l.City, l.Brand_Interest__c, l.Brand_Code__c, l.Assigned_Dealer_2_txt__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_1_txt__c, l.Assigned_Dealer_1__c, l.RecordTypeId From Lead l Where (l.RecordTypeId = :meridianLeadRecordTypeId Or l.RecordTypeId = :searayLeadRecordTypeId) And l.Country_ISO_Code__c = 'US' And MismatchDealerState__c = true And IsConverted = False And IsDeleted = False]);
		}
	}
	 
	global void execute(Database.BatchableContext context, List<sObject> unassignedLeads){
		system.debug('In execute ');
		isBulkLeadBulkUpdate = true; 
		FootstepsService.SEND_FOOTSTEPS_LEADS = false;
		LeadRouter.sendEmail = false;
		List<Lead> leads = new List<Lead>();

        
		for (sObject sLead : unassignedLeads) {
			Lead lead = (Lead) sLead; 
			
			//Set Lead_Emails_Sent__c and Batch_Update__c to true so that we do not generate emails via workflow (and code) 
            lead.Lead_Emails_Sent__c = true;
            
            //Set the batch flag to True
            lead.Batch_Update__c = true;
            
            //Set the batch error flag to false
            lead.Batch_Error__c = false;
			
            leads.add(lead);
  		}
  		
  		update leads;
		
    }
    
	global void finish(Database.BatchableContext context){
		//Send out email
		DateTime endDateTime = DateTime.now();
    	String formattedStartDT = startDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        String formattedEndDT = endDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        
	    AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
			TotalJobItems, CreatedBy.Email
			FROM AsyncApexJob WHERE Id =
			:context.getJobId()];

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {a.CreatedBy.Email};
		mail.setToAddresses(toAddresses);
		mail.setSubject('Lead Set Batch Flags Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		FootstepsService.SEND_FOOTSTEPS_LEADS = true;
		LeadRouter.sendEmail = true;
	}
	
}