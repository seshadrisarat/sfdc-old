/**
 * \author Vladimir Dobrelya
 * \date Apr 07, 2014
 * \brief The test class for JiraMethods class
 */
@isTest
public class JiraMethodsTest {
	
	public static String sIssueKey = 'TSTPRJ-1';
	public static String sUserName = 'testuser';
	public static String sProjectName = 'TESTPROJECT';
	public static String sWorklogId = '1';

	@isTest static void issue() {
		JiraWrappers.REST_Issue oJiraIssue = createData();

		system.assertEquals( null, selectIssue(), 'The SF Issue with Jira_Issue_Name__c = \'' + sIssueKey + '\' already exists.' );
		
		Test.startTest();
			JiraMethods.upsertWorklogs( oJiraIssue );
			system.assertNotEquals( null, selectIssue(), 'There is no SF Issue with Jira_Issue_Name__c = \'' + sIssueKey + '\'' );
			system.assertNotEquals( null, selectWorklog(), 'There is no Worklog with Jira_ID__c = \'' + sWorklogId + '\' and SF_Issue__r.Jira_Issue_Name__c = \'' + sIssueKey + '\'' );

			system.assertEquals( false, JiraMethods.deleteWorklog( oJiraIssue, null ) );
			system.assert( JiraMethods.deleteWorklog( oJiraIssue, createChangeLogTracking() ), 'Worklog hasn\'t been deleted' );
			
			JiraMethods.deleteIssue( sIssueKey );
			system.assertEquals( null, selectIssue(), 'SF Issue hasn\'t been deleted' );
		Test.stopTest();
	}
	
	/*@isTest static void test_method_two() {
		// Implement test code
	}*/
	
	public static JiraWrappers.REST_Issue createData() {
		insert pProject;
		insert pContact;
		return createIssue();
	}

	public static SF_Issue__c selectIssue() {
		for ( SF_Issue__c oItem : [ SELECT Id FROM SF_Issue__c WHERE Jira_Issue_Name__c = :sIssueKey AND IsDeleted__c = false limit 1 ] ) {
			return oItem;
		}
		return null;
	}

	public static Worklog__c selectWorklog() {
		for ( Worklog__c oItem : [ SELECT Id FROM Worklog__c WHERE JIRA_ID__c = :sWorklogId AND SF_Issue__r.Jira_Issue_Name__c = :sIssueKey AND IsDeleted__c = false limit 1 ] ) {
			return oItem;
		}
		return null;
	}
	
	public static pse__Proj__c pProject {
        get {
            if ( pProject == null ) {
                pProject = new pse__Proj__c(
                    Name = 'pProject_Test',
                    Jira_Project_Name__c = sProjectName,
                    pse__Region__c = SL_Settings.idRegionAllSilveline,
                    CurrencyIsoCode = 'USD',
                    pse__Is_Active__c = true
                );
            }
            return pProject;
        } set;
    }

    static Account pAccount {
    	get {
    		if ( pAccount == null ) {
	    		pAccount = new Account(
	    			Name = 'Test_pAccount'
	    		);
	    		insert pAccount;
	    	}
	    	return pAccount;
    	} private set;
    }

    public static Contact pContact {
    	get {
    		if ( pContact == null ) {
	    		pContact = new Contact(
	    			LastName = 'Test_pContact',
	    			JIRA_User_Name__c = sUserName,
	    			Email = 'pContact@example.com',
	    			AccountId = pAccount.Id,
	    			RecordTypeId = idRTContactEmployee
	    		);
	    	}
	    	return pContact;
    	} private set;
    }

    static ID idRTContactEmployee {
    	get {
    		if ( idRTContactEmployee == null ) {
    			for ( RecordType oItem : [ SELECT Id FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'Employee' limit 1 ] ) {
    				idRTContactEmployee = oItem.Id;
    			}
    		}
    		return idRTContactEmployee;
    	} private set;
    }

