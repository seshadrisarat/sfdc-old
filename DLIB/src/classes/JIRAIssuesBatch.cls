global class JIRAIssuesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
	global String jql = 'updated>-1d';
	global String fields = 'key,id,customfield_10233,description,comment,summary,timetracking,assignee,reporter,versions';
	global Integer numberOfHours = -2;
	global Boolean isMigration = false;
	global Boolean runWorklogs = false;
	global Integer maxResults = 1000;
	global Integer startAt = 0;

	global Database.QueryLocator start(Database.BatchableContext BC){
		string query = 'Select Id FROM pse__Proj__c WHERE JIRA_Project_Name__c!=null limit 1';
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		JIRAIssues ji = new JIRAIssues(fields,jql,isMigration,maxResults,startAt);
		ji.getIssues();
	}

	global void finish(Database.BatchableContext BC){
		if(runWorklogs) {
			list<SF_Issue__c> lstIssues = new list<SF_Issue__c>([Select Id FROM SF_Issue__c WHERE Worklogs_Needed__c=true limit 10]);
			if (lstIssues.size()>0) {
				JIRAWorklogsBatch bW = new JIRAWorklogsBatch();
				bW.numberOfHours = numberOfHours;
				Database.executeBatch(BW);
			}
		}
	}
}