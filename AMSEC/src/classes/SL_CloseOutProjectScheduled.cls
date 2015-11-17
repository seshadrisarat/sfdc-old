global class SL_CloseOutProjectScheduled implements Schedulable {

	public static String sched = '0 15 00 * * ?';  //Every Day at 12:15am

	 global static String scheduleMe() {
        SL_CloseOutProjectScheduled SC = new SL_CloseOutProjectScheduled(); 
        return System.schedule('SL_CloseOutProjectBatch', sched, SC);
    }
	global void execute(SchedulableContext sc) {
		SL_CloseOutProjectBatch b = new SL_CloseOutProjectBatch();
		Database.executeBatch(b,100);
	}
}