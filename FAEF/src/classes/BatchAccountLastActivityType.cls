global class BatchAccountLastActivityType implements Database.Batchable<sObject> {

	// usage:
   // Id batchId = Database.executeBatch(new BatchAccountLastActivityType()); 
   
	global BatchAccountLastActivityType() {}

	global Database.Querylocator start(Database.BatchableContext context) {
		
		if(Test.isRunningTest()) {
			return Database.getQueryLocator([select
				Id,
				Last_Activity_Type2__c,
				(select ActivityDate, Type from Tasks where ActivityDate <= :Date.today() order by ActivityDate desc limit 1),
				(select ActivityDate, Type from Events where ActivityDate <= :Date.today() order by ActivityDate desc limit 1)
				from Account limit 200
			]);
		}
		
		return Database.getQueryLocator([select
			Id,
			Last_Activity_Type2__c,
			(select ActivityDate, Type from Tasks where ActivityDate <= :Date.today() order by ActivityDate desc limit 1),
			(select ActivityDate, Type from Events where ActivityDate <= :Date.today() order by ActivityDate desc limit 1)
			from Account
		]);
	}

	global void execute(Database.BatchableContext context, List<Account> accounts) {
		
		for(Account a : accounts) {
			if(a.Tasks.size() > 0) {
				if(a.Events.size() > 0) {
					if(a.Tasks[0].ActivityDate > a.Events[0].ActivityDate) {
						a.Last_Activity_Type2__c = a.Tasks[0].Type;	
					}
					else {
						a.Last_Activity_Type2__c = a.Events[0].Type;
					}
				}
				else {
					a.Last_Activity_Type2__c = a.Tasks[0].Type;
				}
			}
			else if(a.Events.size() > 0) {
				a.Last_Activity_Type2__c = a.Events[0].Type;
			}
			else {
				a.Last_Activity_Type2__c = null;
			}
		}
		
		update accounts;

	}

	global void finish(Database.BatchableContext context) {}

	public static testMethod void testBatch() {
		
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5)
        {
        	Test.StartTest(); 
	        	BatchAccountLastActivityType batch = new BatchAccountLastActivityType();
				Id batchProcessId = Database.executeBatch(batch);
			Test.StopTest();
        }	
		
	
	}

}