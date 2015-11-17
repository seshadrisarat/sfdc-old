@isTest(SeeAllData=true)
public class TestAnnualGoalsDashboardDataController 
{
	static testMethod void testController() 
    {
        AnnualGoalsDashboardDataController controller = new AnnualGoalsDashboardDataController();
        List<SelectOption> userOptions = controller.getUserOptions();
        system.assert(userOptions.size() > 0);
        
        controller.userId = null;
        List<AnnualGoalsUtility.ScheduleSummary> summaries = controller.getScheduleSummaries();
        system.assert(summaries.size() > 0);
        
        controller.userListOnChange();
        
        system.assertEquals(controller.cscTotal, controller.fmaTotal, controller.fmvTotal);
    }
}