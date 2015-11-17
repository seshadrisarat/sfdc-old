global class SL_BoxUserBatch implements Schedulable {
	global void execute(SchedulableContext sc) {
		SL_BoxPopulateUserIdBatch b = new SL_BoxPopulateUserIdBatch();
		database.executebatch(b,1);
	}
}