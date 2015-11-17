@isTest
private class SL_LIB16_test_PostInstallScript
{
	private static testMethod void testPostInstallClass()
	{
		SL_LIB16_PostInstallScript postinstall = new SL_LIB16_PostInstallScript();

		//run the install script
		Test.testInstall(postinstall, null);
	}
}