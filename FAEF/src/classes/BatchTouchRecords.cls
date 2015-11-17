global class BatchTouchRecords implements Database.Batchable<sObject> {
   
   // usage:
   // Id batchId = Database.executeBatch(new BatchTouchRecords('your_soql_here')); 
   
	global final String query;
   
	global BatchTouchRecords(String q) { 
		query = q; 
	}

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext context, List<sObject> scope) {
		update scope;
	}

	global void finish(Database.BatchableContext context) {}

	public static testMethod void testBatch() {
		
		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing' OR Status = 'Queued')] < 5)
        {
        	Test.StartTest();  
			BatchTouchRecords btr = new BatchTouchRecords('select Id from Task where Type like \'%Email%\' limit 100');
			Id batchProcessId = Database.executeBatch(btr);
			Test.StopTest();
        }	
	}
}