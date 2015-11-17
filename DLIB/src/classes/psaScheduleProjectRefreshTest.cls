/*
 * \author Vladimir Dobrelya
 * \date Feb 7, 2014
 * \see https://silverline.jira.com/browse/SLFF-18
 * \detail The test class for psaScheduleProjectRefresh and psaBatchProjectRefresh classes
 */
 @isTest
private class psaScheduleProjectRefreshTest {
	
	@isTest static void psaScheduleProjectRefresh_UnitTest() {
		psaProjectRefeshTest.createData();

		Test.startTest();
			system.schedule( 'TEST_PROJECT_REFRESH', '0 35 1 * 1-12 ? *', new psaScheduleProjectRefresh() );
			Database.executeBatch( new psaBatchProjectRefresh(), 10 );
		Test.stopTest();

		psaProjectRefeshTest.doAsserts();
	}
}