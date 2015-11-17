/**
 * \author Vladimir Dobrelya
 * \date Mar 21, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The JIRA webhook handler class
 */
public without sharing class JiraMethods {

    // --- ISSUE --- //
    public static void upsertIssue( JiraWrappers.REST_Issue oJiraIssue ) {
        upsertIssues( new List<JiraWrappers.REST_Issue>{ oJiraIssue } );
    }

    public static void upsertIssues( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        upsertIssues( aJiraIssues, getUserData( aJiraIssues ), getProjectIds( aJiraIssues ) );
    }

    public static void upsertIssues( List<JiraWrappers.REST_Issue> aJiraIssues, Map<String, ID> aUserData, Map<String, ID> aProjectIds ) {
        upsert createSFIssues( aJiraIssues, aUserData, aProjectIds ) Jira_Issue_Name__c;
    }
    
    public static void upsertIssueWithMilestone( JiraWrappers.REST_Issue oJiraIssue ) {
        List<JiraWrappers.REST_Issue> aJiraIssues = new List<JiraWrappers.REST_Issue>{ oJiraIssue };
        List<SF_Issue__c> issuesToUpsert = createSFIssues( aJiraIssues, getUserData( aJiraIssues ), getProjectIds( aJiraIssues ) );

        for(SF_Issue__c issue : issuesToUpsert) {
          try {
            if(String.isBlank(oJiraIssue.fields.customfield_11130) == false) issue.Milestone__c = oJiraIssue.fields.customfield_11130;
          } catch(Exception e) {
            system.debug(e.getMessage());
          }
        }
        
        upsert issuesToUpsert Jira_Issue_Name__c;
    }

    public static void deleteIssue( String sJiraIssueName ) {
        deleteIssues( new Set<String>{ sJiraIssueName } );
    }

    public static void deleteIssues( Set<String> aJiraIssueNames ) {
        List<Worklog__c> aWorklogs = new List<Worklog__c>();
        for ( Worklog__c oItem : [ SELECT IsDeleted__c FROM Worklog__c WHERE SF_Issue__r.Jira_Issue_Name__c IN :aJiraIssueNames AND IsDeleted = false ] ) {
            oItem.IsDeleted__c = true;
            aWorklogs.add( oItem );
        }

        List<SF_Issue__c> aIssues = new List<SF_Issue__c>();
        for ( SF_Issue__c oItem : [ SELECT IsDeleted__c FROM SF_Issue__c WHERE Jira_Issue_Name__c IN :aJiraIssueNames AND IsDeleted__c = false ] ) {
            oItem.IsDeleted__c = true;
            aIssues.add( oItem );
        }

        if ( !aIssues.isEmpty() ) {
            update aIssues;
        }
        if ( !aWorklogs.isEmpty() ) {
            update aWorklogs;
        }
    }


    // --- WORKLOG --- //
    public static void upsertWorklogs( JiraWrappers.REST_Issue oJiraIssue ) {
        upsertWorklogs( new List<JiraWrappers.REST_Issue>{ oJiraIssue }, null );
    }

    public static void upsertWorklogs( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        upsertWorklogs( aJiraIssues, null );
    }

    public static void upsertWorklogsWithoutCheck( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        upsertWorklogs( aJiraIssues, null, false );
    }

    public static void upsertWorklogs( List<JiraWrappers.REST_Issue> aJiraIssues, Set<String> aExistingIssues ) {
        upsertWorklogs( aJiraIssues, aExistingIssues, true );
    }

    public static void upsertWorklogs( List<JiraWrappers.REST_Issue> aJiraIssues, Set<String> aExistingIssues, Boolean bCheckExisting ) {
        Map<String, ID> aUserData = getUserData( aJiraIssues );
        Map<String, ID> aProjectIds = getProjectIds( aJiraIssues );
        if ( bCheckExisting ) {
            insertNotExistingIssues( aJiraIssues, aExistingIssues, aUserData, aProjectIds );
        }
        Database.upsert(createWorklogs( aJiraIssues, aUserData, aProjectIds ), Worklog__c.Fields.JIRA_ID__c, false);
    }

    public static Boolean deleteWorklog( JiraWrappers.REST_Issue oJiraIssue, JiraWrappers.REST_ChangelogTracking oChangeLog ) {
        if ( oChangeLog == null ) {
            return false;
        }

        if ( deleteWorklogs( oChangeLog.getDeletedIds() ) ) {
            upsertIssue( oJiraIssue );
            return true;
        }

        return false;
    }

    public static Boolean deleteWorklog( String sJiraId ) {
        return deleteWorklogs( new Set<String>{ sJiraId } );
    }

    public static Boolean deleteWorklogs( Set<String> aJiraIds ) {
        if ( aJiraIds.isEmpty() ) {
            return false;
        }

        List<Worklog__c> aWorklogs = new List<Worklog__c>();
        for ( Worklog__c oItem : [ SELECT IsDeleted__c FROM Worklog__c WHERE JIRA_ID__c IN :aJiraIds AND IsDeleted = false ] ) {
            oItem.IsDeleted__c = true;
            aWorklogs.add( oItem );
        }

        if ( !aWorklogs.isEmpty() ) {
            update aWorklogs;
            return true;
        }

        return false;
    }


    public static List<SF_Issue__c> createSFIssues( List<JiraWrappers.REST_Issue> aJiraIssues, Map<String, ID> aUserData, Map<String, ID> aProjectIds ) {
        List<SF_Issue__c> aResult = new List<SF_Issue__c>();

        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            aResult.add(
                createSFIssue( oItem,
                    aUserData.get( oItem.fields.reporter.emailAddress ),
                    oItem.fields.assignee != null ? aUserData.get( oItem.fields.assignee.emailAddress ) : null,
                    aProjectIds.get( oItem.fields.project.key )
                )
            );
        }

        return aResult;
    }

    public static List<Worklog__c> createWorklogs( List<JiraWrappers.REST_Issue> aJiraIssues, Map<String, ID> aUserData, Map<String, ID> aProjectIds ) {
        List<Worklog__c> aResult = new List<Worklog__c>();

        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            aResult.addAll( createWorklogs( oItem.key, oItem.fields.worklog.worklogs, aUserData, aProjectIds.get( oItem.fields.project.key ) ) );
        }

        return aResult;
    }

    public static List<Worklog__c> createWorklogs( String sJiraIssueName, List<JiraWrappers.REST_Worklog> aWorklogs, Map<String, ID> aUserData, ID idProject ) {
        List<Worklog__c> aResult = new List<Worklog__c>();

        for ( JiraWrappers.REST_Worklog oItem : aWorklogs ) {
            aResult.add( createWorklog( sJiraIssueName, oItem, aUserData.get( oItem.author.emailAddress ), idProject ) );
        }

        return aResult;
    }

    private static SF_Issue__c createSFIssue( JiraWrappers.REST_Issue oJiraIssue, ID idReporter, ID idAssignee, ID idProject ) {
        return new SF_Issue__c(
            OwnerId = SL_Settings.idJiraIntegrationUser,
            Name = oJiraIssue.key,
            Id__c = oJiraIssue.id,
            Worklogs_Needed__c = false,
            Jira_Issue_Name__c = oJiraIssue.key,
            Subject__c = oJiraIssue.fields.summary == null ? null : oJiraIssue.fields.summary.left( 254 ),
            Description__c = oJiraIssue.fields.description == null ? null : oJiraIssue.fields.description.left( 32767 ),
            Time_Spent_JIRA__c = oJiraIssue.fields.timetracking.timeSpentSeconds,
            Original_Estimate__c = oJiraIssue.fields.timetracking.originalEstimateSeconds,
            Remaining_Estimate__c = oJiraIssue.fields.timetracking.remainingEstimateSeconds,
            OA_Task_Id__c = oJiraIssue.fields.customfield_10233,
            JIRA_Project_Name__c = oJiraIssue.fields.project.key,
            Project__c = idProject,
            Assignee__c = idAssignee,
            Reporter__c = idReporter//,
            /*Type__c = oJiraIssue.fields.issuetype.name,
            Subtask__c = oJiraIssue.fields.issuetype.subtask,
            Priority__c = oJiraIssue.fields.priority.name,
            Status__c = oJiraIssue.fields.status.name,
            Progress__c = oJiraIssue.fields.progress.progress,
            Total__c = oJiraIssue.fields.progress.total,
            Percent__c = oJiraIssue.fields.progress.percent,*/
            /*Milestone__c = oJiraIssue.fields.customfield_11130
            Milestone__r = getMilestone( idProject, oJiraIssue.fields.customfield_10233, aOpenAirTaskIds )
            */
        );
    }

    private static Worklog__c createWorklog( String sJiraIssueName, JiraWrappers.REST_Worklog oWorklog, ID idAuthor, ID idProject ) {
        return new Worklog__c(
            JIRA_ID__c = oWorklog.id,
            JIRA_Contact__c = idAuthor,
            JIRA_Issue__c = sJiraIssueName,
            SF_Issue__r = new SF_Issue__c( Jira_Issue_Name__c = sJiraIssueName ),
            PSA_Project__c = idProject,
            JIRA_User_Name__c = oWorklog.author.emailAddress,
            JIRA_Notes__c = oWorklog.comment,
            JIRA_Start_Date__c = oWorklog.started,
            Jira_Created__c = oWorklog.created,
            Jira_Updated__c = oWorklog.updated,
            Hours__c = convertSecondsToHours( oWorklog.timeSpentSeconds ),
            Seconds__c = oWorklog.timeSpentSeconds,
            PSA_Integration_Status__c = 'PENDING'
        );
    }

    /*private static Map<String, ID> getUserData( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        Set<String> aUserNames = new Set<String>();

        for ( JiraWrappers.REST_Issue oJiraIssue : aJiraIssues ) {
            if ( oJiraIssue.fields.assignee != null ) {
                aUserNames.add( oJiraIssue.fields.assignee.name );
            }
            aUserNames.add( oJiraIssue.fields.reporter.name );

            if ( oJiraIssue.fields.worklog != null ) {
                for ( JiraWrappers.REST_Worklog oWorklog : oJiraIssue.fields.worklog.worklogs ) {
                    aUserNames.add( oWorklog.author.name );
                }
            }
        }

        return getUserData( aUserNames );
    }

    private static Map<String, ID> getUserData( Set<String> aJiraUserNames ) {
        Map<String, ID> aResult = new Map<String, ID>();

        for ( Contact oItem : [
            SELECT Id, JIRA_User_Name__c
            FROM Contact
            WHERE RecordType.DeveloperName = 'Employee' AND 
                JIRA_User_Name__c IN :aJiraUserNames ]
        ) {
            aResult.put( oItem.JIRA_User_Name__c, oItem.Id );   
        }

        return aResult;
    }*/

    private static Map<String, ID> getUserData( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        Set<String> aUserEmails = new Set<String>();

        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            if ( oItem.fields.assignee != null ) {
                aUserEmails.add( oItem.fields.assignee.emailAddress );
            }
            aUserEmails.add( oItem.fields.reporter.emailAddress );

            if ( oItem.fields.worklog != null ) {
                for ( JiraWrappers.REST_Worklog oWorklog : oItem.fields.worklog.worklogs ) {
                    aUserEmails.add( oWorklog.author.emailAddress );
                }
            }
        }

        return getUserData( aUserEmails );
    }

    public static Map<String, ID> getUserData( Set<String> aUserEmails ) {
        Map<String, ID> aResult = new Map<String, ID>();

        for ( Contact oItem : [
            SELECT Id, Email, Personal_Email__c, JIRA_User_Name__c
            FROM Contact
            WHERE RecordType.DeveloperName = 'Employee' AND 
                ( Email IN :aUserEmails OR Personal_Email__c IN :aUserEmails ) ]
        ) {
            if ( aUserEmails.contains( oItem.Email ) ) {
                aResult.put( oItem.Email, oItem.Id );
            } else {
                aResult.put( oItem.Personal_Email__c, oItem.Id );
            }
        }

        return aResult;
    }

    

    /*private static pse__Milestone__c getMilestone( ID idProject, String sOpenAirTaskIdNumber, Map<ID, Map<String, ID>> aOpenAirTaskIds ) {
        if ( idProject == null || String.isBlank( sOpenAirTaskIdNumber ) || aOpenAirTaskIds == null ||
            !aOpenAirTaskIds.containsKey( idProject ) || !aOpenAirTaskIds.get( idProject ).containsKey( sOpenAirTaskIdNumber ) ) {
            return null;
        }

        return new pse__Milestone__c( Legacy_OA_Project_Task_Id__c = aOpenAirTaskIds.get( idProject ).get( sOpenAirTaskIdNumber ) );
    }*/

    private static Map<String, ID> getProjectIds( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        Map<String, ID> aResult = new Map<String, ID>();

        for ( pse__Proj__c oItem : [ SELECT Id, JIRA_Project_Name__c FROM pse__Proj__c WHERE JIRA_Project_Name__c IN :getProjectNames( aJiraIssues ) ] ) {
            aResult.put( oItem.JIRA_Project_Name__c, oItem.Id );
        }

        return aResult;
    }

    private static Set<String> getProjectNames( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        Set<String> aResult = new Set<String>();

        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            aResult.add( getProjectName( oItem.fields.project.key ) );
        }

        return aResult;
    }

    public static String getProjectName( String sRepositorySlug ) {
        if ( sRepositorySlug.contains( '-' ) ) {
        	//didn't work with repositories with dashes
            //return sRepositorySlug.left( sRepositorySlug.indexOf( '-' ) + 1 );
            return sRepositorySlug.left( sRepositorySlug.indexOf( '-' ));
        }
        return sRepositorySlug;
    }

    private static void insertNotExistingIssues( List<JiraWrappers.REST_Issue> aJiraIssues, Set<String> aExistingIssues, Map<String, ID> aUserData, Map<String, ID> aProjectIds ) {
        if ( aExistingIssues == null ) {
            aExistingIssues = new Set<String>();
            Set<String> aJiraIssueNames = getIssueNames( aJiraIssues );

            for ( SF_Issue__c oItem : [ SELECT Jira_Issue_Name__c FROM SF_Issue__c WHERE Jira_Issue_Name__c IN :aJiraIssueNames ] ) {
                aExistingIssues.add( oItem.Jira_Issue_Name__c );
            }

            if ( aExistingIssues.containsAll( aJiraIssueNames ) ) {
                return;
            }
        }

        List<JiraWrappers.REST_Issue> aJiraIssuesToUpsert = new List<JiraWrappers.REST_Issue>();
        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            if ( !aExistingIssues.contains( oItem.key ) ) {
                aJiraIssuesToUpsert.add( oItem );
            }
        }

        upsertIssues( aJiraIssuesToUpsert, aUserData, aProjectIds );
    }

    public static Set<String> getIssueNames( List<JiraWrappers.REST_Issue> aJiraIssues ) {
        Set<String> aResult = new Set<String>();

        for ( JiraWrappers.REST_Issue oItem : aJiraIssues ) {
            aResult.add( oItem.key );
        }

        return aResult;
    }

    private static Decimal convertSecondsToHours( Integer nSeconds ) {
        if ( nSeconds == null || nSeconds == 0 ) {
            return 0;
        }
        return nSeconds / 60.0 / 60.0;
    }
}

    /*
{
   "webhookEvent":"jira:worklog_updated",
   "user":{
      "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
      "name":"Integration",
      "emailAddress":"julia@silverlinecrm.com",
      "avatarUrls":{
         "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
         "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
         "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
         "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
      },
      "displayName":"Integration User",
      "active":true
   },
   "issue":{
      "id":"11001",
      "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001",
      "key":"XYZ-95",
      "fields":{
         "summary":"REST TEST",
         "progress":{
            "progress":12600,
            "total":43200,
            "percent":29
         },
         "timetracking":{
            "originalEstimate":"12m",
            "remainingEstimate":"1d 30m",
            "timeSpent":"3h 30m",
            "originalEstimateSeconds":720,
            "remainingEstimateSeconds":30600,
            "timeSpentSeconds":12600
         },
         "issuetype":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issuetype/1",
            "id":"1",
            "description":"A problem which impairs or prevents the functions of the product.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/issuetypes/bug.png",
            "name":"Bug",
            "subtask":false
         },
         "timespent":12600,
         "reporter":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "created":"2014-03-21T04:29:45.078-0400",
         "updated":"2014-03-21T11:13:21.563-0400",
         "priority":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/priority/3",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/priorities/major.png",
            "name":"Major",
            "id":"3"
         },
         "description":"Descr TEST\r\n",
         "customfield_10001":null,
         "customfield_10002":null,
         "customfield_10003":null,
         "issuelinks":[

         ],
         "customfield_10000":"3_*:*_1_*:*_37396_*&#124;*_1_*:*_1_*:*_14370299_*&#124;*_5_*:*_1_*:*_0",
         "subtasks":[

         ],
         "customfield_10008":null,
         "customfield_10007":null,
         "status":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/status/5",
            "description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/statuses/resolved.png",
            "name":"Resolved",
            "id":"5",
            "statusCategory":{
               "self":"https://silverlinetest.atlassian.net/rest/api/2/statuscategory/3",
               "id":3,
               "key":"done",
               "colorName":"green",
               "name":"Complete"
            }
         },
         "customfield_10006":"540",
         "labels":[

         ],
         "workratio":1750,
         "project":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/project/10101",
            "id":"10101",
            "key":"XYZ",
            "name":"Mule Test",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/projectavatar?size=xsmall&pid=10101&avatarId=10011",
               "24x24":"https://silverlinetest.atlassian.net/secure/projectavatar?size=small&pid=10101&avatarId=10011",
               "32x32":"https://silverlinetest.atlassian.net/secure/projectavatar?size=medium&pid=10101&avatarId=10011",
               "48x48":"https://silverlinetest.atlassian.net/secure/projectavatar?pid=10101&avatarId=10011"
            }
         },
         "environment":null,
         "customfield_10014":null,
         "customfield_10015":null,
         "lastViewed":"2014-03-21T11:13:20.071-0400",
         "aggregateprogress":{
            "progress":12600,
            "total":43200,
            "percent":29
         },
         "customfield_10012":null,
         "components":[

         ],
         "customfield_10013":null,
         "comment":{
            "startAt":0,
            "maxResults":0,
            "total":0,
            "comments":[

            ]
         },
         "timeoriginalestimate":720,
         "customfield_10017":null,
         "customfield_10016":null,
         "customfield_10019":null,
         "customfield_10018":null,
         "votes":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/XYZ-95/votes",
            "votes":0,
            "hasVoted":false
         },
         "fixVersions":[

         ],
         "resolution":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/resolution/1",
            "id":"1",
            "description":"A fix for this issue is checked into the tree and tested.",
            "name":"Fixed"
         },
         "resolutiondate":"2014-03-21T08:29:52.673-0400",
         "creator":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "aggregatetimeoriginalestimate":720,
         "duedate":null,
         "customfield_10020":null,
         "customfield_10021":"Not Started",
         "watches":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/XYZ-95/watchers",
            "watchCount":1,
            "isWatching":true
         },
         "worklog":{
            "startAt":0,
            "maxResults":20,
            "total":3,
            "worklogs":[
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10701",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"",
                  "created":"2014-03-21T08:29:52.672-0400",
                  "updated":"2014-03-21T08:29:52.672-0400",
                  "started":"2014-03-21T08:29:00.000-0400",
                  "timeSpent":"2h",
                  "timeSpentSeconds":7200,
                  "id":"10701"
               },
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10702",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"description",
                  "created":"2014-03-21T09:59:36.054-0400",
                  "updated":"2014-03-21T09:59:36.054-0400",
                  "started":"2014-03-21T09:59:00.000-0400",
                  "timeSpent":"1h 30m",
                  "timeSpentSeconds":5400,
                  "id":"10702"
               },
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10703",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"asd",
                  "created":"2014-03-21T10:06:04.396-0400",
                  "updated":"2014-03-21T10:06:04.396-0400",
                  "started":"2014-03-21T10:05:00.000-0400",
                  "timeSpent":"2h",
                  "timeSpentSeconds":7200,
                  "id":"10703"
               }
            ]
         },
         "assignee":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "attachment":[

         ],
         "aggregatetimeestimate":30600,
         "versions":[

         ],
         "timeestimate":30600,
         "customfield_10300":null,
         "aggregatetimespent":12600
      }
   },
   "changelog":{
      "id":"11118",
      "items":[
         {
            "field":"timeestimate",
            "fieldtype":"jira",
            "from":"23400",
            "fromString":"23400",
            "to":"30600",
            "toString":"30600"
         },
         {
            "field":"timespent",
            "fieldtype":"jira",
            "from":"19800",
            "fromString":"19800",
            "to":"12600",
            "toString":"12600"
         },
         {
            "field":"WorklogId",
            "fieldtype":"jira",
            "from":"10703",
            "fromString":"10703",
            "to":null,
            "toString":null
         },
         {
            "field":"WorklogTimeSpent",
            "fieldtype":"jira",
            "from":"7200",
            "fromString":"2 hours",
            "to":null,
            "toString":null
         }
      ]
   },
   "timestamp":1395414801573
}
    */



