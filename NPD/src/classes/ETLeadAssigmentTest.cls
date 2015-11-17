@isTest
private class ETLeadAssigmentTest
{
    static testMethod void myUnitTest() 
    {
        Lead newTest = new Lead();
        newTest.Created_by_ET__c = true;
        newTest.LastName = 'test';
        newTest.Phone = '333-3333333';
        newTest.Rating = 'A - Decisionmaker - Good Company';
        newTest.status = 'New Leads - Not yet working';
        newTest.Lead_Type__c = 'Inbound - Email';
        newTest.LeadSource = 'Advertising';
        newTest.company = 'test';
        
        insert newTest;
    }
    static testMethod void myUnitTest2() 
    {
        RunLeadAssigmentRules test = new RunLeadAssigmentRules();
    }
}