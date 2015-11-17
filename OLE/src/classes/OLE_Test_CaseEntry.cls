@isTest
private class OLE_Test_CaseEntry
{
	private static testMethod void test() 
	{
        OLE_CaseEntry objController = new OLE_CaseEntry();
        objController.strCaseType = 'Legal';
        objController.createTicket();
	}
	
	private static testMethod void test1() 
	{
	    Case objCase = OLE_CreateRecord.createCase('On Hold','Digital','Email Manual','Hold-Digital case','Hold-Digital case');
	    insert objCase;
	    OLE_CaseEntry objController = new OLE_CaseEntry();
        objController.objCase.Id = objCase.ID;
        objController.createTicket();
	}

}