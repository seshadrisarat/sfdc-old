global class JiraIssuesBatchSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
		JiraIntegration__c settings = JiraIntegration__c.getInstance();

		JIRAIssuesBatch bW = new JIRAIssuesBatch();
		bW.isMigration = settings.isMigration__c;
		bW.jql = settings.jql__c;
		bW.numberOfHours = Integer.valueOf(settings.numberOfHours__c);
		bW.runWorklogs = settings.runWorklogs__c;
		Database.executeBatch(BW);
	}
}