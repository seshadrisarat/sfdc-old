/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AS_ProjectTest
{
    private static testmethod void testTrigger()
    {
        // Force the dlrs_AS_ProjectTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new AS_Project__c());
    }
}