@isTest
private class Scheduler_control_test {
	private static testMethod void testMinutesEmpty() {
		List<Scheduled_Job__c> schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		List<CronTrigger> listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
		
		Scheduler_Control tested = new Scheduler_Control();
		
		tested.isTest = true;
		
		//Run create method with empty minutes field
		system.debug('======== MINUTES FIELD IS EMPTY ========');
		tested.createScheduler();
		schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (After push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (After push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
	}
	private static testMethod void testMinutesValid() {
		List<Scheduled_Job__c> schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		List<CronTrigger> listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
		
		Scheduler_Control tested = new Scheduler_Control();
		
		tested.isTest = true;
		
		//Run create method with normal minutes interval
		system.debug('======== MINUTES FIELD HAVE A NORMAL VALUE (10 minutes) ========');
		tested.minutes = 10;
		tested.createScheduler();
		schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (After push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (After push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
	}
	private static testMethod void testMinutesError() {
		List<Scheduled_Job__c> schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		List<CronTrigger> listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (Before push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
		
		Scheduler_Control tested = new Scheduler_Control();
		
		tested.isTest = true;
		
		//Run create method with error minutes value
		system.debug('======== MINUTES FIELD HAVE AN ERROR VALUE (70 minutes) ========');
		tested.minutes = 70;
		tested.createScheduler();
		schedules = [SELECT Name,Cron_Id__c FROM Scheduled_Job__c];
		system.debug('======== DB consist schedules (After push \'Create\' button) ==== >>>> ');
		for (Scheduled_Job__c item:schedules) {
			system.debug('======== Cron ID: '+item.Cron_Id__c+'    Schedule ID: '+item.Id);
		}
		listCronTrigger = [select Id from CronTrigger];
		system.debug('======== CronTrigger consist schedules (After push \'Create\' button) ==== >>>> ');
		for (CronTrigger item:listCronTrigger) {
			system.debug('======== Cron ID: '+item.Id);
		}
	}
}