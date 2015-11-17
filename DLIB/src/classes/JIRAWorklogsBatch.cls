global class JIRAWorklogsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	global Integer numberOfHours = -2;

	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'Select Id, Name, Worklogs_Needed__c, Milestone__c, OA_Task_Id__c, Project__c, Project__r.Legacy_Project__c FROM SF_Issue__c WHERE Worklogs_Needed__c=true order by Name limit 10';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<SF_Issue__c> scope){
		JIRAWorklogsRefresh j = new JIRAWorklogsRefresh(scope);
		j.numberOfHours = numberOfHours;
		j.run();		
	}

	global void finish(Database.BatchableContext BC){
		list<SF_Issue__c> lstIssues = new list<SF_Issue__c>([Select Id FROM SF_Issue__c WHERE Worklogs_Needed__c=true limit 10]);
		if (lstIssues.size()>0) {
			JIRAWorklogsBatch bW = new JIRAWorklogsBatch();
			bW.numberOfHours = numberOfHours;
			Database.executeBatch(BW);
		}
	}
	
}