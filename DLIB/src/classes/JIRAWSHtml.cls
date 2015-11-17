global class JIRAWSHtml {
	webService static string createIssue(string projectId, string MilestoneSFId, string userid) {
		
		string username = null;
		for (Contact item:[Select JIRA_User_Name__c FROM Contact WHERE pse__Salesforce_User__c=:userid ]) {
			username = item.JIRA_User_Name__c;
		}
		
		string ProjectJIRAName = null;
		for (pse__Proj__c item:[Select JIRA_Project_Name__c FROM pse__Proj__c WHERE Id=:projectId]) {
			ProjectJIRAName = item.JIRA_Project_Name__c;
		}
		
		JIRARequest jr = new JIRARequest('/project/'+ProjectJIRAName);
		jr.sendrequest();
		HttpResponse res = jr.res;
		JiraWrappers.REST_Project obj = (JiraWrappers.REST_Project) System.JSON.deserialize(res.getBody(), JiraWrappers.REST_Project.class);
    	if (obj!=null && obj.id!=null) {
    		return jr.endpointHost + '/secure/CreateIssueDetails!init.jspa?pid='+obj.id+'&issuetype=1&reporter='+username+'&assignee='+username+'&summary=NEW_ISSUE&duedate='+Datetime.now().addDays(7).format('d/MMM/yyyy')+'&customfield_11130='+MilestoneSFId;
    	}
    	
    	return 'Jira Issue was NOT created!';
	}
}