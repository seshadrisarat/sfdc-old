/**
 * \author Vladimir Dobrelya
 * \date Mar 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The JIRA webhook listener class
 */
@RestResource(urlMapping='/JiraWebhookListener/*')
global without sharing class JiraWebhookListener {

    @HttpPost
    global static void doPost() {
        handlePost();
    }

    global static Integer handlePost() {
        JiraWrappers.REST_Response oResponse;

        try {
            RestContext.response.addHeader( 'Content-type', 'application/json' );
            System.debug( LoggingLevel.INFO, '#### request : ' + RestContext.request.requestBody.toString() );
            System.debug( LoggingLevel.INFO, '#### request : ' + RestContext.request.params );
            oResponse = ( JiraWrappers.REST_Response )JSON.deserialize( RestContext.request.requestBody.toString(), JiraWrappers.REST_Response.class );
        } catch ( Exception e ) {
            return setResponse( 400, e );
        }

        try {
            if ( oResponse.webhookEvent == 'jira:issue_created' ) {
                JiraMethods.upsertIssueWithMilestone( oResponse.issue );
                return setResponse( 201 ); // “Created” success code, for POST request.
            } else if ( oResponse.webhookEvent == 'jira:issue_updated' ) {
                if(oResponse.changelog != null && oResponse.changelog.isMilestoneUpdated()) JiraMethods.upsertIssueWithMilestone( oResponse.issue );
                else JiraMethods.upsertIssue( oResponse.issue );
                return setResponse( 201 ); // “Created” success code, for POST request.
            } else if ( oResponse.webhookEvent == 'jira:worklog_updated' ) {
                if ( JiraMethods.deleteWorklog( oResponse.issue, oResponse.changelog ) ) {
                    return setResponse( 204 ); // “No Content” success code, for DELETE request.
                }

                oResponse.issue.fields.worklog.worklogs = new List<JiraWrappers.REST_Worklog>{
                    getWorklog( oResponse.issue.key, oResponse.changelog.getChangedId(), oResponse.issue.fields.worklog.worklogs )
                };
                
                JiraMethods.upsertWorklogs( oResponse.issue );
                return setResponse( 201 ); // “Created” success code, for POST request.
            } else if ( oResponse.webhookEvent == 'jira:issue_deleted' ) {
                JiraMethods.deleteIssue( oResponse.issue.key );
                return setResponse( 204 ); // “No Content” success code, for DELETE request.
            } else {
                return setResponse( 415 ); // The entity in the request is in a format that’s not supported by the specified method.
            }
        } catch ( Exception e ) {
            return setResponse( 500, e );
        }
    }

    private static JiraWrappers.REST_Worklog getWorklog( String sIssueName, String sWorklogId, List<JiraWrappers.REST_Worklog> aWorklogs ) {
        for ( JiraWrappers.REST_Worklog oItem : aWorklogs ) {
            if ( oItem.id == sWorklogId ) {
                return oItem;
            }
        }

        JiraWrappers.REST_Worklog oResult;

        try {
            oResult = ( JiraWrappers.REST_Worklog ) JSON.deserialize( new JIRARequest( '/issue/' + sIssueName + '/worklog/' + sWorklogId ).sendRequest().getBody(), JiraWrappers.REST_Worklog.class );
        } catch ( Exception e ) {
            //psaUtils.debug( e );
        }
        
        return oResult;
    }

    private static Integer setResponse( Integer nStatusCode ) {
        return setResponse( nStatusCode, '{success:true}' );
    }

    private static Integer setResponse( Integer nStatusCode, Exception oException ) {
        //psaUtils.debug( oException );
        return setResponse( nStatusCode, '{success:false,exception:' + oException.getMessage() + ', line:' + oException.getLineNumber() + '}' );
    }

    private static Integer setResponse( Integer nStatusCode, String sMessage ) {
        RestContext.response.statusCode = nStatusCode;
        RestContext.response.responseBody = Blob.valueOf( sMessage );
        return nStatusCode;
    }
}

    /*
    { 
    "id": 2,
    "timestamp": "2009-09-09T00:08:36.796-0500",
    "issue": { 
        "expand":"renderedFields,names,schema,transitions,operations,editmeta,changelog",
        "id":"99291",
        "self":"https://jira.atlassian.com/rest/api/2/issue/99291",
        "key":"JRA-20002",
        "fields":{
            "summary":"I feel the need for speed",
            "created":"2009-12-16T23:46:10.612-0600",
            "description":"Make the issue nav load 10x faster",
            "labels":["UI", "dialogue", "move"],
            "priority": "Minor"
        }
    },
    "user": {
        "self":"https://jira.atlassian.com/rest/api/2/user?username=brollins",
        "name":"brollins",
        "emailAddress":"bryansemail at atlassian dot com",
        "avatarUrls":{
            "16x16":"https://jira.atlassian.com/secure/useravatar?size=small&avatarId=10605",
            "48x48":"https://jira.atlassian.com/secure/useravatar?avatarId=10605"
        },
        "displayName":"Bryan Rollins [Atlassian]",
        "active" : "true"
    },
    "changelog": {
        "items": [
            {
                "toString": "A new summary.",
                "to": null,
                "fromString": "What is going on here?????",
                "from": null,
                "fieldtype": "jira",
                "field": "summary"
            },
            {
                "toString": "New Feature",
                "to": "2",
                "fromString": "Improvement",
                "from": "4",
                "fieldtype": "jira",
                "field": "issuetype"
            }
        ],
        "id": 10124
    },
    "comment" : {
        "self":"https://jira.atlassian.com/rest/api/2/issue/10148/comment/252789",
        "id":"252789",
        "author":{
            "self":"https://jira.atlassian.com/rest/api/2/user?username=brollins",
            "name":"brollins",
            "emailAddress":"bryansemail@atlassian.com",
            "avatarUrls":{
                "16x16":"https://jira.atlassian.com/secure/useravatar?size=small&avatarId=10605",
                "48x48":"https://jira.atlassian.com/secure/useravatar?avatarId=10605"
            },
            "displayName":"Bryan Rollins [Atlassian]",
            "active":true
        },
        "body":"Just in time for AtlasCamp!",
        "updateAuthor":{
            "self":"https://jira.atlassian.com/rest/api/2/user?username=brollins",
            "name":"brollins",
            "emailAddress":"brollins@atlassian.com",
            "avatarUrls":{
                "16x16":"https://jira.atlassian.com/secure/useravatar?size=small&avatarId=10605",
                "48x48":"https://jira.atlassian.com/secure/useravatar?avatarId=10605"
            },
            "displayName":"Bryan Rollins [Atlassian]",
            "active":true
        },
        "created":"2011-06-07T10:31:26.805-0500",
        "updated":"2011-06-07T10:31:26.805-0500"
    },  
    "timestamp": "2011-06-07T10:31:26.805-0500",
    "webhookEvent": "jira:issue_updated"
}
    */