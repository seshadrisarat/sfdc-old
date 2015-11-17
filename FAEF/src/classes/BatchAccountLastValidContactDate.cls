global with sharing class BatchAccountLastValidContactDate implements Database.Batchable<sObject> {

	// usage:
   // Id batchId = Database.executeBatch(new BatchAccountLastValidContactDate()); 
   
	global BatchAccountLastValidContactDate() {}

	global Database.Querylocator start(Database.BatchableContext context) {
		
		if(Test.isRunningTest()) {
			return Database.getQueryLocator([select
				Id,	
				Last_Valid_Contact_Date__c, 
				(select Id, ActivityDate from Tasks where Type = 'Email In' or Result__c = 'Spoke to DM' or Result__c = 'Spoke to Influencer' order by ActivityDate desc limit 1)
				from Account
				where Last_Valid_Contact_Date__c = null
				limit 200
			]);
		}
		
		return Database.getQueryLocator([select
			Id,
			Last_Valid_Contact_Date__c, 
			(select Id, ActivityDate from Tasks where Type = 'Email In' or Result__c = 'Spoke to DM' or Result__c = 'Spoke to Influencer' order by ActivityDate desc limit 1)
			from Account
			where Last_Valid_Contact_Date__c = null
		]);
	}

	global void execute(Database.BatchableContext context, List<Account> accounts) {
		
		for(Account a : accounts) {
			if(a.Tasks.size() == 0) continue;
			a.Last_Valid_Contact_Date__c = a.Tasks[0].ActivityDate;
		}
		
		update accounts;

	}

	global void finish(Database.BatchableContext context) {}

	public static testMethod void testBatch() {
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5)
        {
        	Test.StartTest();  
        		BatchAccountLastValidContactDate batch = new BatchAccountLastValidContactDate();
				Id batchProcessId = Database.executeBatch(batch);
			Test.StopTest();	
        }
	}

}