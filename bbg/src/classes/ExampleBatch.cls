global class ExampleBatch implements Database.Batchable<sObject> , Database.Stateful{
	
		global Database.QueryLocator start(Database.BatchableContext BC) {
			return Database.getQueryLocator([Select Id From Lead Limit 20 ]);
		}

	   	global void execute(Database.BatchableContext BC, List<Lead> scope) {
						
		}
		
		global void finish(Database.BatchableContext BC) {

		}
	
}