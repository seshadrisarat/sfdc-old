@isTest
private class OLE_Test_Register 
{
	private static testMethod void test() 
	{
	    Account objAccount = OLE_CreateRecord.createAccount('Ole Digital Community');
	    insert objAccount;
	    
	    Contact objContact = OLE_CreateRecord.createContact(objAccount.Id,'contact1');
	    insert objContact;
	    
	    Contact objContact2 = OLE_CreateRecord.createContact(objAccount.Id,'contact2');
	    insert objContact2;
	    System.debug('======Email'+objContact.Email+'===='+objContact2.Email);
	    User objUser = OLE_CreateRecord.createUser(objContact.LastName, objContact.Id);
	    insert objUser;
	    
	    Test.setCurrentPageReference(new PageReference('Page.Register'));
        OLE_Register objController = new OLE_Register();
        objController.redirectAuthenticatedUser();
        objController.validateAndSave();
        objController.cancel();
        System.assertEquals(objController.redirectAuthenticatedUser(), null);
	}

}