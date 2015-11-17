/**
 * \author Vladimir Dobrelya
 * \date Mar 20, 2014
 * \see https://silverline.jira.com/browse/SLFF-42
 * \brief The class contains methods to create appropriate SF records for commits
 */
public without sharing class BitbucketMethods {
    
    private static final Pattern oUserEmailPattern = Pattern.compile( '(<[-0-9a-zA-Z.+_]+@[-0-9a-zA-Z.+_]+\\.[a-zA-Z]{2,4}>)' ); // Pattern for Bitbucket JSON
    private static final Pattern oIssueNamePattern = Pattern.compile( '^([A-Z]+-\\d+)' );

    public static List<SF_Commit__c> createRecords( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        insertNotExistingIssues( getJiraIssueNames( aCommits ) );
        return upsertCommits( createSFCommits( aCommits ) );
    }

    public static List<SF_Commit__c> upsertCommits( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        return upsertCommits( createSFCommits( aCommits ) );
    }

    public static List<SF_Commit__c> upsertCommits( List<SF_Commit__c> aCommits ) {
        if ( !aCommits.isEmpty() ) {
            //upsert aCommits Hash__c;
            Schema.SObjectField hash = SF_Commit__c.Fields.Hash__c;
            List<Database.upsertResult> results = Database.upsert(aCommits,hash,false);
		    for(Database.upsertResult result:results) {
		         if (!result.isSuccess()) {
		              system.debug('Error: ' + result);
		         }
		    }
        }
        return aCommits;
    }

    public static List<SF_Commit__c> createSFCommits( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        List<SF_Commit__c> aResult = new List<SF_Commit__c>();

        Map<String, ID> aUserData = getUserData( aCommits );
		string linktobitbucket = '';
		SF_Commit__c curSFCommit;
        for ( BitBucketWrappers.Abs_Commit oItem : aCommits ) {
        	linktobitbucket =  (oItem.links!=null) ? oItem.links.self.href : SL_Settings.urlBitbucket + '/' + oItem.repository.name.toLowerCase() + '/commits/' + oItem.getHash();
        	if (oItem.xdate==null) oItem.xdate = datetime.now();
        	aResult.add( new SF_Commit__c(
                    OwnerId = SL_Settings.idJiraIntegrationUser,
                    Hash__c = oItem.getHash(),
                    Message__c = oItem.getMessage(),
                    Repository__c = oItem.repository.name,
                    Project__r = getProject( oItem.repository.name ),
                    Author__c = oItem.getAuthor(),
                    Date__c = oItem.xdate,
                    Commit_User__c = aUserData.get( getUserEmail( oItem.getAuthor() ) ),
                    SF_Issue__r = getSFIssue( getIssueName( oItem.getMessage() ) ),
                    Link_to_Bitbucket__c = linktobitbucket
                ) 
           );
        }
        return aResult;
    }

    private static pse__Proj__c getProject( String sRepository ) {
        if ( String.isBlank( sRepository ) ) {
            return null;
        }
        return new pse__Proj__c( JIRA_Project_Name__c = JiraMethods.getProjectName( sRepository ) );
    }

    public static void setRepository( String sRepository, List<BitBucketWrappers.REST_Commit> aCommits ) {
        for ( BitBucketWrappers.REST_Commit oItem : aCommits ) {
            setRepository( sRepository, oItem );
        }
    }
    
    public static void setRepository( String sRepository, BitBucketWrappers.REST_Commit oCommit ) {
        oCommit.repository = new BitBucketWrappers.REST_Repository();
        oCommit.repository.name = sRepository;
    }

    /*private static Set<String> getHashes( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        Set<String> aResult = new Set<String>();

        for ( BitBucketWrappers.Abs_Commit oItem : aCommits ) {
            aResult.add( oItem.getHash() );
        }

        return aResult;
    }

    public static Set<String> getExistingCommits( String sProject ) {
        Set<String> aResult = new Set<String>();

        for ( SF_Commit__c oItem : [ SELECT Hash__c FROM SF_Commit__c WHERE SF_Issue__r.Project__r.Jira_Project_Name__c = :sProject ] ) {
            aResult.add( oItem.Hash__c );
        }

        return aResult;
    }*/

    private static SF_Issue__c getSFIssue( String sJiraIssueName ) {
        if ( String.isBlank( sJiraIssueName ) ) {
            return null;
        }
        return new SF_Issue__c( Jira_Issue_Name__c = sJiraIssueName );
    }

    public static Set<String> getExistingIssueNames( Set<String> aJiraIssueNames ) {
        Set<String> aResult = new Set<String>();

        for ( SF_Issue__c oItem : [ SELECT Jira_Issue_Name__c FROM SF_Issue__c WHERE Jira_Issue_Name__c IN :aJiraIssueNames ] ) {
            aResult.add( oItem.Jira_Issue_Name__c );
        }

        return aResult;
    }

    public static List<String> getNotExistingIssueNames( Set<String> aJiraIssueNames, Set<String> aExistingIssues ) {
        List<String> aResult = new List<String>();

        if ( aExistingIssues.containsAll( aJiraIssueNames ) ) {
            system.debug( '### aExistingIssues.containsAll( aJiraIssueNames ) : true' );
            return aResult;
        }

        for ( String sItem : aJiraIssueNames ) {
            if ( !aExistingIssues.contains( sItem ) ) {
                aResult.add( sItem );
            }
        }

        return aResult;
    }

    public static void insertNotExistingIssues( Set<String> aJiraIssueNames ) {
        Set<String> aExistingIssues = getExistingIssueNames( aJiraIssueNames );
        List<JiraWrappers.REST_Issue> aIssues = getSFIssues( getNotExistingIssueNames( aJiraIssueNames, aExistingIssues ) );
        if ( aIssues != null && !aIssues.isEmpty() ) {
            JiraMethods.upsertWorklogs( aIssues, aExistingIssues );
        }
    }

    public static Set<String> getJiraIssueNames( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        Set<String> aResult = new Set<String>();

        for ( BitBucketWrappers.Abs_Commit oItem : aCommits ) {
            String sIssueName = getIssueName( oItem.getMessage() );
            if ( !String.isBlank( sIssueName ) ) {
                aResult.add( sIssueName );
            }
        }

        return aResult;
    }

    public static String getIssueName( String sMessage ) {
    	if (sMessage!=null) sMessage = sMessage.toUpperCase();
    	string issuename = regularExpression( oIssueNamePattern, sMessage );
        return issuename;
    }

    public static String getUserEmail( String sCommitRaw ) {
        return regularExpression( oUserEmailPattern, sCommitRaw ).replace('<','').replace('>','');
    }

    private static String regularExpression( Pattern oPattern, String sValue ) {
        Matcher oMatch = oPattern.matcher( sValue );
        system.debug( '### sValue : ' + sValue );
        try {
	        while( oMatch.find() ) {
	            return String.valueOf( oMatch.group() );
	        }
        } catch (exception e) {
        	system.debug( '### Error : ' + e.getMessage() );
        }
        return null;
    }

    private static Map<String, ID> getUserData( List<BitBucketWrappers.Abs_Commit> aCommits ) {
        Set<String> aUserEmails = new Set<String>();
        for ( BitBucketWrappers.Abs_Commit oItem : aCommits ) {
            aUserEmails.add( getUserEmail( oItem.getAuthor() ) );
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

    public static List<JiraWrappers.REST_Issue> getSFIssues( List<String> aJiraIssueNames ) {
        if ( aJiraIssueNames.isEmpty() ) {
            return null;
        }

        JIRARequest oRequest = new JIRARequest( 'key IN (' + String.join( aJiraIssueNames, ',' ) + ')', 1000 );
        system.debug( '### oRequest : ' + oRequest );
        oRequest.sendRequest(); 
        try {
            system.debug( '### oRequest.res.getBody() : ' + oRequest.res.getBody() );
            JiraWrappers.HTTP_Response oResponse = ( JiraWrappers.HTTP_Response )System.JSON.deserialize( oRequest.res.getBody(), JiraWrappers.HTTP_Response.class );
            system.debug( '### oResponse : ' + oResponse );
            if ( !Test.isRunningTest() ) {
                return oResponse.issues;
            }
        } catch ( Exception e ) {
            psaUtils.debug( e );
        }

        if ( Test.isRunningTest() ) {
            return new List<JiraWrappers.REST_Issue>{ JiraMethodsTest.createIssue() };
        }

        return null;
    }
}