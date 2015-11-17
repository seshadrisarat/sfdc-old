global class LeadReassignDealersJob { // implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	/*
	public static boolean isBulkLeadBulkUpdate = false;
	private List<String> leadsAssigned = new List<String>();
	private List<String> leadsNotGeocoded = new List<String>();
	private List<String> leadsNotAssigned = new List<String>();
	private String successText = 'Lead Id: {0}, Lead Name:, {1}, {2}: Assigned Dealer 1: {3}, Assigned Dealer 2: {4}, Assign Dealer 3: {5}';
	private String geoCodeFailureText = 'Lead Id: {0}, Lead Name:, {1}, {2}: Was not geocoded.  GeoNames error: {3}';
	private String assignedFailureText = 'Lead Id: {0}, Lead Name:, {1}, {2}: Was not assigned a dealer.';
	private String[] textArguments;
    private DateTime startDateTime = DateTime.now();
	
	private static Map<Id, RecordType> allLeadRecordTypes {
        get{
            
            if (allLeadRecordTypes == null){
                allLeadRecordTypes = new Map<Id, RecordType>([Select Id, DeveloperName From RecordType Where SObjectType = 'Lead']);
            }
            system.debug('Lead record types: ' + allLeadRecordTypes);
            return allLeadRecordTypes;
        }
        set;
    }
    
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
		    return Database.getQueryLocator([Select l.PostalCode, l.Lead_Emails_Sent__c, l.LastName, l.Id, l.Geonames_Retry__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.FirstName, l.County__c, l.Country_ISO_Code__c, l.Country, l.City, l.Brand_Interest__c, l.Brand_Code__c, l.Assigned_Dealer_2_txt__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_1_txt__c, l.Assigned_Dealer_1__c, l.State, l.RecordTypeId From Lead l  LIMIT 20]);
		} else {
			return Database.getQueryLocator([Select l.PostalCode, l.Lead_Emails_Sent__c, l.LastName, l.Id, l.Geonames_Retry__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.FirstName, l.County__c, l.Country_ISO_Code__c, l.Country, l.City, l.Brand_Interest__c, l.Brand_Code__c, l.Assigned_Dealer_2_txt__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_1_txt__c, l.Assigned_Dealer_1__c, l.State, l.RecordTypeId From Lead l Where (l.RecordTypeId = :meridianLeadRecordTypeId Or l.RecordTypeId = :searayLeadRecordTypeId) And l.Country_ISO_Code__c = 'US' And MismatchDealerState__c = true And IsConverted = False And IsDeleted = False And Batch_Update__c = true And l.Batch_Error__c != true]);
		}
	}
	 
	global void execute(Database.BatchableContext context, List<sObject> unassignedLeads){
		system.debug('In execute ');
		isBulkLeadBulkUpdate = true; 
		FootstepsIntegrationServices.SEND_FOOTSTEPS_LEADS = false;
		LeadRouter.sendEmail = false;
		Set<Id> leadIds = new Set<Id>();
		List<Lead> leads = new List<Lead>();
		List<Lead> leadsToRoute = new List<Lead>();
		List<Lead> leadsToUpdate = new List<Lead>();
        
		//Iterate through the leads to geocode and assign dealers
		for (sObject sLead : unassignedLeads) {
			Lead lead = (Lead) sLead; 
			
			system.debug('Testing: ' + lead.FirstName + ' ' + lead.LastName);
			
			if (lead.GeoLocation__Latitude__s == null || lead.GeoLocation__Longitude__s == null || lead.State.length() > 2) {
				//Need to geocode if the latitude and / or longitude data is missing, or the state length > 2 (possible full state name)
				system.debug('Lead not geocoded, add to list of lead to geocode');
				leadIds.add(lead.Id);
            }
            leads.add(lead);
  		}
  		
  		if (leadIds.size() > 0) { 
  			LeadServices.geoFieldsMakeCallout(leadIds, false, false); 
  		}
  		
  		for (Lead lead: leads) {
  			Boolean brandCodeOnLead = True;
  			
  			//Reload the lead so that we can test the geocode info
  			lead = [Select l.Id, l.LastName, l.FirstName, l.Brand_Code__c, l.Country_ISO_Code__c, l.County__c, l.PostalCode, l.State, l.Assigned_Dealer_1__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_3__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.Longitude__c, l.Latitude__c, l.Lead_Emails_Sent__c, l.Boat_Category_of_Interest__c, l.LeadSource, l.Lead_Form_Name__c, l.RecordTypeId From Lead l Where l.id = :lead.Id];
           	
           	//Set Lead_Emails_Sent__c and Batch_Update__c to true so that we do not generate emails via workflow (and code) 
            lead.Lead_Emails_Sent__c = true;
            
            //Set the batch flag to True
            lead.Batch_Update__c = true;
            
            if (lead.GeoLocation__Latitude__s == null || lead.GeoLocation__Longitude__s == null) {
            	//Not geocoded, record error 
            	system.debug('Lead still not geocoded, record error');
            	textArguments = new String[] {lead.Id, lead.LastName, lead.FirstName, lead.GeoNames_WebService_Error__c};
				leadsNotGeocoded.add(String.format(geoCodeFailureText, textArguments));
            } else {
            	system.debug('Lead id: ' + lead.Id + ' for brand: ' + lead.Brand_Code__c + ' is geocoded.  Latitude: ' + lead.GeoLocation__Latitude__s + ', longitude: ' + lead.GeoLocation__Longitude__s + ', adding to list of lead ids');
            
	            //Is the brand code and brand interest set on the lead
	            if (String.isEmpty(lead.Brand_Code__c) || String.isEmpty(lead.Brand_Interest__c)) {
	           		brandCodeOnLead = False;
	           		
		            RecordType leadRecordType = allLeadRecordTypes.get(lead.RecordTypeId);
		            
		            if (leadRecordType != null) {
		                if (leadRecordType.DeveloperName.equalsIgnoreCase('Sea_Ray_Lead')) {
		                    lead.Brand_Interest__c = 'Sea Ray';
		                } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Bayliner_Lead')) {
		                    lead.Brand_Interest__c = 'Bayliner';
		                } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Maxum_Lead')) {
		                    lead.Brand_Interest__c = 'Maxum';
		                } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Trophy_Lead')) {
		                    lead.Brand_Interest__c = 'Trophy';
		                } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Meridian_Yachts_Lead')) {
		                    lead.Brand_Interest__c = 'Meridian';
		                } else if (leadRecordType.DeveloperName.equalsIgnoreCase('Boston_Whaler_Lead')) {
		                    lead.Brand_Interest__c = 'Boston Whaler';
		                }
		            } else {
		                system.debug('Unable to find lead record type');
		            }
	            }
	            
	            update lead;
		            
		        //If the brand code was not on the lead, re-read as it should be now
		        //Brand code is a formula field based on the brand interest
		        if (brandCodeOnLead == False) {  	
	           		lead = [Select l.Id, l.LastName, l.FirstName, l.Brand_Code__c, l.Country_ISO_Code__c, l.County__c, l.PostalCode, l.State, l.Assigned_Dealer_1__c, l.Assigned_Dealer_2__c, l.Assigned_Dealer_3__c, l.GeoNames_WebService_Error__c, l.GeoLocation__c, l.GeoLocation__Longitude__s, l.GeoLocation__Latitude__s, l.Longitude__c, l.Latitude__c, l.Lead_Emails_Sent__c, l.Boat_Category_of_Interest__c, l.LeadSource, l.Lead_Form_Name__c, l.RecordTypeId From Lead l Where l.id = :lead.Id];
		        }
		        
				system.debug('Lead id: ' + lead.Id + ' for brand: ' + lead.Brand_Code__c);
            	
            	leadsToRoute.add(lead);
			}
  		}
  		
  		if (leadsToRoute.size() > 0) {
  			LeadServices.routeLeads(leadsToRoute, new List<Lead>());
  		}
  		
  		
  		for (Lead lead: leadsToRoute) {
            	
			lead = [Select l.Id, l.LastName, l.FirstName, l.Assigned_Dealer_1__r.Dealer_Number__c, l.Assigned_Dealer_2__r.Dealer_Number__c, l.Assigned_Dealer_3__r.Dealer_Number__c, l.GeoNames_WebService_Error__c From Lead l Where l.id = :lead.id];
			
			if (lead.Assigned_Dealer_1__c != null) {
				system.debug('Lead was assigned a dealer');
				textArguments = new String[] {lead.Id, lead.LastName, lead.FirstName, lead.Assigned_Dealer_1__r.Dealer_Number__c, lead.Assigned_Dealer_2__r.Dealer_Number__c, lead.Assigned_Dealer_3__r.Dealer_Number__c};
				leadsAssigned.add(String.format(successText, textArguments));
			} else {
				system.debug('Lead was not assigned a dealer');
				textArguments = new String[] {lead.Id, lead.LastName, lead.FirstName};
				leadsNotAssigned.add(String.format(assignedFailureText, textArguments));
			}
			
		}
		
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
		mail.setSubject('Lead Assign Dealers Job Result Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT
            + '\n\nSuccessful: ' + leadsAssigned.size()
			+ '\nGeocode Errors (' + leadsNotGeocoded.size() + '): ' + (!leadsNotGeocoded.isEmpty() ? String.join(leadsNotGeocoded, ' \n') : 'None')
			+ '\n\nDealer Assignment Errors (' + leadsNotAssigned.size() + '): ' + (!leadsNotAssigned.isEmpty() ? String.join(leadsNotAssigned, ' \n') : 'None'));
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		FootstepsIntegrationServices.SEND_FOOTSTEPS_LEADS = true;
		LeadRouter.sendEmail = true;
	}
	*/

}