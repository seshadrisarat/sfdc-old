/**
 * \author Vladimir Dobrelya
 * \date Mar 21, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief JIRA webhook wrappers
 */
public with sharing class JiraWrappers {
	
	public static String sJqlFields = 'id,key,worklog,assignee,reporter,description,customfield_10233,summary,timetracking,project';
	
    /* --- REQUEST --- */

    public class REST_Request {
        public REST_RequestFields fields;

        public REST_Request( String project, String issueType, String summary, String description, String assignee, String reporter, String milestoneId  ) {
            this.fields = new REST_RequestFields( project, issueType, summary, description, assignee, reporter, milestoneId );
        }
    }

    public class REST_RequestFields {
        public REST_Project project;
        public REST_IssueType issuetype;
        public String summary;
        public String description;
        //for prod JIRA
        public String customfield_11130;
        //public String customfield_10500;
        public REST_User assignee;
        public REST_User reporter;

        public REST_RequestFields( String project, String issueType, String summary, String description, String assignee, String reporter, String milestoneId ) {
            this.project = new REST_Project( project );
            this.issueType = new REST_IssueType( issueType );
            this.summary = summary;
            this.description = description;
            //for prod JIRA
            this.customfield_11130 = milestoneId;
            //for test JIRA
            //this.customfield_10500 = milestoneId;
            this.assignee = new REST_User( assignee );
            this.reporter = new REST_User( reporter );
        }
    }

    /* --- RESPONSE --- */

    public class REST_Response {
        public String id;
        public REST_Issue issue;
        public REST_ChangelogTracking changelog;
        public String webhookEvent;
    }

    public class HTTP_Response {
        public List<REST_Issue> issues;
        public Integer maxResults; 
        public Integer startAt;
        public Integer total;
    }

    public class REST_Issue {
        public String id;
        public String key;
        public REST_IssueFields fields;
    }

    public class REST_IssueFields {
        public REST_Project project;
        public String summary;
        public String description;
        public REST_User assignee;
        public REST_User reporter;

        public REST_WorklogTracking worklog;
        public REST_Timetracking timetracking;
        public String customfield_10233;
        public String customfield_11130;

        public REST_IssueStatus status;
        public REST_IssuePriority priority;
        public REST_IssueProgress progress;
        public REST_IssueType issuetype;
    }
    
    public class REST_IssueStatus {
        public String name;
    }

    public class REST_IssuePriority {
        public String name;
    }

    public class REST_IssueProgress {
        public Long progress;
        public Long total;
        public Long percent;
    }

    public class REST_Timetracking {
        public Integer timeSpentSeconds;
        public Integer originalEstimateSeconds;
        public Integer remainingEstimateSeconds;
    }

    public class REST_IssueType {
        public String name;
        public Boolean subtask;

        public REST_IssueType() { }
        public REST_IssueType( String name ) {
            this.name = name;
        }
    }

    public class REST_User {
        public String name;
        public String emailAddress;

        public REST_User() { }
        public REST_User( String name ) {
            this.name = name;
        }       
    }

    public class REST_Project {
        public String key;
        public String id;

        public REST_Project() { }
        public REST_Project( String key ) {
            this.key = key;
        }
    }

    public class REST_WorklogTracking {
        public List<REST_Worklog> worklogs;
        public Integer total;
    }

    public class REST_Worklog {
        public String id;
        public REST_User author;
        public REST_User updateAuthor;
        public String comment;
        public DateTime created;
        public DateTime updated;
        public DateTime started;
        public String timeSpent;
        public Integer timeSpentSeconds;
    }

    public class REST_ChangelogTracking {
        public List<REST_Changelog> items;

        public Set<String> getDeletedIds() {
            Set<String> aResult = new Set<String>();
            if ( this.items == null ) {
                return aResult;
            }

            Map<String, REST_Changelog> aChangeLogs = this.convertItemsToMap();
            if ( aChangeLogs.containsKey( 'WorklogTimeSpent' ) && aChangeLogs.get( 'WorklogTimeSpent' ).fromString != null && aChangeLogs.get( 'WorklogTimeSpent' ).toString == null &&
                aChangeLogs.containsKey( 'WorklogId' ) && aChangeLogs.get( 'WorklogId' ).fromString != null && aChangeLogs.get( 'WorklogId' ).toString == null
            ) {
                aResult.add( aChangeLogs.get( 'WorklogId' ).fromString );
            }

            return aResult;
        }

        public String getChangedId() {
            Map<String, REST_Changelog> aChangeLogs = this.convertItemsToMap();
            if ( aChangeLogs.containsKey( 'WorklogId' ) && aChangeLogs.get( 'WorklogId' ).fromString != null ) {
                return aChangeLogs.get( 'WorklogId' ).fromString;
            }
            return null;
        }

        public Boolean isMilestoneUpdated() {
            Map<String, REST_Changelog> aChangeLogs = this.convertItemsToMap();
            
            if( aChangeLogs.containsKey('customfield_11130') ) return true;
            return false;
        }

        private Map<String, REST_Changelog> convertItemsToMap() {
            Map<String, REST_Changelog> aResult = new Map<String, REST_Changelog>();
            if ( this.items != null ) {
                for ( REST_Changelog oItem : this.items ) {
                    aResult.put( oItem.field, oItem );
                }
            }
            return aResult;
        }
    }

    public class REST_Changelog {
        public String field;
        public String fromString;
        public String toString;
    }

}


    /*
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
    */



    /*"worklog":{
            "startAt":0,
            "maxResults":20,
            "total":1,
            "worklogs":[
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10700",
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
                  "created":"2014-03-21T07:09:28.607-0400",
                  "updated":"2014-03-21T07:09:28.607-0400",
                  "started":"2014-03-21T07:09:00.000-0400",
                  "timeSpent":"1d 30m",
                  "timeSpentSeconds":30600,
                  "id":"10700"
               }
            ]
         },*/


