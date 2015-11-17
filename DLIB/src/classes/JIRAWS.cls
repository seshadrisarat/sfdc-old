global class JIRAWS {
	webService static string createIssue(string projectId, string MilestoneSFId, string userid) {
		
		string username = null;
		for (Contact item:[Select JIRA_User_Name__c FROM Contact WHERE pse__Salesforce_User__c=:userid ]) {
			username = item.JIRA_User_Name__c;
		}
		
		string ProjectJIRAName = null;
		for (pse__Proj__c item:[Select JIRA_Project_Name__c FROM pse__Proj__c WHERE Id=:projectId]) {
			ProjectJIRAName = item.JIRA_Project_Name__c;
		}
		
		JiraWrappers.REST_Request issue = new JiraWrappers.REST_Request(ProjectJIRAName, 'New Feature', 'NEW_ISSUE', '', username, username, MilestoneSFId);
		
		id issueId = null;
		string newIssue = JSON.serialize(issue);
		JIRARequest jr = new JIRARequest('/issue');
		jr.sendrequestPOST(newIssue);
		HttpResponse res = jr.res;
		JiraWrappers.REST_Issue obj = (JiraWrappers.REST_Issue) System.JSON.deserialize(res.getBody(), JiraWrappers.REST_Issue.class);
		if (obj!=null && obj.id!=null) {
    		return jr.endpointHost + '/secure/EditIssue!default.jspa?id='+ obj.id;
    	}
    	return 'Jira Issue was NOT created!';
	}
}