    public static JiraWrappers.REST_Issue createIssue() {
    	JiraWrappers.REST_Issue oResult = new JiraWrappers.REST_Issue();
    	oResult.id = '1';
    	oResult.key = sIssueKey;

    	JiraWrappers.REST_User oUser = new JiraWrappers.REST_User( sUserName );

    	oResult.fields = new JiraWrappers.REST_IssueFields(); // FIELDS
    	oResult.fields.summary = 'TEST SUMMARY';
    	oResult.fields.description = 'TEST DESCRIPTION';
    	oResult.fields.assignee = oUser;
    	oResult.fields.reporter = oUser;
    	oResult.fields.project = new JiraWrappers.REST_Project( sProjectName ); // PROJECT

		oResult.fields.worklog = new JiraWrappers.REST_WorklogTracking(); // WORKLOGS
		oResult.fields.worklog.worklogs = new List<JiraWrappers.REST_Worklog>{ new JiraWrappers.REST_Worklog() };
		oResult.fields.worklog.worklogs[ 0 ].id = sWorklogId;
		oResult.fields.worklog.worklogs[ 0 ].author = oUser;
		oResult.fields.worklog.worklogs[ 0 ].updateAuthor = oUser;
		oResult.fields.worklog.worklogs[ 0 ].comment = 'TEST COMMENT';
		oResult.fields.worklog.worklogs[ 0 ].created = DateTime.now().addDays( -1 );
		oResult.fields.worklog.worklogs[ 0 ].updated = DateTime.now();
		oResult.fields.worklog.worklogs[ 0 ].started = DateTime.now().addDays( -1 );
		oResult.fields.worklog.worklogs[ 0 ].timeSpent = '1d';
		oResult.fields.worklog.worklogs[ 0 ].timeSpentSeconds = 28800;

		oResult.fields.timetracking = new JiraWrappers.REST_Timetracking(); // TIMETRACKING
		oResult.fields.timetracking.timeSpentSeconds = 28800;
		oResult.fields.timetracking.originalEstimateSeconds = 30600;
		oResult.fields.timetracking.remainingEstimateSeconds = 1800;

        oResult.fields.customfield_10233 = '1'; // OpenAir ID

    	return oResult;
    }

    public static JiraWrappers.REST_ChangelogTracking createChangeLogTracking() {
    	JiraWrappers.REST_ChangelogTracking oResult = new JiraWrappers.REST_ChangelogTracking();
    	oResult.items = new List<JiraWrappers.REST_Changelog>{ new JiraWrappers.REST_Changelog() };
    	oResult.items[ 0 ].field = 'WorklogId';
    	oResult.items[ 0 ].fromString = sWorklogId;
    	oResult.items[ 0 ].toString = null;

    	oResult.items.add( new JiraWrappers.REST_Changelog() );
    	oResult.items[ 1 ].field = 'WorklogTimeSpent';
    	oResult.items[ 1 ].fromString = '1234';
    	oResult.items[ 1 ].toString = null;

    	return oResult;
    }
}



/*
{
   "webhookEvent":"jira:issue_updated",
   "user":{
      "name":"Integration",
      "emailAddress":"julia@silverlinecrm.com",
      "displayName":"Integration User"
   },
   "issue":{
      "id":"11001",
      "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001",
      "key":"XYZ-95",
      "fields":{
         "summary":"REST TEST",
         "timetracking":{
            "originalEstimate":"12m",
            "remainingEstimate":"0m",
            "timeSpent":"1d 30m",
            "originalEstimateSeconds":720,
            "remainingEstimateSeconds":0,
            "timeSpentSeconds":30600
         },
         "issuetype":{
            "name":"Bug",
            "subtask":false
         },
         "timespent":30600,
         "reporter":{
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "displayName":"Integration User"
         },
         "created":"2014-03-21T04:29:45.078-0400",
         "updated":"2014-03-21T07:53:59.038-0400",
         "priority":{
            "name":"Major"
         },
         "description":"Descr TEST\r\n",
         "subtasks":[

         ],
         "status":{
            "name":"Open",
            "statusCategory":{
               "key":"new",
               "colorName":"blue-gray",
               "name":"New"
            }
         },
         "workratio":4250,
         "project":{
            "id":"10101",
            "key":"XYZ",
            "name":"Mule Test"
         },
         "environment":null,
         "lastViewed":"2014-03-21T07:51:32.076-0400",
         "aggregateprogress":{
            "progress":30600,
            "total":30600,
            "percent":100
         },
         "comment":{
            "startAt":0,
            "maxResults":0,
            "total":0
         },
         "timeoriginalestimate":720,
         "resolution":null,
         "resolutiondate":null,
         "creator":{
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "displayName":"Integration User",
            "active":true
         },
         "aggregatetimeoriginalestimate":720,
         "duedate":null,
         "customfield_10021":"Not Started",
         "watches":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/XYZ-95/watchers",
            "watchCount":1,
            "isWatching":true
         },
         "worklog":{
            "startAt":0,
            "maxResults":20,
            "total":1,
            "worklogs":[
               {
                  "author":{
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "displayName":"Integration User"
                  },
                  "updateAuthor":{
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "displayName":"Integration User"
                  },
                  "comment":"",
                  "created":"2014-03-21T07:09:28.607-0400",
                  "updated":"2014-03-21T07:09:28.607-0400",
                  "started":"2014-03-21T07:09:00.000-0400",
                  "timeSpent":"1d 30m",
                  "timeSpentSeconds":30600,
                  "id":"10700"
               }
            ]
         },
         "assignee":null,
         "aggregatetimeestimate":0,
         "timeestimate":0,
         "customfield_10300":null,
         "aggregatetimespent":30600
      }
   },
   "changelog":null,
   "timestamp":1395402839041
}*/