/*{
   "webhookEvent":"jira:issue_updated",
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
            "progress":30600,
            "total":30600,
            "percent":100
         },
         "timetracking":{
            "originalEstimate":"12m",
            "remainingEstimate":"0m",
            "timeSpent":"1d 30m",
            "originalEstimateSeconds":720,
            "remainingEstimateSeconds":0,
            "timeSpentSeconds":30600
         },
         "issuetype":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/issuetype/1",
            "id":"1",
            "description":"A problem which impairs or prevents the functions of the product.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/issuetypes/bug.png",
            "name":"Bug",
            "subtask":false
         },
         "timespent":30600,
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
         "updated":"2014-03-21T07:53:59.038-0400",
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
         "customfield_10000":null,
         "subtasks":[

         ],
         "customfield_10008":null,
         "customfield_10007":null,
         "status":{
            "self":"https://silverlinetest.atlassian.net/rest/api/2/status/1",
            "description":"The issue is open and ready for the assignee to start work on it.",
            "iconUrl":"https://silverlinetest.atlassian.net/images/icons/statuses/open.png",
            "name":"Open",
            "id":"1",
            "statusCategory":{
               "self":"https://silverlinetest.atlassian.net/rest/api/2/statuscategory/2",
               "id":2,
               "key":"new",
               "colorName":"blue-gray",
               "name":"New"
            }
         },
         "customfield_10006":"540",
         "labels":[

         ],
         "workratio":4250,
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
         "lastViewed":"2014-03-21T07:51:32.076-0400",
         "aggregateprogress":{
            "progress":30600,
            "total":30600,
            "percent":100
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
         "resolution":null,
         "resolutiondate":null,
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
            "total":1,
            "worklogs":[
               {
                  "self":"https://silverlinetest.atlassian.net/rest/api/2/issue/11001/worklog/10700",
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
         "attachment":[

         ],
         "aggregatetimeestimate":0,
         "versions":[

         ],
         "timeestimate":0,
         "customfield_10300":null,
         "aggregatetimespent":30600
      }
   },
   "changelog":{
      "id":"11109",
      "items":[
         {
            "field":"description",
            "fieldtype":"jira",
            "from":null,
            "fromString":"Descr TEST 1\r\n",
            "to":null,
            "toString":"Descr TEST\r\n"
         }
      ]
   },
   "timestamp":1395402839041
}
*/