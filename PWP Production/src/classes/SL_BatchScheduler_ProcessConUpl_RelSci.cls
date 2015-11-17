global class SL_BatchScheduler_ProcessConUpl_RelSci implements Schedulable {
	global void execute(SchedulableContext sc) {
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		Database.executeBatch(new SL_Batch_ProcessContactUpload_RelSci('SELECT Id, RelSci_SyncId__c, PWP_Employee__r.username FROM Relationship__C WHERE Relsci_Status__c = \'Uploaded\' and RelSci_SyncId__c != null'), 10);

	}
}