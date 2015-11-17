/**
 * \author Vladimir Dobrelya
 * \date Apr 08, 2014
 * \brief The test class for BitbucketMethods class
 */
@isTest
public class BitbucketMethodsTest {

    public static String sHash = '123456789testhash987654321';

    @isTest static void commitTest() {
        createData();       

        system.assertEquals( null, selectCommit( sHash + '0' ) ); 

        List<BitBucketWrappers.REST_Commit> aCommits = createCommits();

        Test.startTest();
            BitbucketMethods.createRecords( aCommits );
            aCommits[ 0 ].raw_node += 'new';
            BitbucketMethods.createRecords( new List<BitBucketWrappers.REST_Commit>{ aCommits[ 0 ] } );
        Test.stopTest();

        system.assertNotEquals( null, JiraMethodsTest.selectIssue() );
        system.assertNotEquals( null, selectCommit( sHash + '0new' ) );
    }

    public static SF_Commit__c selectCommit( String sHashValue ) {
        for ( SF_Commit__c oItem : [ SELECT Id FROM SF_Commit__c WHERE SF_Issue__r.Jira_Issue_Name__c = :JiraMethodsTest.sIssueKey AND Author__c = :(JiraMethodsTest.sUserName+ ' <'+JiraMethodsTest.pContact.Email+'>') AND Hash__c = :sHashValue limit 1 ] ) {
            return oItem;
        }
        return null;
    }

    public static void createData() {
        insert JiraMethodsTest.pProject;
        insert JiraMethodsTest.pContact;
        insert pSFIssue;
    }

    public static List<BitBucketWrappers.REST_Commit> createCommits() {
        List<BitBucketWrappers.REST_Commit> aResult = new List<BitBucketWrappers.REST_Commit>{
            new BitBucketWrappers.REST_Commit(), new BitBucketWrappers.REST_Commit()
        };

        aResult[ 0 ].message = JiraMethodsTest.sIssueKey + '\nTestCommitMessage0';
        aResult[ 0 ].raw_author = JiraMethodsTest.sUserName + ' <'+JiraMethodsTest.pContact.Email+'>';
        aResult[ 0 ].raw_node = sHash + '0';

        aResult[ 1 ].message = JiraMethodsTest.sIssueKey + '\nTestCommitMessage1';
        aResult[ 1 ].raw_author = JiraMethodsTest.sUserName + ' <'+JiraMethodsTest.pContact.Email+'>';
        aResult[ 1 ].raw_node = sHash + '1';

        BitbucketMethods.setRepository( JiraMethodsTest.sProjectName, aResult );

        return aResult;
    }

    public static List<BitBucketWrappers.HTTP_Commit> createHttpCommits() {
        List<BitBucketWrappers.HTTP_Commit> aResult = new List<BitBucketWrappers.HTTP_Commit>{
            new BitBucketWrappers.HTTP_Commit()
        };

        aResult[ 0 ].message = JiraMethodsTest.sIssueKey + '\nTestCommitMessage0';
        aResult[ 0 ].author = new BitBucketWrappers.HTTP_Author();
        aResult[ 0 ].author.raw = JiraMethodsTest.sUserName;
        aResult[ 0 ].hash = sHash + '0';

        return aResult;
    }
    
    public static SF_Issue__c pSFIssue {
        get {
            if ( pSFIssue == null ) {
                pSFIssue = new SF_Issue__c(
                    Name = JiraMethodsTest.sIssueKey,
                    Jira_Issue_Name__c = JiraMethodsTest.sIssueKey,
                    CurrencyIsoCode = 'USD',
                    IsDeleted__c = false,
                    Project__c = JiraMethodsTest.pProject.id
                );
            }
            return pSFIssue;
        } set;
    }
}