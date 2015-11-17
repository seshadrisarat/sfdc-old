@isTest
private class OLE_Test_ForgotYourPassword 
{
	private static testMethod void test() 
	{
        OLE_ForgotYourPassword objController = new OLE_ForgotYourPassword();
        objController.strUsername = 'test@salesforce.com';
        objController.redirectAuthenticatedUser();
        objController.forgotPassword();
        System.assertEquals(objController.forgotPassword(), null);
	}

}