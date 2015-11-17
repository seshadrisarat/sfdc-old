global class psaRollupsSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		psaRollups b = new psaRollups();
		database.executebatch(b);
	}
}