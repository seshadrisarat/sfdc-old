global class SL_LockDownTimeRecords_Scheduled implements Schedulable {
	
	public static String sched = '0 00 01 15 * ?';  //Every 15th at 1 in the morning

    global static String scheduleMe() {
        SL_LockDownTimeRecords_Scheduled SC = new SL_LockDownTimeRecords_Scheduled(); 
        return System.schedule('SL_LockDownTimeRecordsBatch', sched, SC);
    }


	global void execute(SchedulableContext sc) {
		SL_LockDownTimeRecordsBatch b = new SL_LockDownTimeRecordsBatch();
		Database.executeBatch(b,100);
	} 
}