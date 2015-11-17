global without sharing class SL_ScheduleUserContactCleanup implements Schedulable {

	global void execute(SchedulableContext sc){
		SL_UsersWithMismatchedContacts_Cleanup batch = new SL_UsersWithMismatchedContacts_Cleanup(null);
		Database.executeBatch(batch);
	}
}