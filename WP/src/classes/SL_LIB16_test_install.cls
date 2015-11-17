@isTest
private class SL_LIB16_test_install
{
	private static testMethod void testPostInstallClass()
	{
		SL_LIB16_install controller = new SL_LIB16_install();
		controller.runChecker();
	}
}