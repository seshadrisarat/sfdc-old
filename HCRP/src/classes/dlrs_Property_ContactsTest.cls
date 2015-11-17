/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Property_ContactsTest
{
    private static testmethod void testTrigger()
    {
        // Force the dlrs_Property_ContactsTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Property_Contacts__c());
    }
}