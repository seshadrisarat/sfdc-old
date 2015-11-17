@isTest
private class OLE_Test_Login 
{
	private static testMethod void test() 
	{
        OLE_Login objController = new OLE_Login();
        System.currentPageReference().getParameters().put('RetUrl', 'CaseEntry');
        system.debug('====='+URL.getCurrentRequestUrl().getQuery());
        objController.redirectAuthenticatedUser();
        objController.login();
        system.assertEquals(objController.redirectAuthenticatedUser(), null);
	}

}