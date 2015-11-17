global class SL_RelockTimeEntries implements Schedulable {
	global void execute(SchedulableContext sc) {
		SL_RelockTimeRecordsBatch b = new SL_RelockTimeRecordsBatch();
		Database.executeBatch(b,100);
		System.abortJob(SC.getTriggerID());
	}
}