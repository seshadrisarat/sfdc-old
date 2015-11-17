/**
 * \author Vladimir Dobrelya
 * \date Apr 07, 2014
 * \brief The test class for JiraWebhookListener class
 */
@isTest
private class JiraWebhookListenerTest {
	
	@isTest static void webhookListener() {
		JiraWrappers.REST_Issue oJiraIssue = JiraMethodsTest.createData();
		system.assertEquals( null, JiraMethodsTest.selectIssue(), 'The SF Issue with Jira_Issue_Name__c = \'' + JiraMethodsTest.sIssueKey + '\' already exists.' );

		JiraWrappers.REST_Response oResponse = createResponse( oJiraIssue );

		Test.startTest();
			system.assertEquals( 201, handle( 'jira:issue_created', oResponse ) );
			system.assertEquals( 201, handle( 'jira:issue_updated', oResponse ) );

			oResponse.changelog = createChangeLogTracking();
			system.assertEquals( 201, handle( 'jira:worklog_updated', oResponse ) );

			oResponse.changelog = JiraMethodsTest.createChangeLogTracking();
			system.assertEquals( 204, handle( 'jira:worklog_updated', oResponse ) );
			
			system.assertEquals( 204, handle( 'jira:issue_deleted', oResponse ) );
			system.assertEquals( 415, handle( 'jira:incorrect', oResponse ) );
			system.assertEquals( 400, handle( null, null ) );
		Test.stopTest();
	}

	static Integer handle( String sWebhookEvent, JiraWrappers.REST_Response oResponse ) {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();
		if ( oResponse != null ) {
			oResponse.webhookEvent = sWebhookEvent;
			RestContext.request.requestBody = Blob.valueOf( JSON.serialize( oResponse ) );
		}
        JiraWebhookListener.doPost();
        return RestContext.response.statusCode;
	}

	static JiraWrappers.REST_Response createResponse( JiraWrappers.REST_Issue oJiraIssue ) {
		JiraWrappers.REST_Response oResult = new JiraWrappers.REST_Response();
		oResult.id = '123';
		oResult.issue = oJiraIssue;
		oResult.changelog = null;
		return oResult;
	}

	public static JiraWrappers.REST_ChangelogTracking createChangeLogTracking() {
    	JiraWrappers.REST_ChangelogTracking oResult = new JiraWrappers.REST_ChangelogTracking();
    	oResult.items = new List<JiraWrappers.REST_Changelog>{ new JiraWrappers.REST_Changelog() };
    	oResult.items[ 0 ].field = 'WorklogId';
    	oResult.items[ 0 ].fromString = JiraMethodsTest.sWorklogId;
    	oResult.items[ 0 ].toString = null;

    	return oResult;
    }
}