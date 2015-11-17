global class SL_BatchScheduler_ProcAlteredRel_RelSci implements Schedulable {
	global void execute(SchedulableContext sc) 
	{
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		Database.executeBatch(new SL_Batch_ProcessAlteredRel_RelSci('SELECT Id, RelSci_EntityId__c,RelSci_User_Identifier__c FROM RelSci_Processing__c' ));

	}
}