/*  DELETE

{
   "webhookEvent":"jira:worklog_updated",
   "user":{
      "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
      "name":"Integration",
      "emailAddress":"julia@silverlinecrm.com",
      "avatarUrls":{
         "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
         "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
         "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
         "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
      },
      "displayName":"Integration User",
      "active":true
   },
   "issue":{
      "id":"11001",
      "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001",
      "key":"XYZ-95",
      "fields":{
         "summary":"REST TEST",
         "progress":{
            "progress":16200,
            "total":43200,
            "percent":37
         },
         "timetracking":{
            "originalEstimate":"12m",
            "remainingEstimate":"7h 30m",
            "timeSpent":"4h 30m",
            "originalEstimateSeconds":720,
            "remainingEstimateSeconds":27000,
            "timeSpentSeconds":16200
         },
         "issuetype":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issuetype/1",
            "id":"1",
            "description":"A problem which impairs or prevents the functions of the product.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/issuetypes/bug.png",
            "name":"Bug",
            "subtask":false
         },
         "timespent":16200,
         "reporter":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "created":"2014-03-21T04:29:45.078-0400",
         "updated":"2014-03-24T07:31:55.414-0400",
         "priority":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/priority/3",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/priorities/major.png",
            "name":"Major",
            "id":"3"
         },
         "description":"Descr TEST\r\n",
         "customfield_10001":null,
         "customfield_10002":null,
         "customfield_10003":null,
         "issuelinks":[

         ],
         "customfield_10000":"3_*:*_1_*:*_37396_*&#124;*_1_*:*_1_*:*_14370299_*&#124;*_5_*:*_1_*:*_0",
         "subtasks":[

         ],
         "customfield_10008":null,
         "customfield_10007":null,
         "status":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/status/5",
            "description":"A resolution has been taken, and it is awaiting verification by reporter. From here issues are either reopened, or are closed.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/statuses/resolved.png",
            "name":"Resolved",
            "id":"5",
            "statusCategory":{
               "self":"https://silverlinetest.atlassian.net/rest/api/2/statuscategory/3",
               "id":3,
               "key":"done",
               "colorName":"green",
               "name":"Complete"
            }
         },
         "customfield_10006":"540",
         "labels":[

         ],
         "workratio":2250,
         "project":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/project/10101",
            "id":"10101",
            "key":"XYZ",
            "name":"Mule Test",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/projectavatar?size=xsmall&pid=10101&avatarId=10011",
               "24x24":"https://silverlinetest.atlassian.net/secure/projectavatar?size=small&pid=10101&avatarId=10011",
               "32x32":"https://silverlinetest.atlassian.net/secure/projectavatar?size=medium&pid=10101&avatarId=10011",
               "48x48":"https://silverlinetest.atlassian.net/secure/projectavatar?pid=10101&avatarId=10011"
            }
         },
         "environment":null,
         "customfield_10014":null,
         "customfield_10015":null,
         "lastViewed":"2014-03-24T07:31:52.520-0400",
         "aggregateprogress":{
            "progress":16200,
            "total":43200,
            "percent":37
         },
         "customfield_10012":null,
         "components":[

         ],
         "customfield_10013":null,
         "comment":{
            "startAt":0,
            "maxResults":0,
            "total":0,
            "comments":[

            ]
         },
         "timeoriginalestimate":720,
         "customfield_10017":null,
         "customfield_10016":null,
         "customfield_10019":null,
         "customfield_10018":null,
         "votes":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/XYZ-95/votes",
            "votes":0,
            "hasVoted":false
         },
         "fixVersions":[

         ],
         "resolution":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/resolution/1",
            "id":"1",
            "description":"A fix for this issue is checked into the tree and tested.",
            "name":"Fixed"
         },
         "resolutiondate":"2014-03-21T08:29:52.673-0400",
         "creator":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "aggregatetimeoriginalestimate":720,
         "duedate":null,
         "customfield_10020":null,
         "customfield_10021":"Not Started",
         "watches":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/XYZ-95/watchers",
            "watchCount":1,
            "isWatching":true
         },
         "worklog":{
            "startAt":0,
            "maxResults":20,
            "total":3,
            "worklogs":[
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10701",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"11111",
                  "created":"2014-03-21T08:29:52.672-0400",
                  "updated":"2014-03-24T07:31:55.409-0400",
                  "started":"2014-03-21T08:29:00.000-0400",
                  "timeSpent":"2h",
                  "timeSpentSeconds":7200,
                  "id":"10701"
               },
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10702",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"description",
                  "created":"2014-03-21T09:59:36.054-0400",
                  "updated":"2014-03-21T09:59:36.054-0400",
                  "started":"2014-03-21T09:59:00.000-0400",
                  "timeSpent":"1h 30m",
                  "timeSpentSeconds":5400,
                  "id":"10702"
               },
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10705",
                  "author":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "updateAuthor":{
                     "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
                     "name":"Integration",
                     "emailAddress":"julia@silverlinecrm.com",
                     "avatarUrls":{
                        "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
                        "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
                        "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
                        "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
                     },
                     "displayName":"Integration User",
                     "active":true
                  },
                  "comment":"aaa",
                  "created":"2014-03-21T11:35:02.567-0400",
                  "updated":"2014-03-21T11:35:02.567-0400",
                  "started":"2014-03-21T11:34:00.000-0400",
                  "timeSpent":"1h",
                  "timeSpentSeconds":3600,
                  "id":"10705"
               }
            ]
         },
         "assignee":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/user?username=Integration",
            "name":"Integration",
            "emailAddress":"julia@silverlinecrm.com",
            "avatarUrls":{
               "16x16":"https://silverlinetest.atlassian.net/secure/useravatar?size=xsmall&avatarId=10122",
               "24x24":"https://silverlinetest.atlassian.net/secure/useravatar?size=small&avatarId=10122",
               "32x32":"https://silverlinetest.atlassian.net/secure/useravatar?size=medium&avatarId=10122",
               "48x48":"https://silverlinetest.atlassian.net/secure/useravatar?avatarId=10122"
            },
            "displayName":"Integration User",
            "active":true
         },
         "attachment":[

         ],
         "aggregatetimeestimate":27000,
         "versions":[

         ],
         "timeestimate":27000,
         "customfield_10300":null,
         "aggregatetimespent":16200
      }
   },
   "changelog":{
      "id":"11202",
      "items":[
         {
            "field":"WorklogId",
            "fieldtype":"jira",
            "from":"10701",
            "fromString":"10701",
            "to":null,
            "toString":null
         }
      ]
   },
   "timestamp":1395660715419
}

*/