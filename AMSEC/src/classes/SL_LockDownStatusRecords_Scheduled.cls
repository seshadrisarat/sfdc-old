global class SL_LockDownStatusRecords_Scheduled implements Schedulable {
	
	public static String sched = '0 00 01 15 * ?';  //Every 15th at 1 in the morning

    global static String scheduleMe() {
        SL_LockDownStatusRecords_Scheduled SC = new SL_LockDownStatusRecords_Scheduled(); 
        return System.schedule('SL_LockDownStatusRecordsBatch', sched, SC);
    }


	global void execute(SchedulableContext sc) {
		SL_LockDownStatusRecordsBatch b = new SL_LockDownStatusRecordsBatch();
		Database.executeBatch(b,100);
	} 
}