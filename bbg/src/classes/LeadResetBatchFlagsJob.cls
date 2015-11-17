global class LeadResetBatchFlagsJob implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	public static boolean isBulkLeadBulkUpdate = false;
    private DateTime startDateTime = DateTime.now();
	
    private static Id baylinerLeadRecordTypeId {
        get{
            
            if (baylinerLeadRecordTypeId == null){
                baylinerLeadRecordTypeId = [Select Id From RecordType Where SObjectType = 'Lead' And DeveloperName = 'Bayliner_Lead'].Id;
            }
            system.debug('Bayliner lead record type id: ' + baylinerLeadRecordTypeId);
            return baylinerLeadRecordTypeId;
        }
        set;
    }
	
	global Database.QueryLocator start(Database.BatchableContext context){
		system.debug('In QueryLocator.getQueryLocator');
		if(Test.isRunningTest()) {
			return Database.getQueryLocator([Select l.Id, l.Lead_Emails_Sent__c, l.Batch_Update__c From Lead l Where l.RecordTypeId != :baylinerLeadRecordTypeId And l.Batch_Update__c = true And l.Batch_Error__c != true And IsConverted = False And IsDeleted = False LIMIT 20]);
		} else {
			return Database.getQueryLocator([Select l.Id, l.Lead_Emails_Sent__c, l.Batch_Update__c From Lead l Where l.RecordTypeId != :baylinerLeadRecordTypeId And l.Batch_Update__c = true And l.Batch_Error__c != true And IsConverted = False And IsDeleted = False]);
		}
	}
	 
	global void execute(Database.BatchableContext context, List<sObject> batchLeads){
		system.debug('In execute ');
		isBulkLeadBulkUpdate = true; 
		FootstepsService.SEND_FOOTSTEPS_LEADS = false;
		LeadRouter.sendEmail = false;
		List<Lead> leads = new List<Lead>();

		for (sObject sLead : batchLeads) {
			Lead lead = (Lead) sLead; 
			
            //Set the batch flag to false
            lead.Batch_Update__c = false;
            
            //if (lead.Assigned_Dealer_1__c == null) {
            //	lead.Batch_Error__c = true;
            //}
			
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
		mail.setSubject('Lead Reset Batch Flags Status: ' + a.Status);
		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n'
            + '\nStart datetime: ' + formattedStartDT
            + '\nEnd datetime: ' + formattedEndDT);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		FootstepsService.SEND_FOOTSTEPS_LEADS = true;
		LeadRouter.sendEmail = true;
	}
	
}