public with sharing class JiraWorklogsRefresh_Remote {

	static JiraWorklogsRefresh wlRefresh = new JiraWorklogsRefresh();

	static {
		wlRefresh.numberOfHours = -99999;
	}

	@RemoteAction
	public static List<sObject> query(String soql) {
        return Database.query(soql);
	}

	@RemoteAction
	public static String refreshIssueWithKey(String key) {
        try {
            JIRAMethods.upsertIssue(
            	( JiraWrappers.REST_Issue ) JSON.deserialize( new JIRARequest( '/issue/' + key ).sendRequest().getBody(), JiraWrappers.REST_Issue.class )
            );
        } catch ( Exception e ) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            return 'Error: ' + key + ' => ' + e.getMessage();
        }
        return 'Success: ' + key;	
	}

	@RemoteAction
	public static String refreshWorklogsWithIssue(Id issueId) {
		wlRefresh.issues = [Select Id, Name, Worklogs_Needed__c, Milestone__c, OA_Task_Id__c, Project__c, Project__r.Legacy_Project__c from SF_Issue__c where Id = :issueId];
		return run(wlRefresh.issues[0].Name);
	}

	@RemoteAction
	public static String refreshWorklogsWithIssueDEL(Id issueId) {
		wlRefresh.shouldDelete = true;
		return refreshWorklogsWithIssue(issueId);
	}

	private static String run(String msg) {
		try {
			wlRefresh.run();
		} catch(Exception e) {
			return 'Error: ' + msg + ' => ' + e.getMessage();
		}

		return 'Success: ' + msg;		
	}
}