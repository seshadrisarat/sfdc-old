/**
 * \author Vladimir Dobrelya
 * \date Apr 09, 2014
 * \brief The test class for BitbucketBatch class
 */
@isTest
public class BitbucketBatchTest {
	
	public static String sStart = 'starttest';
	public static String sStop = null;

	@isTest static void test_batch() {
		BitbucketMethodsTest.createData();

		Test.startTest();
			Database.executeBatch( new BitbucketBatch( JiraMethodsTest.sProjectName, sStart ) );
		Test.stopTest();
	}
	
}