@isTest
private class HelpDeskControllerTest
{
    static testMethod void testController()
    {
        Case testCase = new Case();
        insert testCase;
        
        HelpDeskController controller = new HelpDeskController();
        controller.getCases();
    }
}