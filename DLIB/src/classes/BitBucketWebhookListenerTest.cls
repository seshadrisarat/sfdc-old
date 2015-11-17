/**
 * \author Vladimir Dobrelya
 * \date Apr 08, 2014
 * \brief The test class for BitBucketWebhookListener class
 */
@isTest
private class BitBucketWebhookListenerTest {
	
	@isTest static void test_method_one() {
		BitbucketMethodsTest.createData();

		system.assertEquals( null, BitbucketMethodsTest.selectCommit( BitbucketMethodsTest.sHash + '0' ) );

		Test.startTest();
			system.assertEquals( 500, handle( null ) ); 
			system.assertEquals( 200, handle( createResponse() ) );
		Test.stopTest();

		system.assertNotEquals( null, JiraMethodsTest.selectIssue() );
		system.assertNotEquals( null, BitbucketMethodsTest.selectCommit( BitbucketMethodsTest.sHash + '0' ) );
	}
	
	static Integer handle( BitBucketWrappers.REST_Response oResponse ) {
		RestContext.request = new RestRequest();
		RestContext.response = new RestResponse();
		if ( oResponse != null ) {
			RestContext.request.addParameter( 'payload', JSON.serialize( oResponse ) );
		}
        BitBucketWebhookListener.doPost();
        return RestContext.response.statusCode;
	}

	static BitBucketWrappers.REST_Response createResponse() {
		BitBucketWrappers.REST_Response oResult = new BitBucketWrappers.REST_Response();
		oResult.commits = BitbucketMethodsTest.createCommits();
		oResult.repository = new BitBucketWrappers.REST_Repository();
		oResult.repository.name = JiraMethodsTest.sProjectName;
		return oResult;
	}
}