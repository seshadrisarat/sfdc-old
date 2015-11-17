@isTest
private class OLE_Test_ChangeYourPassword 
{
	private static testMethod void test() 
	{
        OLE_ChangeYourPassword objController = new OLE_ChangeYourPassword();
        objController.redirectUnAuthenticatedUser();
        objController.changePassword();
        objController.isredirectedFromMyProfile = true;
	}

}